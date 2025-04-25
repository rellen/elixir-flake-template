{
  description = "Elixir development environment";

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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        pkgs = nixpkgs.legacyPackages.${system};

        custom = rec {
          erlang = pkgs.beam.interpreters.erlang_27;
          elixir = pkgs.beam.packages.erlang_27.elixir_1_18;
          elixir_ls = pkgs.elixir_ls.override {
            elixir = elixir;
          };
          postgresql = pkgs.postgresql_16;
          nodejs = pkgs.nodejs_22;
        };

        scripts = import ./scripts.nix {
          inherit pkgs;
          customPkgs = custom;
        };
      in
      {
        # for `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # for `nix flake check`
        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              rebar
              rebar3
              custom.erlang
              custom.elixir
              custom.elixir_ls

              custom.postgresql
              custom.nodejs

              scripts.db_init
              scripts.db_ctl

              # formatting / checking
              treefmt
              nixfmt-rfc-style
              shellcheck
              shfmt
            ]
            ++ optional stdenv.isLinux inotify-tools
            ++ optionals stdenv.isDarwin (
              with darwin.apple_sdk.frameworks;
              [
                CoreFoundation
                CoreServices
              ]
            );

          shellHook = ''
            # this allows mix to work on the local directory
            mkdir -p .nix-mix
            mkdir -p .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$HEX_HOME/bin:$PATH
            export LANG=en_US.UTF-8
            export ERL_AFLAGS="-kernel shell_history enabled"
            export ERL_LIBS=""

            ${scripts.db_init}/bin/db_init --check

            echo "Elixir development environment loaded!"
          '';
        };
      }
    );
}
