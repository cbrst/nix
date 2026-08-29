{ settings, ... }:
{
  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = builtins.substring 1 6 settings.theme.dark.background;
      };
    };
  };
}
