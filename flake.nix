{
  description = "Template flake file";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    {
      templates.default = {
        path = ./template;
        description = "Elixir development environment";
      };

    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {

        # for `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # for `nix flake check`
        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [

            # formatting
            treefmt
            nixfmt-rfc-style
            shfmt
            shellcheck

          ];

          shellHook = ''
            echo "Elixir flake template development environment loaded!"
          '';
        };
      }
    );
}
