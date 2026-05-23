# nix-php56

PHP 5.6 with mcrypt for PushPress devbox.

fossar/nix-phps ships php56 without mcrypt. CodeIgniter's Encrypt library requires it.
This flake adds mcrypt via `withExtensions` and publishes prebuilt binaries to Cachix so
no developer needs to compile PHP from source.

## What's in here

- `flake.nix` — takes `fossar/nix-phps` as input, outputs `php56.withExtensions([mcrypt])`
  for aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- `.github/workflows/build.yml` — on push: `nix build`, `cachix push sushruth-nix-php56`

## Using in devbox

In `devbox.json`, replace:

```json
"github:fossar/nix-phps#php56": {"disable_plugin": true}
```

with:

```json
"github:sushruth/nix-php56#php56": {"disable_plugin": true}
```

Add the Cachix substituter so nix pulls the prebuilt binary:

```json
"env": {
  "NIX_CONFIG": "extra-substituters = https://sushruth-nix-php56.cachix.org extra-trusted-public-keys = sushruth-nix-php56.cachix.org-1:<public-key-here>"
}
```

## One-time Cachix setup (repo maintainer only)

```bash
cachix authtoken <token>
nix build .#packages.aarch64-darwin.php56
cachix push sushruth-nix-php56 ./result
```

After that, CI handles all future pushes.

## Why mcrypt only

All other extensions needed by control-panel-legacy (`gd`, `intl`, `mysqli`, `mbstring`,
`curl`, `openssl`, `sockets`) are already compiled into fossar's php56 default build.
`imagick` is optional — both callers fall back to GD if not present.
