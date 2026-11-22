{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.media-center;

  missingUrlPage = pkgs.writeText "media-center-missing-url.html" ''
    <!DOCTYPE html>
    <html>
      <head><meta charset="utf-8"><title>Media Center</title></head>
      <body style="background:#000;color:#ddd;font:2rem sans-serif;padding:4rem">
        <p>No Jellyfin address configured.</p>
        <p>Write the server URL to <code>~/.config/media-center/url</code>,
        then press Ctrl+W to return to the greeter and start the session again.</p>
      </body>
    </html>
  '';

  # Runs inside KWin. When it exits, KWin exits and the greeter returns.
  launcher = pkgs.writeShellApplication {
    name = "media-center-launcher";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.kdePackages.libkscreen
      cfg.chromiumPackage
    ];
    text = ''
      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      profile="$data_home/media-center/chromium"

      # kscreen-doctor talks to KWin over Wayland, so it works without the
      # rest of Plasma. KWin stores the result in kwinoutputconfig.json.
      for output in $(kscreen-doctor --json | jq -r '.outputs[] | select(.connected) | .name'); do
        kscreen-doctor "output.$output.hdr.enable" ${
          lib.optionalString (
            cfg.sdrBrightness != null
          ) "\"output.$output.sdr-brightness.${toString cfg.sdrBrightness}\""
        } || echo "media-center: could not enable HDR on $output" >&2
      done

      url="file://${missingUrlPage}"
      if [[ -s "$config_home/media-center/url" ]]; then
        url="$(head -n 1 "$config_home/media-center/url")"
      fi

      # Chromium, not Firefox: jellyfin-web only advertises HDR10 for desktop
      # Chrome (any OS) and Firefox on macOS, so Firefox on Linux always gets
      # HDR tone-mapped to SDR on the server. Chromium decodes HEVC Main 10
      # through VA-API and describes HDR video to KWin over
      # wp_color_manager_v1, both on by default.
      exec chromium --ozone-platform=wayland --kiosk --no-first-run \
        --no-default-browser-check --disable-session-crashed-bubble \
        --autoplay-policy=no-user-gesture-required \
        --user-data-dir="$profile" "$url"
    '';
  };

  session = pkgs.writeShellApplication {
    name = "media-center-session";
    runtimeInputs = [ pkgs.kdePackages.kwin ];
    text = ''
      exec kwin_wayland --drm --no-lockscreen \
        --exit-with-session=${lib.getExe launcher}
    '';
  };

  sessionPackage =
    (pkgs.writeTextFile {
      name = "media-center-session-desktop";
      destination = "/share/wayland-sessions/media-center.desktop";
      text = ''
        [Desktop Entry]
        Name=Media Center
        Comment=Jellyfin in a full-screen HDR browser on KWin
        Exec=${lib.getExe session}
        Type=Application
        DesktopNames=media-center
      '';
    }).overrideAttrs
      { passthru.providedSessions = [ "media-center" ]; };
in
{
  # A Steam Deck-style session that boots into Jellyfin's web client. KWin
  # runs alone (no Plasma shell) because, unlike gamescope, it offers
  # wp_color_manager_v1 to its clients, which browser HDR video requires.
  # The server address is read from ~/.config/media-center/url at start so
  # it stays out of this public repository.
  options.programs.media-center = {
    enable = lib.mkEnableOption "the Media Center session (Jellyfin web in a KWin kiosk)";

    chromiumPackage = lib.mkPackageOption pkgs "chromium" { };

    sdrBrightness = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 100 1000);
      default = null;
      example = 250;
      description = ''
        SDR reference brightness in nits for the Jellyfin interface while HDR
        is on. Null keeps KWin's stored value.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [ sessionPackage ];
  };
}
