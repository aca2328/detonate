# detonate

Static triage of email attachments (PDFs) inside an isolated Apple `container`, without opening them on the Mac.

- Image is built with network (tools + ClamAV signatures); analysis runs on a host-only `--internal` network with no DNS.
- Read-only rootfs, non-root user, all capabilities dropped, 1 CPU / 1 GB.
- The `.eml` is mounted read-only; attachments are extracted to tmpfs and vanish with the container. Only `out/report.txt` returns to the host.
- Checks: SHA-256, file type, metadata, `qpdf --check`, `pdfid`, `/URI` targets via `pdf-parser`, ClamAV. Nothing renders or executes the sample.

## Usage

```sh
cp ~/Downloads/message.eml inbox/   # raw .eml; don't double-click it
./detonate.sh                        # build + analyse -> out/report.txt
./detonate.sh --cleanup              # remove image and network
```

Red flags in the report: non-zero `/JS`, `/JavaScript`, `/OpenAction`, `/AA`, `/Launch`, `/EmbeddedFile`, `/RichMedia`, `/XFA`, or URIs pointing off the sender's domain.

The folder name ends in `.noindex` so Spotlight does not index (and parse) samples dropped in `inbox/`.
