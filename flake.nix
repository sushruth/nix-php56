{
  description = "PHP 5.6 with mcrypt and ddtrace (PHP-5 branch) for PushPress devbox";

  inputs.nix-phps.url = "github:fossar/nix-phps";

  outputs = { self, nix-phps, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: builtins.listToAttrs
        (map (s: { name = s; value = f s; }) systems);
    in {
      packages = forAllSystems (system:
        let
          pkgs = nix-phps.inputs.nixpkgs.legacyPackages.${system};
          php56base = nix-phps.packages.${system}.php56;

          ddtrace = pkgs.stdenv.mkDerivation {
            pname = "php56-ddtrace";
            version = "PHP-5-e8a294d";
            src = pkgs.fetchFromGitHub {
              owner = "DataDog";
              repo = "dd-trace-php";
              rev = "e8a294d1c1fffd59b5ed8ddb9df340ed43c22fd3";
              sha256 = "0s7xqd9kr3k7d9alaqhiyz35bfk5znl4aj4p6wdlyd8r3prsrkh5";
            };
            nativeBuildInputs = [ php56base php56base.unwrapped.dev php56base.packages.composer pkgs.which pkgs.autoconf pkgs.automake pkgs.libtool ];
            buildInputs = [ pkgs.curl pkgs.pcre ];
            buildPhase = ''
              export HOME=$TMPDIR
              make
              make generate
            '';
            installPhase = ''
              mkdir -p $out/lib/php/extensions
              find . -name "ddtrace.so" -exec install -m 755 {} $out/lib/php/extensions/ddtrace.so \; -quit
              cp -r bridge $out/lib/ddtrace-bridge
            '';
            passthru.extensionName = "ddtrace";
          };
        in
        {
          php56 = php56base.withExtensions
            ({ enabled, all }: enabled ++ [ all.mcrypt ddtrace ]);
          default = self.packages.${system}.php56;
        });
    };
}
