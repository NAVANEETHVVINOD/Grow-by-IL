import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Replace GoogleFonts.spaceGrotesk(...) with Theme.of(context).textTheme.displaySmall?.copyWith(...)
    # We will use headlineMedium for spaceGrotesk and bodyLarge for dmSans as a base
    
    # regex to match GoogleFonts.spaceGrotesk(...)
    content = re.sub(r'GoogleFonts\.spaceGrotesk\(', r'Theme.of(context).textTheme.titleLarge?.copyWith(', content)
    content = re.sub(r'GoogleFonts\.dmSans\(', r'Theme.of(context).textTheme.bodyMedium?.copyWith(', content)

    # Need to remove import 'package:google_fonts/google_fonts.dart';
    if original != content:
        content = re.sub(r"import 'package:google_fonts/google_fonts\.dart';\n?", "", content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

def main():
    lib_dir = os.path.join('F:\\', 'kannan', 'projects', 'Grow', 'grow', 'lib')
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
