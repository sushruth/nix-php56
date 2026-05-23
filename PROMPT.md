# Agent pickup prompt

Working dir: ~/code/nix-php56

Read AGENTS.md, SPEC.md, README.md before doing anything.

## Task

Implement the repo per SPEC.md. Specifically:

1. Create `flake.nix` exactly as specced (fossar/nix-phps input, php56 + mcrypt via withExtensions, 4 platforms)
2. Run `nix flake lock` to generate `flake.lock`
3. Create `.github/workflows/build.yml` — matrix build on macos-latest + ubuntu-latest, cachix push
4. Create `.gitignore`
5. Verify: `nix build .#packages.aarch64-darwin.php56 && ./result/bin/php -m | grep mcrypt`
6. Make initial commit with all files

## What NOT to do

- Do not create any files beyond what's listed in SPEC.md rules
- Do not add extensions other than mcrypt
- Do not touch the box repo at ~/pushpress/box

## After completing

Delete this file (PROMPT.md) — it is a one-shot pickup prompt, not permanent docs.
