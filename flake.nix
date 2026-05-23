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
