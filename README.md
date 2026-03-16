# SANS Workbook Password Removal (using qpdf)

Tired of typing the same password every time you open a SANS electronic workbook (SEC560, FOR578, etc.)?

This repo contains a dead-simple one-liner + optional bash script to decrypt the PDF **once** using your known password — creating an unprotected version you can use without prompts.

## Important legal note   
Only use this on SANS materials you have legitimately purchased / received access to. Do **NOT** share decrypted PDFs. Violation of the Courseware License Agreement could result in financial liability and decertification.

## Requirements
- Ubuntu, Debian, Kali, WSL, macOS, or any Linux/macOS system
- `qpdf` installed

```bash
# Ubuntu / Debian / WSL / Kali
sudo apt update && sudo apt install qpdf -y

# macOS (with Homebrew)
brew install qpdf
```
## One-liner method (what most people use)
```bash
export SANSPWD='your-actual-sans-password-here'
qpdf --password="$SANSPWD" --decrypt ./SEC560_GPEN_Book1.pdf ./SEC560_GPEN_Book1_NoPass.pdf
```
Replace filenames as needed. After this runs successfully:

The new file (*_NoPass.pdf) opens without any password prompt.
You can delete or archive the original encrypted version.
## Optional: Simple bash script (decrypt-sansk.sh)
Create a file called decrypt-sansk.sh:
```bash
#!/usr/bin/env bash

# Usage: ./decrypt-sansk.sh Book1.pdf
#        or drag-and-drop the PDF onto the script

if [ $# -ne 1 ]; then
    echo "Usage: $0 input.pdf"
    exit 1
fi

INPUT="$1"
OUTPUT="${INPUT%.*}_NoPass.pdf"

echo "Enter your SANS workbook password:"
read -s SANSPWD

qpdf --password="$SANSPWD" --decrypt "$INPUT" "$OUTPUT"

if [ $? -eq 0 ]; then
    echo "Success! Created: $OUTPUT"
    echo "You can now open it without password prompts."
else
    echo "Failed. Check password or if qpdf is installed."
fi
```
Make it executable:
```bash
chmod +x decrypt-sansk.sh
```
Then run:
```bash
./decrypt-sansk.sh SEC560_GPEN_Book1.pdf
```
## Bulk decrypt (all PDFs in current folder)
If you have many books/sections:
```bash
export SANSPWD='your-password'
for f in *.pdf; do
    [ -f "$f" ] || continue  # skip if no PDFs
    OUTPUT="${f%.*}_nopass.pdf"
    qpdf --password="$SANSPWD" --decrypt "$f" "$OUTPUT"
    if [ $? -eq 0 ]; then
        echo "Decrypted: $OUTPUT"
    else
        echo "Failed: $f"
    fi
done
unset SANSPWD
```







