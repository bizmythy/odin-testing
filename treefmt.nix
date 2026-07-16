{
  pkgs,
  ...
}:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    odinfmt.enable = true;
    jsonfmt.enable = true;
    shellcheck.enable = true;
    gofmt.enable = true;
    ruff.enable = true;
    yamlfmt.enable = true;
    toml-sort.enable = true;
    dos2unix.enable = true;
    keep-sorted.enable = true;
    # buggy as of right now
    # nufmt.enable = true;
  };

  settings = {
    excludes = [ ];
    formatter.odinfmt.command = pkgs.writeShellApplication {
      name = "odinfmt-treefmt";
      runtimeInputs = [ pkgs.ols ];
      text = ''
        # odinfmt only accepts one file, while treefmt batches its arguments.
        if [[ "''${1-}" == "-w" ]]; then
          shift
        fi
        for file in "$@"; do
          odinfmt -w "$file"
        done
      '';
    };
  };
}
