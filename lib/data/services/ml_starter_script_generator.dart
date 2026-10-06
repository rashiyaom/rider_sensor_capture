/// Generates a standalone, production-ready Python training and analysis script (train_baseline.py)
/// bundled directly into every dataset and journey export.
///
/// Enables researchers and ML engineers to train Random Forest and Gradient Boosting models
/// on their exported 50Hz sensor data in under 30 seconds.
class MlStarterScriptGenerator {
  MlStarterScriptGenerator._();

  /// Returns the complete Python 3 script source code
  static String generateTrainBaselineScript({String? defaultCsvFilename}) {
    final csvHint = defaultCsvFilename != null ? "'$defaultCsvFilename'" : "None";

    return '''# ==============================================================================
# 🚴 Ride Sensor ML Pipeline — Baseline Classifier & Feature Extractor
# Generated automatically by Ride Sensor Capture
# ==============================================================================
# Requirements:
#   pip install numpy pandas scikit-learn scipy matplotlib joblib
#
# Usage:
#   python train_baseline.py                     # auto-detects CSV in current directory
#   python train_baseline.py --csv path/to.csv   # specify CSV path explicitly
# ==============================================================================

import os
import sys
import glob
import argparse
import numpy as np
import pandas as pd
from scipy import signal, stats
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_val_score
from sklearn.ensemble import RandomForestClassifier, HistGradientBoostingClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
from sklearn.preprocessing import StandardScaler
import joblib

# Default filename hint from export
DEFAULT_CSV = $csvHint

def find_dataset_csv(cli_arg=None):
    if cli_arg and os.path.exists(cli_arg):
        return cli_arg
    if DEFAULT_CSV and os.path.exists(DEFAULT_CSV):
        return DEFAULT_CSV
    
    # Auto-discover CSVs in current directory
    candidates = glob.glob("*.csv")
    trip_csvs = [c for c in candidates if "trip_" in c or "sensor" in c or "consolidated" in c]
    if trip_csvs:
        return trip_csvs[0]
    if candidates:
        return candidates[0]
    
    raise FileNotFoundError("No sensor CSV files found in the current directory. Specify with --csv <path>")

def load_and_preprocess(csv_path):
    print(f"[*] Loading sensor telemetry from: {csv_path}")
    df = pd.read_csv(csv_path)
    print(f"    Loaded {len(df):,} total sensor rows with columns: {list(df.columns)}")

    # Clean and fill missing sensor columns
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    df[numeric_cols] = df[numeric_cols].ffill().bfill().fillna(0.0)

    # Determine ground-truth label column
    label_col = None
    for col in ['event_type', 'event_label', 'label', 'tag', 'eventType']:
        if col in df.columns:
            label_col = col
            break
    
    if label_col is None:
        print("[!] Warning: No explicit 'event_type' column found. Assuming all rows are 'normal_riding'.")
        df['event_type'] = 'normal_riding'
        label_col = 'event_type'
    else:
        # Standardize missing labels to normal_riding
        df[label_col] = df[label_col].fillna('normal_riding').astype(str).str.strip().str.lower()
        df[label_col] = df[label_col].replace({'': 'normal_riding', 'nan': 'normal_riding', 'none': 'normal_riding'})

    print(f"[*] Label distribution across raw 50Hz rows:\\n{df[label_col].value_counts()}\\n")
    return df, label_col

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
        if len(non_normal) >= int(0.3 * len(window_labels)):
            assigned_label = stats.mode(non_normal, keepdims=False)[0]
        else:
            assigned_label = 'normal_riding'

        rows.append(feats)
        labels.append(assigned_label)

    feature_df = pd.DataFrame(rows).fillna(0.0)
    print(f"[✓] Extracted {len(feature_df):,} temporal feature windows across {feature_df.shape[1]} engineered features.")
    print(f"    Class distribution across windows:\\n{pd.Series(labels).value_counts()}\\n")
    return feature_df, pd.Series(labels)

def train_and_evaluate(X, y):
    print("==============================================================================")
    print("🚀 Training Machine Learning Classifiers (Random Forest & Gradient Boosting)")
    print("==============================================================================")

    # Filter out classes with < 2 instances for stratified splitting
    counts = y.value_counts()
    valid_classes = counts[counts >= 2].index
    if len(valid_classes) < len(counts):
        mask = y.isin(valid_classes)
        X = X[mask]
        y = y[mask]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.25, random_state=42, stratify=y if len(np.unique(y)) > 1 else None
    )

    print(f"[*] Training Set: {len(X_train)} windows | Test Set: {len(X_test)} windows")

    # 1. Random Forest Classifier
    rf = RandomForestClassifier(n_estimators=120, max_depth=12, random_state=42, class_weight='balanced')
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
    features_csv = 'dataset_features_windowed_1s.csv'
    export_df = X.copy()
    export_df['target_label'] = y
    export_df.to_csv(features_csv, index=False)
    print(f"[✓] Exported tabular ML feature dataset to: {features_csv}")

    print("\\n==============================================================================")
    print("✨ ML Pipeline Completed Successfully! You can deploy this model or load it with joblib.")
    print("==============================================================================")

def main():
    parser = argparse.ArgumentParser(description="Ride Sensor Baseline ML Trainer")
    parser.add_argument('--csv', type=str, default=None, help="Path to telemetry CSV file")
    parser.add_argument('--window', type=float, default=1.5, help="Window size in seconds (default: 1.5)")
    parser.add_argument('--stride', type=float, default=0.5, help="Stride step in seconds (default: 0.5)")
    args = parser.parse_args()

    try:
        csv_file = find_dataset_csv(args.csv)
        df, label_col = load_and_preprocess(csv_file)
        X, y = build_windowed_dataset(df, label_col, window_sec=args.window, stride_sec=args.stride)
        train_and_evaluate(X, y)
    except Exception as e:
        print(f"[!] Error executing ML pipeline: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
''';
  }
}
