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

  # Link the whole directory so Python cannot write __pycache__ next to the
  # extension: store files all have mtime 1, so a cached .pyc of an older
  # generation with the same source size would keep calling stale helpers.
  extensions = pkgs.linkFarm "nautilus-python-extensions" [
    {
      name = "context_actions.py";
      path = contextActions;
    }
  ];
in
{
  xdg.dataFile."nautilus-python/extensions".source = extensions;
}
