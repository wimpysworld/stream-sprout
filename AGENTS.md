# AGENTS.md

## Overview

Stream Sprout is a bash-based RTMP restreaming tool that forwards a single video source (from OBS Studio or similar) to multiple destinations like Twitch, YouTube, Owncast, and Peertube simultaneously. It uses FFmpeg's tee muxer to copy streams without transcoding.

## Tech Stack

- **Language:** Bash 5.0+ (single script: `stream-sprout`)
- **Runtime dependency:** FFmpeg (RTMP server and restreaming)
- **Configuration:** YAML parsed via awk/sed
- **Packaging:** Nix flake, Debian .deb, Snap, Docker/Podman

## Build and Run Commands

```bash
# Run directly (requires ffmpeg, bash 5.0+, awk, grep, sed)
./stream-sprout --config stream-sprout.yaml

# Show version and FFmpeg info
./stream-sprout --version

# Show system info (useful for bug reports)
./stream-sprout --info

# Nix build
nix build

# Enter development shell with all dependencies
nix develop

# Docker build and run
docker build -t stream-sprout .
docker run -p 1935:1935 -it -v $PWD:/data stream-sprout --config /data/stream-sprout.yaml
```

## Linting

ShellCheck is enforced via CI on all pull requests.

```bash
# Run locally before committing
shellcheck stream-sprout
```

The script includes `# shellcheck disable=SC2154` for variables set dynamically via `eval` from YAML parsing.

## Code Style

- Bash scripts use `#!/usr/bin/env bash`
- Functions use `function name() {}` syntax
- Use `local` for function-scoped variables
- Use `readonly` for constants
- Validation with informative error messages using Unicode icons and ANSI colours
- Version is tracked in the script: `readonly VERSION="x.y.z"`

## Project Structure

```
stream-sprout           # Main bash script (single file)
stream-sprout.yaml      # Local config (gitignored)
stream-sprout.yaml.example  # Example configuration
package.nix             # Nix package definition
devshell.nix            # Nix development shell
flake.nix               # Nix flake
Dockerfile              # Alpine-based container
```

## Configuration

YAML config with two main sections:

- `server:` - RTMP server settings (ip, port, app, key, archive options)
- `services:` - Destination services (each with enabled, rtmp_server, key)

Config search order: `./stream-sprout.yaml`, `$XDG_CONFIG_HOME/stream-sprout.yaml`, `/etc/stream-sprout.yaml`

## PR and Commit Guidelines

- **Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/)**
- PR titles are validated against Conventional Commits format
- Single-commit PRs must have matching PR title and commit message
- ShellCheck must pass with no warnings

Common prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`

## Version Updates

When changing version:

1. Update `VERSION` in `stream-sprout` script
2. The Nix package extracts version automatically from the script

## Constraints

- Requires bash 5.0 or newer
- FFmpeg must be available on PATH
- RTMP only (no RTMPS support currently)
- FFmpeg does not enforce stream keys (documented security limitation)

## Security Considerations

- Stream keys are stored in plain text in YAML config
- FFmpeg accepts any RTMP stream on the configured port regardless of app/key path
- Do not expose the RTMP port to untrusted networks without additional protection (VPN, firewall, SSH tunnel)
