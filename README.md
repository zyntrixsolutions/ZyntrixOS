# ZyntrixOS Updates Repository

This repository hosts the public APT update channel for ZyntrixOS. It is designed to work from GitHub Pages, so client machines can install the signing key, add the `stable` source, and receive ZyntrixOS packages through normal `apt update` and `apt full-upgrade` workflows.

## Repository URL

```text
https://zyntrixsolutions.github.io/ZyntrixOS
```

## Quick Install

```bash
curl -fsSL https://zyntrixsolutions.github.io/ZyntrixOS/setup-repo.sh | sudo bash -s -- --repo-url https://zyntrixsolutions.github.io/ZyntrixOS --channel stable
```

## Manual Install

```bash
curl -fsSL https://zyntrixsolutions.github.io/ZyntrixOS/zyntrix-archive-keyring.gpg | sudo tee /usr/share/keyrings/zyntrix-archive-keyring.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/zyntrix-archive-keyring.gpg] https://zyntrixsolutions.github.io/ZyntrixOS stable main" | sudo tee /etc/apt/sources.list.d/zyntrix.list
sudo apt update
```

## Current Channel

| Field | Value |
| --- | --- |
| Suite | `stable` |
| Codename | `stable` |
| Component | `main` |
| Architecture | `amd64` |
| Signing key | `zyntrix-archive-keyring.gpg` |

## Published Packages

The package index is stored at:

```text
dists/stable/main/binary-amd64/Packages
```

Current packages:

- `zyntrix-cli`
- `zyntrix-config`
- `zyntrix-os-base`
- `zyntrix-shell`
- `zyntrix-update`

Latest published revision: `0.1.0-2`.

## Publishing Checklist

Use this checklist every time packages are added, removed, or rebuilt.

- [ ] Add or replace `.deb` files under `pool/main/`.
- [ ] Run `scripts/refresh-metadata.sh` to regenerate and sign repository metadata.
- [ ] Confirm `dists/stable/main/binary-amd64/Packages` changed as expected.
- [ ] Confirm `dists/stable/main/binary-amd64/Packages.gz` changed as expected.
- [ ] Confirm `dists/stable/Release`, `dists/stable/InRelease`, and `dists/stable/Release.gpg` changed together.
- [ ] Run `apt update` on a clean test machine.
- [ ] Confirm no `Hash Sum mismatch` or signature warnings appear.
- [ ] Commit and push the updated package files and metadata together.

## Hash Sum Mismatch Notes

APT prefers `dists/stable/InRelease` when it exists. If `Packages.gz` is updated but `InRelease` still contains older checksums, clients will fail with `Hash Sum mismatch`. Always update and sign `Release`, `InRelease`, and `Release.gpg` in the same publish step as the package index.

If a test machine has cached stale metadata after a fixed publish, clear the local lists and retry:

```bash
sudo rm -f /var/lib/apt/lists/*zyntrixsolutions.github.io*
sudo apt clean
sudo apt update
```

If `dpkg` was interrupted during a previous package install, repair the local package database before retrying:

```bash
sudo dpkg --configure -a
sudo apt --fix-broken install
sudo apt update
```

## Local Verification

```bash
scripts/refresh-metadata.sh
sha256sum dists/stable/main/binary-amd64/Packages.gz
grep -A20 '^SHA256:' dists/stable/Release
gpgv --keyring ./zyntrix-archive-keyring.gpg ./dists/stable/InRelease
```
