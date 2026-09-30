#!/bin/sh
# Runs inside the sandbox. Static analysis only: nothing renders or executes the files.
cd /work || exit 1
{
  echo "### Extraction (SHA-256 / size / MIME / name)"
  python3 /usr/local/bin/extract.py

  for f in /work/*; do
    echo; echo "################ $(basename "$f")"
    echo "--- file(1)";   file -b "$f"
    echo "--- exiftool";  exiftool -Producer -Creator -CreateDate -ModifyDate -PDFVersion -PageCount -Encryption "$f"
    echo "--- qpdf --check"; qpdf --check "$f" 2>&1 | tail -n 5
    echo "--- pdfid (non-zero keywords only; red flags: /JS /JavaScript /OpenAction /AA /Launch /EmbeddedFile /RichMedia /XFA)"
    python3 /usr/local/bin/pdfid.py -n "$f"
    echo "--- pdf-parser: every /URI target"
    python3 /usr/local/bin/pdf-parser.py --search URI "$f" 2>/dev/null \
      | grep -Eo '\(https?://[^)]*\)' | sort -u || true
    echo "--- ClamAV"; clamscan --no-summary "$f"
  done
} 2>&1 | tee /out/report.txt
