{
  configLib,
  lib,
  pkgs,
  settings,
  ...
}:
let
  paletteReplacements = builtins.listToAttrs (
    builtins.concatMap
      (
        variant:
        map
          (name: {
            name = "@${variant}-${name.key}@";
            value = settings.theme.${variant}.${name.attr};
          })
          [
            {
              key = "background";
              attr = "background";
            }
            {
              key = "foreground";
              attr = "foreground";
            }
            {
              key = "border";
              attr = "border";
            }
            {
              key = "accent";
              attr = "accent";
            }
            {
              key = "accent-foreground";
              attr = "accentForeground";
            }
          ]
      )
      [
        "light"
        "dark"
      ]
  );

  # Vimium-C stores multi-line settings as arrays of lines.
  splitLines = text: lib.splitString "\n" (lib.removeSuffix "\n" text);
  lines = path: splitLines (builtins.readFile path);

  # Vimium-C cannot read a config file; this is a backup to import by hand via
  # the options page (Backup/Restore).
  vimiumCSettings = {
    name = "Vimium C";
    "@time" = "";
    # Must be > 10000: store files have mtime 1, which Vimium-C rejects as "not a backup".
    time = 1792859939275;
    environment = {
      extension = "2.12.2";
      platform = "linux";
      chromium = 155;
    };
    keyMappings = lines ./configs/vimium-c/mappings.txt;
    searchEngines = lines ./configs/vimium-c/search-engines.txt;
    userDefinedCss = splitLines (
      configLib.renderTemplate paletteReplacements ./configs/vimium-c/user.css
    );
    smoothScroll = true;
    nextPatterns = "next,newer,weiter,more,>,›,→,»,≫,>>";
    previousPatterns = "prev,previous,older,zurück,<,‹,←,«,≪,<<";
    exclusionRules = [
      {
        pattern = ":https://monkeytype.com/";
        passKeys = "";
      }
    ];
  };
in
{
  home.packages = [ pkgs.nur.repos.lonerOrz.helium ];

  xdg.configFile."vimium-c/settings.json".text = builtins.toJSON vimiumCSettings;
}
