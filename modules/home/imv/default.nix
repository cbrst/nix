{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let
  setNoctaliaWallpaper = pkgs.callPackage ../../../packages/set-noctalia-wallpaper {
    noctalia = config.programs.noctalia.package;
  };
in
{
  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = builtins.substring 1 6 settings.theme.dark.background;
      };
      # imv's exec waits on system(), so background the slow conversion.
      binds = lib.mkIf config.programs.noctalia.enable {
        w = ''exec ${lib.getExe setNoctaliaWallpaper} "$imv_current_file" &'';
      };
    };
  };
}
