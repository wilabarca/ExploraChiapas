import glob

repo_files = glob.glob('lib/features/**/data/**/*repository_impl.dart', recursive=True)

for file in repo_files:
    with open(file, 'r') as f:
        content = f.read()
    
    # We will remove all instances of the block and then add it back only once before the first catch in each try-catch block.
    # Actually, simpler: just remove any duplicate contiguous blocks or just remove them all and re-add properly.
    # Let's remove them all first.
    lines = content.split('\n')
    cleaned_lines = []
    skip = False
    for line in lines:
        if '} on CertificatePinningException catch (e) {' in line:
            skip = True
            continue
        if skip and 'return Left(CertificatePinningFailure(message: e.message));' in line:
            skip = False
            continue
        cleaned_lines.append(line)
        
    # Now add it back properly
    new_lines = []
    # A try-catch block can have multiple catch statements. We only want to add it BEFORE the first one.
    # We can track when we are inside a catch chain.
    in_catch_chain = False
    for line in cleaned_lines:
        if ' catch ' in line and ' on ' in line:
            if not in_catch_chain:
                # First catch in the chain
                indent = line[:len(line) - len(line.lstrip())]
                new_lines.append(indent + '} on CertificatePinningException catch (e) {')
                new_lines.append(indent + '  return Left(CertificatePinningFailure(message: e.message));')
                in_catch_chain = True
        elif '} catch' in line:
            if not in_catch_chain:
                indent = line[:len(line) - len(line.lstrip())]
                new_lines.append(indent + '} on CertificatePinningException catch (e) {')
                new_lines.append(indent + '  return Left(CertificatePinningFailure(message: e.message));')
                in_catch_chain = True
        else:
            if 'try {' in line:
                in_catch_chain = False
            # if we see a closing brace that is not part of a catch, we might be out of the chain, but it's hard to track.
            # simpler: reset in_catch_chain when we see a method signature or something, or just track 'try {'
            
        new_lines.append(line)
        
    with open(file, 'w') as f:
        f.write('\n'.join(new_lines))

print("Fixed")
