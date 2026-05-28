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
          ({ enabled, all }:
            let
              ddtrace = all.datadog_trace.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                  ln -s $out/lib/php/extensions/ddtrace.so \
                         $out/lib/php/extensions/datadog_trace.so
                '';
              });
            in
            enabled ++ [ all.mcrypt ddtrace ]);
        default = self.packages.${system}.php56;
      });
    };
}
