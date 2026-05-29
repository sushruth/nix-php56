# nix-php56

PHP 5.6 with mcrypt.

fossar/nix-phps ships php56 without mcrypt. CodeIgniter's Encrypt library requires it.
This flake adds mcrypt via `withExtensions` and publishes prebuilt binaries to Cachix so
no developer needs to compile PHP from source.

## What's in here

- `flake.nix` — takes `fossar/nix-phps` as input, outputs `php56.withExtensions([mcrypt])`
  for aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- `.github/workflows/build.yml` — on push: `nix build`, `cachix push sushruth-nix-php56`

## Using in devbox

In `devbox.json`:

1. Replace the php package reference
2. Add `NIX_CONFIG` so nix pulls the prebuilt binary from Cachix instead of compiling

```json
{
  "packages": [
    "github:sushruth/nix-php56#php56": {"disable_plugin": true}
  ],
  "env": {
    "NIX_CONFIG": "extra-substituters = https://sushruth-nix-php56.cachix.org extra-trusted-public-keys = sushruth-nix-php56.cachix.org-1:diAqn4S5in05R1dMM3CXy29VLkOn9MyGG/ku+zqLmg8="
  }
}
```

The cache is public — no auth token needed to pull.

## Why mcrypt only

All other extensions needed by control-panel-legacy (`gd`, `intl`, `mysqli`, `mbstring`,
`curl`, `openssl`, `sockets`) are already compiled into fossar's php56 default build.
`imagick` is optional — both callers fall back to GD if not present.

## Note: Linux sandbox disabled

`make generate` in dd-trace-php runs `composer update` to download `classpreloader`
for generating PHP bridge files. Nix sandbox on Linux blocks network access by default,
causing the build to fail. CI disables sandbox for Linux builds (`NIX_CONFIG: sandbox = false`)
to allow composer to fetch this dependency. macOS is unaffected (nix sandbox defaults to off).
