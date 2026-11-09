/// Generates a standalone Python baseline training and analysis script.
/// bundled directly into every dataset and journey export.
///
/// Enables researchers and ML engineers to train Random Forest and Gradient Boosting models
/// on exported sensor data. Reported scores are within-ride baselines only.
class MlStarterScriptGenerator {
  MlStarterScriptGenerator._();

  /// Returns the complete Python 3 script source code
  static String generateTrainBaselineScript({String? defaultCsvFilename}) {
    final csvHint = defaultCsvFilename != null
        ? "'$defaultCsvFilename'"
        : "None";

    return '''# ==============================================================================
# Ride Sensor ML Pipeline — Baseline Classifier
# Generated automatically by Ride Sensor Capture
# ==============================================================================
# Requirements:
#   pip install numpy pandas scikit-learn scipy matplotlib joblib
#
# Usage:
#   python train_baseline.py                          # finds features_windowed CSV
#   python train_baseline.py --csv features_windowed.csv
# ==============================================================================

import os
import sys
import glob
import argparse
from collections import Counter
import numpy as np
import pandas as pd
from scipy import signal
from sklearn.ensemble import RandomForestClassifier, HistGradientBoostingClassifier
from sklearn.metrics import classification_report, accuracy_score, f1_score
import joblib

# Default filename hint from export
DEFAULT_CSV = $csvHint

def find_dataset_csv(cli_arg=None):
    if cli_arg:
        if os.path.exists(cli_arg):
            return cli_arg
        raise FileNotFoundError(f"CSV not found: {cli_arg}")
    if DEFAULT_CSV and os.path.exists(DEFAULT_CSV):
        return DEFAULT_CSV

    candidates = sorted(glob.glob("features_windowed*.csv"))
    if candidates:
        return candidates[0]
    raise FileNotFoundError("No features_windowed CSV found. Export windowed features from the app first.")

def load_and_preprocess(csv_path):
    print(f"[*] Loading time-based feature windows from: {csv_path}")
    df = pd.read_csv(csv_path)
    required = {'target_label', 'dataset_split', 'split_strategy'}
    if not required.issubset(df.columns):
        raise ValueError("Expected a features_windowed CSV with target_label, dataset_split and split_strategy; raw sensor CSVs cannot be trained by this baseline.")
    if df.empty:
        raise ValueError("The feature CSV contains no windows.")
    df['target_label'] = df['target_label'].fillna('').astype(str).str.strip().str.lower()
    if (df['target_label'] == '').any():
        raise ValueError("Every feature window needs an explicit target_label.")
    if not df['dataset_split'].isin(['train', 'val', 'test']).all():
        raise ValueError("dataset_split must contain only train, val or test.")
    if not df['split_strategy'].eq('chronological_disjoint_samples').all():
        raise ValueError("Expected disjoint raw-sample splits; this export is not suitable for evaluation.")
    print(f"[*] Loaded {len(df):,} windows. Label distribution:\\n{df['target_label'].value_counts()}\\n")
    return df

def prepare_features(df):
    # IDs, timestamps and event review outcomes are metadata or label-derived.
    excluded = {
        'window_index', 'trip_id', 'start_row_idx', 'end_row_idx',
        'target_label_id', 'event_id', 'event_cross_confirmed',
        'event_hr_spike_confirmed', 'duration_sec', 'sample_count',
    }
    numeric = df.select_dtypes(include=[np.number]).columns
    feature_cols = [c for c in numeric if c not in excluded and not c.startswith('event_')]
    if not feature_cols:
        raise ValueError("No numeric sensor features found in the feature CSV.")
    X = df[feature_cols].replace([np.inf, -np.inf], np.nan).fillna(0.0)
    y = df['target_label']
    splits = df['dataset_split']
    return X, y, splits

def extract_window_features(window_df, sample_rate_hz=50.0):
    """
    Extracts statistical, frequency-domain, and multi-sensor correlation features
    from a single fixed temporal window (e.g. 1-2 seconds).
    """
    features = {}

    # 1. Primary IMU Channels
    imu_channels = [
        'accel_x', 'accel_y', 'accel_z',
        'gyro_x', 'gyro_y', 'gyro_z',
        'roll_deg', 'pitch_deg',
        'watch1_accel_x', 'watch1_accel_y', 'watch1_accel_z',
        'watch2_accel_x', 'watch2_accel_y', 'watch2_accel_z',
        'watch1_gyro_x', 'watch1_gyro_y', 'watch1_gyro_z',
        'watch2_gyro_x', 'watch2_gyro_y', 'watch2_gyro_z',
    ]

    for ch in imu_channels:
        if ch in window_df.columns:
            vals = window_df[ch].values
            if len(vals) < 4:
                continue
            
            # Time-domain metrics
            features[f'{ch}_mean'] = float(np.mean(vals))
            features[f'{ch}_std'] = float(np.std(vals))
            features[f'{ch}_rms'] = float(np.sqrt(np.mean(vals ** 2)))
            features[f'{ch}_peak_to_peak'] = float(np.ptp(vals))
            features[f'{ch}_max'] = float(np.max(vals))
            features[f'{ch}_min'] = float(np.min(vals))
            features[f'{ch}_zero_crossings'] = int(np.sum(np.diff(np.signbit(vals - np.mean(vals))) != 0))

            # FFT Frequency-domain metrics
            if len(vals) >= 16:
                fft_vals = np.abs(np.fft.rfft(vals - np.mean(vals)))
                freqs = np.fft.rfftfreq(len(vals), d=1.0 / sample_rate_hz)
                features[f'{ch}_spectral_energy'] = float(np.sum(fft_vals ** 2))
                if np.sum(fft_vals) > 0:
                    features[f'{ch}_dominant_freq_hz'] = float(freqs[np.argmax(fft_vals)])
                    features[f'{ch}_spectral_centroid'] = float(np.sum(freqs * fft_vals) / np.sum(fft_vals))

    # 2. Multi-Sensor Fork vs Footboard Cross-Correlation
    w1_z = 'watch1_accel_z' if 'watch1_accel_z' in window_df.columns else ('accel_z' if 'accel_z' in window_df.columns else None)
    w2_z = 'watch2_accel_z' if 'watch2_accel_z' in window_df.columns else None
    if w1_z and w2_z and len(window_df) >= 16:
        s1 = window_df[w1_z].values - np.mean(window_df[w1_z].values)
        s2 = window_df[w2_z].values - np.mean(window_df[w2_z].values)
        if np.std(s1) > 1e-4 and np.std(s2) > 1e-4:
            corr = signal.correlate(s1, s2, mode='full')
            lags = signal.correlation_lags(len(s1), len(s2), mode='full')
            peak_idx = np.argmax(np.abs(corr))
            features['fork_foot_peak_corr'] = float(corr[peak_idx] / (len(s1) * np.std(s1) * np.std(s2)))
            features['fork_foot_lag_ms'] = float((lags[peak_idx] / sample_rate_hz) * 1000.0)

    # 3. GPS Speed & Dynamic Features
    if 'gps_speed_kmh' in window_df.columns:
        speeds = window_df['gps_speed_kmh'].values
        features['speed_mean_kmh'] = float(np.mean(speeds))
        features['speed_max_kmh'] = float(np.max(speeds))
        features['speed_delta_kmh'] = float(speeds[-1] - speeds[0])

    # 4. Heart Rate Features (Polar Strap & Watches)
    for hr_col in ['polar_hr_bpm', 'watch1_hr_bpm', 'watch2_hr_bpm', 'heart_rate']:
        if hr_col in window_df.columns:
            hrs = window_df[hr_col].replace(0, np.nan).dropna().values
            if len(hrs) > 0:
                features[f'{hr_col}_mean'] = float(np.mean(hrs))
                features[f'{hr_col}_delta'] = float(hrs[-1] - hrs[0])

    return features

def build_windowed_dataset(df, label_col, window_sec=1.5, stride_sec=0.5, sample_rate_hz=50.0):
    window_size = int(window_sec * sample_rate_hz)
    stride = int(stride_sec * sample_rate_hz)

    print(f"[*] Windowing time-series: window_size={window_size} samples ({window_sec}s), stride={stride} samples ({stride_sec}s)")

    rows = []
    labels = []

    for start_idx in range(0, len(df) - window_size + 1, stride):
        window_df = df.iloc[start_idx:start_idx + window_size]
        feats = extract_window_features(window_df, sample_rate_hz=sample_rate_hz)
        
        # Determine dominant event label in window
        window_labels = window_df[label_col].values
        # If any specialized event (e.g. bump, turn) exists in >= 30% of window, assign that label
        non_normal = [l for l in window_labels if l != 'normal_riding']
        if len(non_normal) >= int(np.ceil(0.3 * len(window_labels))):
            assigned_label = Counter(non_normal).most_common(1)[0][0]
        else:
            assigned_label = 'normal_riding'

        rows.append(feats)
        labels.append(assigned_label)

    feature_df = pd.DataFrame(rows).fillna(0.0)
    print(f"[✓] Extracted {len(feature_df):,} temporal feature windows across {feature_df.shape[1]} engineered features.")
    print(f"    Class distribution across windows:\\n{pd.Series(labels).value_counts()}\\n")
    return feature_df, pd.Series(labels)

def train_and_evaluate(X, y, purge_windows, dataset_split=None):
    print("==============================================================================")
    print("🚀 Training Machine Learning Classifiers (Random Forest & Gradient Boosting)")
    print("==============================================================================")

    # Windows overlap. Preserve chronological order and purge every window
    # that could share a raw sample with the test partition.
    if dataset_split is None:
        cutoff = int(len(X) * 0.75)
        train_stop = cutoff - purge_windows
        if train_stop < 2 or len(X) - cutoff < 1:
            raise ValueError("Not enough disjoint windows for evaluation; collect a longer ride.")
        X_train, y_train = X.iloc[:train_stop], y.iloc[:train_stop]
        X_test, y_test = X.iloc[cutoff:], y.iloc[cutoff:]
    else:
        train_mask = dataset_split.eq('train')
        test_mask = dataset_split.eq('test')
        X_train, y_train = X.loc[train_mask], y.loc[train_mask]
        X_test, y_test = X.loc[test_mask], y.loc[test_mask]
        if len(X_train) < 2 or len(X_test) < 2:
            raise ValueError("Need train and test windows from disjoint source samples.")
    print("[*] Disjoint chronological evaluation; this is not held-out-rider validation.")

    print(f"[*] Training Set: {len(X_train)} windows | Test Set: {len(X_test)} windows")

    # 1. Random Forest Classifier
    rf = RandomForestClassifier(n_estimators=120, max_depth=12, random_state=42, class_weight='balanced')
    if y_train.nunique() < 2 or y_test.nunique() < 2:
        raise ValueError("Need at least two event classes in both train and test; collect more labeled rides.")
    rf.fit(X_train, y_train)
    y_pred_rf = rf.predict(X_test)
    rf_acc = accuracy_score(y_test, y_pred_rf)
    rf_f1 = f1_score(y_test, y_pred_rf, average='weighted')

    print(f"\\n[1] 🌲 Random Forest Performance:")
    print(f"    Accuracy: {rf_acc * 100:.2f}% | Weighted F1-Score: {rf_f1:.4f}")
    print("\\nClassification Report:")
    print(classification_report(y_test, y_pred_rf, zero_division=0))

    # Top Feature Importances
    importances = pd.Series(rf.feature_importances_, index=X.columns).sort_values(ascending=False)
    print("Top 10 Most Predictive Sensor Features:")
    for rank, (feat, score) in enumerate(importances.head(10).items(), start=1):
        print(f"  {rank:2d}. {feat:<35} (weight: {score:.4f})")

    # 2. Histogram Gradient Boosting Classifier
    gb = HistGradientBoostingClassifier(random_state=42)
    gb.fit(X_train, y_train)
    y_pred_gb = gb.predict(X_test)
    gb_acc = accuracy_score(y_test, y_pred_gb)
    print(f"\\n[2] ⚡ Gradient Boosting Performance: {gb_acc * 100:.2f}% Accuracy")

    # Save trained baseline model artifact
    model_filename = 'trained_ride_classifier.joblib'
    joblib.dump({'model': rf, 'feature_names': list(X.columns), 'classes': rf.classes_}, model_filename)
    print(f"\\n[✓] Best model saved successfully to: {model_filename}")

    # Export computed windowed feature dataset for Python / Excel / AutoML
    features_csv = 'baseline_features_windowed.csv'
    export_df = X.copy()
    export_df['target_label'] = y
    export_df.to_csv(features_csv, index=False)
    print(f"[✓] Exported tabular ML feature dataset to: {features_csv}")

    print("\\n==============================================================================")
    print("Baseline complete. Validate on held-out riders and rides before using this model for decisions.")
    print("==============================================================================")

def main():
    parser = argparse.ArgumentParser(description="Ride Sensor Baseline ML Trainer")
    parser.add_argument('--csv', type=str, default=None, help="Path to features_windowed CSV")
    args = parser.parse_args()

    try:
        csv_file = find_dataset_csv(args.csv)
        df = load_and_preprocess(csv_file)
        X, y, splits = prepare_features(df)
        train_and_evaluate(X, y, purge_windows=0, dataset_split=splits)
    except Exception as e:
        print(f"[!] Error executing ML pipeline: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
''';
  }
}
