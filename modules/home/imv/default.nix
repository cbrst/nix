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
  wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
in
{
  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = builtins.substring 1 6 settings.theme.dark.background;
      };
      # imv's exec waits on system(), so background anything that may block.
      binds = lib.mkMerge [
        {
          n = "next";
          p = "prev";
          zz = "center";
          "<equal>" = "reset";
          y = ''exec ${wlCopy} < "$imv_current_file" &'';
          "<Shift+Y>" = ''exec printf %s "$imv_current_file" | ${wlCopy} &'';
        }
        (lib.mkIf config.programs.noctalia.enable {
          w = ''exec ${lib.getExe setNoctaliaWallpaper} "$imv_current_file" &'';
        })
      ];
    };
  };
}
