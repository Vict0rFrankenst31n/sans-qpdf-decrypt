#!/usr/bin/env bash
#
# decrypt-sans.sh — remove the open-password from PDFs you own, using qpdf.
#
# Creates an unprotected copy of one or more password-protected PDFs (such as
# SANS electronic workbooks) so you are not prompted for the password every
# time you open them.
#
# LEGAL: Only use this on materials you have legitimately purchased or been
# granted access to, and do not share the decrypted files. See README.md.

set -euo pipefail

readonly SUFFIX="_NoPass"

usage() {
    cat <<'EOF'
Remove the password from PDFs you own (a friendly wrapper around qpdf).

USAGE
    ./decrypt-sans.sh [file.pdf ...]      Decrypt the given PDF(s)
    ./decrypt-sans.sh                     Decrypt every *.pdf in the current folder
    ./decrypt-sans.sh -h | --help         Show this help

OPTIONS
    -f, --force     Overwrite existing *_NoPass.pdf output files.
    -h, --help      Show this help and exit.

PASSWORD
    You are prompted for the password and your typing stays hidden.
    To skip the prompt (e.g. for batch runs), export it first:
        export SANSPWD='your-password'

OUTPUT
    For each  Book1.pdf  a  Book1_NoPass.pdf  is written next to it.
    Existing output files are left alone unless you pass -f.

REQUIREMENTS
    qpdf must be installed and on PATH:
        Debian/Ubuntu/Kali/WSL:  sudo apt install qpdf
        macOS (Homebrew):        brew install qpdf

EXAMPLES
    ./decrypt-sans.sh SEC560_Book1.pdf
    ./decrypt-sans.sh *.pdf
    export SANSPWD='my-password'; ./decrypt-sans.sh
EOF
}

# ------------------------------- arguments -----------------------------------
FORCE=0
FILES=()
for arg in "$@"; do
    case "$arg" in
        -h|--help)  usage; exit 0 ;;
        -f|--force) FORCE=1 ;;
        -*)         echo "Error: unknown option '$arg'" >&2; usage >&2; exit 1 ;;
        *)          FILES+=("$arg") ;;
    esac
done

# ------------------------------- checks --------------------------------------
# Fail early and clearly if qpdf is missing (instead of a misleading
# "wrong password" further down).
if ! command -v qpdf >/dev/null 2>&1; then
    echo "Error: qpdf is not installed or not on PATH." >&2
    echo "  Debian/Ubuntu/Kali/WSL:  sudo apt install qpdf" >&2
    echo "  macOS (Homebrew):        brew install qpdf" >&2
    exit 1
fi

# If no files were named, use every *.pdf in the current directory.
if [ ${#FILES[@]} -eq 0 ]; then
    shopt -s nullglob
    FILES=( *.pdf )
    shopt -u nullglob
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "Error: no PDF given and none found in $(pwd)." >&2
        echo "Run with -h for usage." >&2
        exit 1
    fi
fi

# ------------------------------- password ------------------------------------
# Prefer the SANSPWD environment variable; otherwise prompt without echoing.
# Note: qpdf briefly receives the password as an argument, so on a shared
# machine another local user could see it via 'ps' for that instant. On a
# personal laptop this is not a concern.
if [ -n "${SANSPWD:-}" ]; then
    PASSWORD="$SANSPWD"
else
    printf 'Enter PDF password: ' >&2
    read -rs PASSWORD
    printf '\n' >&2
fi
if [ -z "$PASSWORD" ]; then
    echo "Error: no password provided." >&2
    exit 1
fi

# ------------------------------- work ----------------------------------------
decrypt_one() {
    local in="$1"
    local out="${in%.*}${SUFFIX}.pdf"

    if [ ! -f "$in" ]; then
        echo "Skip: not found: $in" >&2
        return 1
    fi
    # Don't re-process files this script already produced (batch mode).
    if [[ "$in" == *"${SUFFIX}.pdf" ]]; then
        echo "Skip: $in looks already decrypted"
        return 0
    fi
    if [ -e "$out" ] && [ "$FORCE" -ne 1 ]; then
        echo "Skip: $out already exists (use -f to overwrite)"
        return 0
    fi

    if qpdf --password="$PASSWORD" --decrypt -- "$in" "$out"; then
        echo "Created: $out"
    else
        # Remove any partial/broken output so a failed run leaves nothing behind.
        rm -f -- "$out"
        echo "Failed: $in (wrong password, or file not encrypted/readable)" >&2
        return 1
    fi
}

total=${#FILES[@]}
failed=0
for f in "${FILES[@]}"; do
    decrypt_one "$f" || failed=$((failed + 1))
done

echo ""
echo "Done. $total file(s) processed, $failed failed."
[ "$failed" -eq 0 ]
