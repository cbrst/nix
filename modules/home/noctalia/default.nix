{ settings, configLib, ... }:
{
  programs.noctalia = {
    enable = true;
    settings = configLib.renderTemplate {
      "@font@" = settings.fonts.mono;
    } ./config.toml;
  };
}
