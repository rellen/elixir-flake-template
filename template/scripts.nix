{
  pkgs,
  customPkgs ? { },
}:
let
  packages = pkgs // customPkgs;
in
{
  db_init = pkgs.writeScriptBin "db_init" (
    builtins.replaceStrings
      [ "#!/usr/bin/env bash" "initdb" "pg_ctl" "createuser" ]
      [
        "#!${packages.bash}/bin/bash"
        "${packages.postgresql}/bin/initdb"
        "${packages.postgresql}/bin/pg_ctl"
        "${packages.postgresql}/bin/createuser"
      ]
      (builtins.readFile ./src/bin/db_init.sh)
  );

  db_ctl = packages.writeScriptBin "db_ctl" (
    builtins.replaceStrings
      [ "#!/usr/bin/env bash" "exec pg_ctl" ]
      [ "#!${packages.bash}/bin/bash" "exec ${packages.postgresql}/bin/pg_ctl" ]
      (builtins.readFile ./src/bin/db_ctl.sh)
  );
}
