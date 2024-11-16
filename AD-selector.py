import re
import os
import sys
from tqdm import tqdm

def meets_ad_complexity(password):
    """
    Check if a password meets Active Directory default complexity requirements.
    """
    # At least 3 of the 4 categories:
    has_uppercase = bool(re.search(r'[A-Z]', password))
    has_lowercase = bool(re.search(r'[a-z]', password))
    has_digit = bool(re.search(r'\d', password))
    has_special = bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', password))
    
    # Check that at least 3 categories are satisfied
    categories = sum([has_uppercase, has_lowercase, has_digit, has_special])
    
    # Minimum length: 7 characters
    return len(password) >= 7 and categories >= 3

def filter_passwords(input_file):
    """
    Filter passwords in the file that meet Active Directory default complexity.
    """
    # Get the output filename
    base, ext = os.path.splitext(input_file)
    output_file = f"{base}-AD{ext}"
    
    try:
        # Count total lines for progress display
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
            total_lines = sum(1 for _ in infile)
        
        saved_passwords = 0  # Counter for valid passwords
        
        # Open input and output files
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:
            
            print(f"Processing {input_file}...")
            
            # Process with tqdm progress bar
            for line in tqdm(infile, total=total_lines, desc="Filtering passwords"):
                password = line.strip()
                if meets_ad_complexity(password):
                    outfile.write(password + '\n')
                    saved_passwords += 1
        
        # Display statistics
        percentage_saved = (saved_passwords / total_lines) * 100 if total_lines > 0 else 0
        print(f"Filtered passwords saved to: {output_file}")
        print(f"Saved passwords: {saved_passwords} ({percentage_saved:.2f}% of total)")
    except FileNotFoundError:
        print(f"File not found: {input_file}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python filter_ad_passwords.py <input_file>")
    else:
        input_file = sys.argv[1]
        filter_passwords(input_file)
