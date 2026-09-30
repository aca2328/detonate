#!/usr/bin/env python3
"""Pull every attachment out of the .eml files in /in into /work, as raw bytes only."""
import email, email.policy, hashlib, pathlib, re

out = pathlib.Path("/work")
for eml in sorted(pathlib.Path("/in").glob("*.eml")):
    msg = email.message_from_bytes(eml.read_bytes(), policy=email.policy.default)
    print(f"== {eml.name}: {msg['Subject']!s}")
    for part in msg.iter_attachments():
        name = re.sub(r"[^A-Za-z0-9._-]", "_", part.get_filename() or "unnamed.bin")
        data = part.get_payload(decode=True) or b""
        (out / name).write_bytes(data)
        print(f"   {hashlib.sha256(data).hexdigest()}  {len(data):>8}  {part.get_content_type():<22} {name}")
