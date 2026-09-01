{
  configLib,
  pkgs,
  settings,
  ...
}:
{
  xdg.configFile."niri/config.kdl".text = configLib.renderTemplate {
    "@active-from@" = settings.theme.niri.activeFrom;
    "@active-to@" = settings.theme.niri.activeTo;
    "@inactive@" = settings.theme.niri.inactive;
  } ./config.kdl;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}
