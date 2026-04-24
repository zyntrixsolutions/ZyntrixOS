# Roadmap

This roadmap is intentionally checklist based so it can be updated as repository work lands.

## Repository Reliability

- [x] Host package index under `dists/stable/main/binary-amd64/`.
- [x] Publish signed `Release`, `InRelease`, and `Release.gpg` metadata.
- [x] Document the hash mismatch failure mode and fix path.
- [x] Add a one-command metadata refresh script that regenerates and signs all APT metadata.
- [ ] Add CI verification that `Release` hashes match `Packages` and `Packages.gz`.
- [ ] Add CI verification for `InRelease` and `Release.gpg` signatures.
- [ ] Add a clean-machine apt update smoke test before releases.

## Packages

- [x] Publish base ZyntrixOS package set.
- [x] Publish `0.1.0-2` package refresh for safer install scripts.
- [ ] Add package-level changelog entries for each package update.
- [ ] Add package descriptions that explain user-visible behavior.
- [ ] Add rollback notes for high-risk package changes.
- [ ] Add beta and canary channels once stable publishing is automated.

## Update Portal

- [x] Show install, update, and channel commands.
- [x] Load package cards from live APT metadata.
- [x] Improve contrast and readability for command blocks.
- [ ] Add visible repository health checks for metadata freshness.
- [ ] Add direct links to package files from each package card.
- [ ] Add a troubleshooting section for common APT errors.

## Documentation

- [x] Add `README.md`.
- [x] Add `CHANGELOG.md`.
- [x] Add `ROADMAP.md`.
- [ ] Add maintainer notes for signing-key rotation.
- [ ] Add release notes template.
- [ ] Add offline install bundle instructions.
