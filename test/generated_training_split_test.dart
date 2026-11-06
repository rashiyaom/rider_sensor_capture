import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/services/ml_starter_script_generator.dart';

void main() {
  test(
    'generated Python parses and its purged split shares no source samples',
    () async {
      final dir = await Directory.systemTemp.createTemp('training_split_');
      try {
        final file = File('${dir.path}/trainer.py');
        await file.writeAsString(
          MlStarterScriptGenerator.generateTrainBaselineScript(),
        );
        final result = await Process.run('python3', [
          '-c',
          r'''
import ast, sys
source = open(sys.argv[1]).read()
module = ast.parse(source)
compile(module, sys.argv[1], 'exec')
fn = next(n for n in module.body if isinstance(n, ast.FunctionDef) and n.name == 'train_and_evaluate')
# Exercise the generated split without installing or invoking the ML models.
cut = next(i for i,n in enumerate(fn.body) if isinstance(n, ast.Assign) and any(isinstance(t,ast.Name) and t.id == 'rf' for t in n.targets))
fn.body = fn.body[:cut] + [ast.parse('return X_train, X_test').body[0]]
probe = ast.fix_missing_locations(ast.Module(body=[fn],type_ignores=[]))
namespace = {}
exec(compile(probe, '<split-test>', 'exec'), namespace)
class Rows(list):
    @property
    def iloc(self): return self
for width, stride in [(75,25),(100,10),(50,50)]:
    windows = Rows([set(range(i*stride,i*stride+width)) for i in range(40)])
    purge = (width+stride-1)//stride
    train, test = namespace['train_and_evaluate'](windows,Rows(range(40)),purge)
    assert not set.union(*train).intersection(set.union(*test))
''',
          file.path,
        ]);
        expect(
          result.exitCode,
          0,
          reason: '${result.stdout}\n${result.stderr}',
        );
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );
}
