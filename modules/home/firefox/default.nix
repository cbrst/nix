{ pkgs, ... }:
{
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
        "browser.startup.homepage" = "about:blank";
        "browser.toolbars.bookmarks.visibility" = "never";
        "privacy.trackingprotection.enabled" = true;

        # Allow extensions installed by the profile configuration
        "extensions.autoDisableScopes" = 0;
      };

      # enable and install userChrome.css
      userChrome = builtins.readFile ./userChrome.css;

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
}
