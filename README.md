# Setup Nix

Shikanime Studio standard Nix install for GitHub Actions. It installs Nix using Determinate Systems and enables Magic Nix Cache for faster builds.

## What It Does

- Installs Nix (`DeterminateSystems/nix-installer-action@v20`)
- Enables Magic Nix Cache (`DeterminateSystems/magic-nix-cache-action@v13`)
- Prepares runners for `nix build`, `nix run`, and `nix flake check`

## Quick Start

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: shikanime-studio/setup-nix@v1

      - name: Build
        run: nix build ".#"
```
