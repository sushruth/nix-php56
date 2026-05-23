# Spec: nix-php56

## Problem

`fossar/nix-phps#php56` does not include mcrypt. CodeIgniter Encrypt library in
`control-panel-legacy` calls `mcrypt_*` functions → fatal error at runtime.

All other required extensions (`gd`, `intl`, `mysqli`, `mbstring`, `curl`, `openssl`,
`sockets`, `opcache`) are already in fossar's default php56 build. Only mcrypt is missing.

## Goal

Publish a nix flake at `github:sushruth/nix-php56` that:
1. Provides `php56` with mcrypt enabled as a nix package
2. Builds for all 4 platforms (aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux)
3. Pushes prebuilt binaries to Cachix on every push → zero compilation for devs

## Files to create

### `flake.nix`

```nix
{
  description = "PHP 5.6 with mcrypt for PushPress devbox";

  inputs.nix-phps.url = "github:fossar/nix-phps";

  outputs = { self, nix-phps, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: builtins.listToAttrs
        (map (s: { name = s; value = f s; }) systems);
    in {
      packages = forAllSystems (system: {
        php56 = nix-phps.packages.${system}.php56.withExtensions
          ({ enabled, all }: enabled ++ [ all.mcrypt ]);
        default = self.packages.${system}.php56;
      });
    };
}
```

### `.github/workflows/build.yml`

Trigger: push to main, pull_request.

Steps:
1. `uses: cachix/install-nix-action@v27` with `nix_path: nixpkgs=channel:nixos-unstable`
2. `uses: cachix/cachix-action@v15` with `name: sushruth-nix-php56`, authToken from secret
3. `run: nix build .#packages.aarch64-darwin.php56` (on macos-latest runner)
4. Push result to Cachix

Run matrix: `[macos-latest, ubuntu-latest]` × `[aarch64-darwin, x86_64-linux]`.
For cross (aarch64-linux, x86_64-darwin), use `nix build --system` with extra-platforms
or skip for now — primary targets are aarch64-darwin (dev Macs) and x86_64-linux (CI/prod).

### `.gitignore`

```
result
result-*
.direnv
```

## Integration into box (out of scope for this repo)

After binary cache is seeded, in `box/devbox.json`:
- Swap `"github:fossar/nix-phps#php56"` → `"github:sushruth/nix-php56#php56"`
- Add `NIX_CONFIG` env with substituter URL + public key from Cachix dashboard

## Acceptance criteria

- `nix build .#packages.aarch64-darwin.php56` succeeds
- `result/bin/php -m | grep mcrypt` prints `mcrypt`
- `result/bin/php -m | grep gd` prints `gd` (regression check — must not drop existing ext)
- CI passes on push
- Cachix shows the derivation as cached
