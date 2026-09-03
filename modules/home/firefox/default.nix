{
  configLib,
  pkgs,
  settings,
  ...
}:
let
  paletteReplacements = {
    "@light-background@" = settings.theme.light.background;
    "@light-foreground@" = settings.theme.light.foreground;
    "@light-muted@" = settings.theme.light.muted;
    "@light-border@" = settings.theme.light.border;
    "@light-hover@" = settings.theme.light.hover;
    "@light-selected@" = settings.theme.light.selected;
    "@light-accent@" = settings.theme.light.accent;
    "@light-accent-foreground@" = settings.theme.light.accentForeground;
    "@light-accent-2@" = settings.theme.light.accent2;
    "@light-accent-3@" = settings.theme.light.accent3;
    "@light-accent-4@" = settings.theme.light.accent4;
    "@light-accent-5@" = settings.theme.light.accent5;
    "@light-error@" = settings.theme.light.error;
    "@light-success@" = settings.theme.light.success;
    "@light-link@" = settings.theme.light.link;
    "@dark-background@" = settings.theme.dark.background;
    "@dark-foreground@" = settings.theme.dark.foreground;
    "@dark-muted@" = settings.theme.dark.muted;
    "@dark-border@" = settings.theme.dark.border;
    "@dark-hover@" = settings.theme.dark.hover;
    "@dark-selected@" = settings.theme.dark.selected;
    "@dark-accent@" = settings.theme.dark.accent;
    "@dark-accent-foreground@" = settings.theme.dark.accentForeground;
    "@dark-accent-2@" = settings.theme.dark.accent2;
    "@dark-accent-3@" = settings.theme.dark.accent3;
    "@dark-accent-4@" = settings.theme.dark.accent4;
    "@dark-accent-5@" = settings.theme.dark.accent5;
    "@dark-error@" = settings.theme.dark.error;
    "@dark-success@" = settings.theme.dark.success;
    "@dark-link@" = settings.theme.dark.link;
  };
in
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

        # Fastfox
        "gfx.content.skia-font-cache-size" = 20;
        "gfx.canvas.accelerated.cache-size" = 512;
        "javascript.options.baselinejit.threshold" = 50;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "network.buffer.cache.size" = 65535;
        "network.buffer.cache.count" = 48;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;

        # Securefox
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.uitour.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.search.suggest.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.dap_enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "datareporting.usage.uploadEnabled" = false;

        # Smoothfox
        "apz.overscroll.enabled" = true;
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
        "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
        "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
        "general.smoothScroll.currentVelocityWeighting" = "1";
        "general.smoothScroll.stopDecelerationWeighting" = "1";
        "mousewheel.default.delta_multiplier_y" = 300;
      };

      # enable and install userChrome.css
      userChrome =
        configLib.renderTemplate paletteReplacements ./configs/chrome/theme.css
        + builtins.readFile ./configs/chrome/userChrome.css;

      # install extensions into this profile
      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        [
          tridactyl
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
  xdg.configFile."tridactyl/themes/theme.css".text =
    configLib.renderTemplate paletteReplacements ./configs/tridactyl/theme.css;
}
