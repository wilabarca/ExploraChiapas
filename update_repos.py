import os
import glob

repo_files = glob.glob('lib/features/**/data/**/*repository_impl.dart', recursive=True)

for file in repo_files:
    with open(file, 'r') as f:
        content = f.read()
    
    # We want to insert the catch block before the first specific Exception catch in each try-catch block,
    # or before the generic catch (e) if no specific ones exist.
    # Often it looks like:
    # } on UnauthorizedException catch (e) {
    # or
    # } on ServerException catch (e) {
    # We can just replace "} on UnauthorizedException catch (e) {" with "} on CertificatePinningException catch (e) {\n      return Left(CertificatePinningFailure(message: e.message));\n    } on UnauthorizedException catch (e) {"
    # Same for ServerException, but only if it doesn't already have CertificatePinningException.
    
    if "CertificatePinningException" in content:
        continue
        
    lines = content.split('\n')
    new_lines = []
    
    for i, line in enumerate(lines):
        if '} on UnauthorizedException catch' in line or '} on ServerException catch' in line:
            # check if previous line has CertificatePinningException
            if i > 0 and 'CertificatePinningException' not in new_lines[-1]:
                indent = line[:len(line) - len(line.lstrip())]
                new_lines.append(indent + '} on CertificatePinningException catch (e) {')
                new_lines.append(indent + '  return Left(CertificatePinningFailure(message: e.message));')
        new_lines.append(line)
        
    with open(file, 'w') as f:
        f.write('\n'.join(new_lines))

print("Done")
