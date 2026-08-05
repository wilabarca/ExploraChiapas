import glob

repo_files = glob.glob('lib/features/**/data/**/*repository_impl.dart', recursive=True)

for file in repo_files:
    with open(file, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    has_exceptions = any('core/error/exceptions.dart' in line for line in lines)
    has_failures = any('core/error/failures.dart' in line for line in lines)
    
    new_lines = []
    inserted = False
    
    for line in lines:
        if not inserted and line.startswith('import '):
            if not has_exceptions:
                # Need to figure out relative path. Best is package:explorachiapas/core/error/exceptions.dart
                new_lines.append("import 'package:explorachiapas/core/error/exceptions.dart';")
                has_exceptions = True
            if not has_failures:
                new_lines.append("import 'package:explorachiapas/core/error/failures.dart';")
                has_failures = True
            inserted = True
        new_lines.append(line)
        
    with open(file, 'w') as f:
        f.write('\n'.join(new_lines))

print("Fixed imports")
