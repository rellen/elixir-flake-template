{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.shfmt.enable = true;
  programs.shellcheck.enable = true;
}
