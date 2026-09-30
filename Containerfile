# Static PDF triage sandbox. Built WITH network; run WITHOUT it.
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 ca-certificates curl clamav clamav-freshclam \
        libimage-exiftool-perl qpdf file \
    && freshclam --stdout \
    && curl -fsSL -o /usr/local/bin/pdfid.py \
        https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/pdfid.py \
    && curl -fsSL -o /usr/local/bin/pdf-parser.py \
        https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/pdf-parser.py \
    && apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 1000 analyst

COPY extract.py analyze.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.py /usr/local/bin/analyze.sh

USER analyst
ENTRYPOINT ["/usr/local/bin/analyze.sh"]
