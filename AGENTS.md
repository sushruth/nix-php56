# AGENTS.md

use caveman.

## Communication

Caveman always. Drop articles, filler, hedging. Fragments OK. Short synonyms. Technical terms exact. Code unchanged.

## Sources of Truth

1. `SPEC.md` — what to build and why
2. `flake.nix` — canonical package definition
3. `.github/workflows/build.yml` — CI/Cachix push config
4. `fossar/nix-phps` source — upstream PHP packages

## Repo purpose

Single job: provide `php56` with mcrypt via nix flake + Cachix binary cache.
No scope creep. No other PHP versions. No other extensions unless explicitly added.

## Building locally

```bash
nix build .#packages.aarch64-darwin.php56
./result/bin/php -m | grep mcrypt   # must print mcrypt
./result/bin/php -m | grep gd       # must still print gd (regression)
```

## Cachix

Cache name: `sushruth-nix-php56`
Auth token: stored as `CACHIX_AUTH_TOKEN` GitHub Actions secret.
Public key: shown in Cachix dashboard after first push — copy into README + box devbox.json.

## Rules

- No files other than `flake.nix`, `.github/workflows/build.yml`, `.gitignore`, `README.md`, `SPEC.md`, `AGENTS.md`
- No shell scripts
- No extra nix files beyond `flake.nix`
- `flake.lock` is committed (pin fossar input)
- Primary platform: aarch64-darwin (dev Macs). x86_64-linux secondary (CI/prod).
