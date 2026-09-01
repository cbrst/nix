{ settings, configLib, ... }:
{
  programs.noctalia = {
    enable = true;
    settings = configLib.renderTemplate {
      "@font@" = settings.fonts.mono;
    } ./configs/config.toml;
  };
  xdg.configFile."noctalia/palettes/palette.json".text = configLib.renderTemplate {
    "@dark-background@" = settings.theme.dark.background;
    "@dark-foreground@" = settings.theme.dark.foreground;
    "@dark-muted@" = settings.theme.dark.muted;
    "@dark-shade0@" = settings.theme.dark.shade0;
    "@dark-shade1@" = settings.theme.dark.shade1;
    "@dark-shade2@" = settings.theme.dark.shade2;
    "@dark-shade3@" = settings.theme.dark.shade3;
    "@dark-shade4@" = settings.theme.dark.shade4;
    "@dark-accent2@" = settings.theme.dark.accent2;
    "@dark-link@" = settings.theme.dark.link;
    "@dark-hover@" = settings.theme.dark.hover;
    "@dark-error@" = settings.theme.dark.error;
    "@dark-border@" = settings.theme.dark.border;
    "@light-background@" = settings.theme.light.background;
    "@light-foreground@" = settings.theme.light.foreground;
    "@light-muted@" = settings.theme.light.muted;
    "@light-shade0@" = settings.theme.light.shade0;
    "@light-shade1@" = settings.theme.light.shade1;
    "@light-shade2@" = settings.theme.light.shade2;
    "@light-shade3@" = settings.theme.light.shade3;
    "@light-shade4@" = settings.theme.light.shade4;
    "@light-accent2@" = settings.theme.light.accent2;
    "@light-link@" = settings.theme.light.link;
    "@light-hover@" = settings.theme.light.hover;
    "@light-error@" = settings.theme.light.error;
    "@light-border@" = settings.theme.light.border;
  } ./configs/palette.json;
}
