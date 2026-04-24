# Changelog

All notable changes to this update repository are tracked here.

## 2026-04-24

### Fixed

- Published `0.1.0-5` packages to fix `zyntrix-tui` startup after version checks
  succeeded but the home screen crashed on shell tile loading.
- Published `0.1.0-4` packages to make `zyntrix-tui` resolve shell modules from
  `/opt/zyntrix-shell` on installed systems.
- Published `0.1.0-3` packages to include `zyntrix-tui`, its bundled `tui/`
  Python module, the `/usr/bin/zyntrix-tui` wrapper, and the `python3-textual`
  dependency in `zyntrix-cli`.
- Resolved APT `Hash Sum mismatch` risk by identifying stale signed metadata as the cause.
- Published `0.1.0-2` packages to avoid `zyntrix-shell` maintainer scripts terminating `dpkg` during upgrades.
- Improved command block contrast on the updates page so terminal commands remain readable.
- Strengthened page colors, spacing, borders, and focus states for a clearer update workflow.

### Added

- Added repository documentation with install commands, package layout, publishing checklist, and verification notes.
- Added an updatable roadmap for package, repository, and website work.
- Added `scripts/refresh-metadata.sh` so package indexes, release metadata, and signatures can be refreshed together.

## 0.1.0-1

### Added

- Published initial ZyntrixOS package set:
  - `zyntrix-cli`
  - `zyntrix-config`
  - `zyntrix-os-base`
  - `zyntrix-shell`
  - `zyntrix-update`
- Added signed APT repository metadata for the `stable` channel.
- Added `setup-repo.sh` for online and offline repository setup.
- Added GitHub Pages update portal.
