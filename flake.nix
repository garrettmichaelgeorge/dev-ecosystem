{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, self, ... }:
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
          lib = import lib/scripts.nix { inherit pkgs; };
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

            script-with-deps = lib.mkShellScript {
              name = "script-with-deps";
              runtimeInputs = [ pkgs.cowsay ];
            };

            print-date = lib.mkPythonPoetryScript { name = "print-date"; };
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
