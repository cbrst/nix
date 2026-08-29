{ config, pkgs, ... }:
let
  setNoctaliaWallpaper = pkgs.writeShellApplication {
    name = "set-noctalia-wallpaper";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.imagemagick
      pkgs.libnotify
      config.programs.noctalia.package
    ];
    text = builtins.readFile ./scripts/set-noctalia-wallpaper.sh;
  };

  openFolderSlideshow = pkgs.writeShellApplication {
    name = "open-folder-slideshow";
    runtimeInputs = [ pkgs.mpv ];
    text = builtins.readFile ./scripts/open-folder-slideshow.sh;
  };

  contextActions = pkgs.replaceVars ./extensions/context_actions.py {
    openFolderSlideshow = "${openFolderSlideshow}/bin/open-folder-slideshow";
    setNoctaliaWallpaper = "${setNoctaliaWallpaper}/bin/set-noctalia-wallpaper";
  };
in
{
  xdg.dataFile."nautilus-python/extensions/context_actions.py".source = contextActions;
}
