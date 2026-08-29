{ configLib, settings, ... }:
{
  xdg.configFile."niri/config.kdl".text = configLib.renderTemplate {
    "@active-from@" = settings.theme.niri.activeFrom;
    "@active-to@" = settings.theme.niri.activeTo;
    "@inactive@" = settings.theme.niri.inactive;
  } ./config.kdl;
}
