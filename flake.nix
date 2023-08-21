{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          mkShellScript = name: ext: runtimeInputs: pkgs.writeShellApplication {
            inherit name runtimeInputs;
            text =
              let maybeExt = if pkgs.lib.isString (ext) then ".${ext}" else "";
              in builtins.readFile ./scripts/${name}/${name}${maybeExt};
          };

          mkShellScript2 = { name, runtimeInputs, ext ? null }: pkgs.writeShellApplication {
            inherit name runtimeInputs;
            text =
              let maybeExt = if pkgs.lib.isString (ext) then ".${ext}" else "";
              in builtins.readFile ./scripts/${name}/${name}${maybeExt};
          };

          mkPythonScript = name: pkgs.poetry2nix.mkPoetryApplication {
              meta.mainProgram = name;
              projectDir = ./scripts/${name};
            };
        in
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          packages.default = pkgs.hello;
          apps.default = { type = "app"; program = "${config.packages.default}/bin/hello"; };

          packages = {
            my-first-script = pkgs.writeShellApplication {
              name = "my-first-script";
              runtimeInputs = [ ];
              text = builtins.readFile ./scripts/my-first-script/my-first-script.sh;
            };

            # Short form
            script-with-deps = mkShellScript "script-with-deps" "sh" [ pkgs.cowsay ];

            # Medium form; not much shorter than writeShellApplication, but
            # enforces the repo directory convention (scripts/${pkgname}.${ext})
            script-with-deps2 = mkShellScript2 {
              name = "script-with-deps";
              runtimeInputs = [ pkgs.cowsay ];
              ext = "sh";
            };

            print-date = mkPythonScript "print-date";
          };

          checks = config.packages;
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
