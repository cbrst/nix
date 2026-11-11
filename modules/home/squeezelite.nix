{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.squeezelite-client;

  # PipeWire's PulseAudio server on Linux; CoreAudio (PortAudio) on macOS.
  package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.squeezelite-pulse else pkgs.squeezelite;

  # A locally administered MAC derived from the player name. Squeezelite
  # otherwise takes it from the first network interface, and Music Assistant
  # identifies players by MAC, so bridges or VPN interfaces could make the
  # same machine appear as a new player.
  hash = builtins.hashString "sha256" cfg.name;
  mac = lib.concatStringsSep ":" (
    [ "02" ] ++ map (i: builtins.substring (i * 2) 2 hash) (lib.range 0 4)
  );

  args = [
    "-s"
    cfg.server
    "-n"
    cfg.name
    "-m"
    mac
  ]
  # Release CoreAudio while idle; PipeWire handles an idle stream itself.
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "-C"
    "5"
  ];
in
{
  options.services.squeezelite-client = {
    enable = lib.mkEnableOption "a Squeezelite player for Music Assistant";

    server = lib.mkOption {
      type = lib.types.str;
      example = "100.117.183.9";
      description = ''
        Music Assistant (Slimproto) server, as `host` or `host:port`. It is
        required because autodiscovery broadcasts do not cross Tailscale.
      '';
    };

    name = lib.mkOption {
      type = lib.types.str;
      example = "asgard";
      description = "Player name shown in Music Assistant.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.services.squeezelite = {
          Unit = {
            Description = "Squeezelite player for Music Assistant";
            After = [ "pipewire-pulse.service" ];
            Wants = [ "pipewire-pulse.service" ];
          };
          Service = {
            ExecStart = lib.escapeShellArgs ([ (lib.getExe package) ] ++ args);
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      })

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        launchd.agents.squeezelite = {
          enable = true;
          config = {
            ProgramArguments = [ (lib.getExe package) ] ++ args;
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 5;
          };
        };
      })
    ]
  );
}
