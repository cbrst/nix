{ lib, pkgs, ... }:
let
  hookFiles = lib.filterAttrs (_name: type: type == "regular") (builtins.readDir ./hooks);
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Christian Brassat";
        email = "christian@brassat.eu";
      };
      pull = {
        rebase = true;
      };
    };
    hooks = lib.mapAttrs (
      name: _type:
      pkgs.writeTextFile {
        inherit name;
        executable = true;
        text = builtins.readFile (./hooks + "/${name}");
      }
    ) hookFiles;
  };
}
