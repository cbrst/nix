{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg
    yt-dlp
  ];

  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.tridactyl-native
    ];

    profiles.default = {
      id = 0;
      path = "default";
      isDefault = true;

      settings = {
        "browser.startup.page" = 3;
        "browser.toolbars.bookmarks.visibility" = "never";
        "privacy.trackingprotection.enabled" = true;

        # Allow extensions installed by the profile configuration
        "extensions.autoDisableScopes" = 0;
      };

      # enable and install userChrome.css
      userChrome =
        builtins.readFile ./configs/chrome/theme.css + builtins.readFile ./configs/chrome/userChrome.css;

      # install extensions into this profile
      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        [
          tridactyl
          onepassword-password-manager
          export-cookies-txt
          ublock-origin
          stylus
          tampermonkey
        ]
        ++ [
          pkgs.nur.repos.ethancedwards8.firefox-addons.sponsorblock
        ];
    };
  };

  # Link tridactyl config
  xdg.configFile."tridactyl/tridactylrc".source = ./configs/tridactyl/tridactylrc;
  xdg.configFile."tridactyl/themes/theme.css".source = ./configs/tridactyl/theme.css;
}
