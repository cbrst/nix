{
  configLib,
  lib,
  pkgs,
  settings,
  ...
}:
let
  vrrOutput = settings.gaming.vrrOutput;
  outputConfig = lib.optionalString (vrrOutput != null) ''
    output "${vrrOutput}" {
      variable-refresh-rate on-demand=true
    }

  '';
in
{
  xdg.configFile."niri/config.kdl".text =
    outputConfig
    + configLib.renderTemplate {
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
