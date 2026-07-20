# SANS Workbook Password Removal (using qpdf)

Tired of typing the same password every time you open a SANS electronic workbook
(SEC560, FOR578, etc.)? This repo gives you a small script — and a one-liner —
that use [`qpdf`](https://github.com/qpdf/qpdf) to decrypt a PDF **once** with
your known password, producing an unprotected copy you can open without prompts.

## ⚠️ Legal note — read this first

Only use this on materials you have **legitimately purchased or been granted
access to**, and do **not** share the decrypted PDFs. Violating the SANS
Courseware License Agreement can result in financial liability and
decertification. This tool does not break or bypass unknown passwords — you must
already know the password.

## Contents

- [Requirements](#requirements)
- [Quick start (recommended)](#quick-start-recommended)
- [One-liner (no script)](#one-liner-no-script)
- [Verify it worked](#verify-it-worked)
- [How it works](#how-it-works)
- [License](#license)

## Requirements

- Linux, macOS, or Windows via WSL (Ubuntu, Debian, Kali, etc.)
- `qpdf` installed:

```bash
# Debian / Ubuntu / Kali / WSL
sudo apt update && sudo apt install qpdf -y

# macOS (Homebrew)
brew install qpdf
```

## Quick start (recommended)

The [`decrypt-sans.sh`](decrypt-sans.sh) script handles a single file or a whole
folder, prompts for your password without showing it, and won't overwrite your
originals.

```bash
# 1. Download the script
wget https://raw.githubusercontent.com/Vict0rFrankenst31n/sans-qpdf-decrypt/main/decrypt-sans.sh

# 2. Make it executable
chmod +x decrypt-sans.sh

# 3a. Decrypt one file
./decrypt-sans.sh SEC560_Book1.pdf

# 3b. …or every PDF in the current folder
./decrypt-sans.sh
```

Each `Book1.pdf` becomes `Book1_NoPass.pdf` next to it. You'll be prompted for the
password (input stays hidden). Run `./decrypt-sans.sh --help` for all options.

**Tip:** To skip the prompt for a batch run, export the password first:

```bash
export SANSPWD='your-password'
./decrypt-sans.sh
unset SANSPWD
```

## One-liner (no script)

If you just want the raw command for a single file:

```bash
qpdf --password='your-password' --decrypt SEC560_Book1.pdf SEC560_Book1_NoPass.pdf
```

The new `*_NoPass.pdf` opens without a prompt. You can then archive or delete the
original encrypted copy.

> Note: putting the password directly in the command saves it to your shell
> history. The script above avoids that by prompting instead — prefer it if you
> care about that.

## Verify it worked

Open the new file — it should not ask for a password. Or confirm from the
terminal that encryption is gone:

```bash
qpdf --show-encryption SEC560_Book1_NoPass.pdf
# -> "File is not encrypted"
```

## How it works

`qpdf --decrypt` takes a PDF you can already open (because you supply the correct
password) and writes an equivalent PDF with the encryption removed. It does
**not** crack or guess passwords; it simply removes protection you are already
authorized to bypass. Nothing is uploaded anywhere — everything runs locally.

## License

Released under the [MIT License](LICENSE).
