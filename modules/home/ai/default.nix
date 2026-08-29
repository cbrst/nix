{
  inputs,
  pkgs,
  ...
}:

let
  rtk = pkgs.callPackage ../../../packages/rtk {
    inherit inputs;
  };

  serena = inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena;
in
{
  home.packages = [
    rtk
    serena
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      # Current default. You can change provider/model later without
      # touching any of the RTK or Serena integration.
      model = "openai/gpt-5.6-sol";

      # OpenCode itself is managed through Nix.
      autoupdate = false;

      # Let OpenCode compact old conversation history itself.
      compaction = {
        auto = true;

        # Explicitly enable old tool-output pruning.
        # Current OpenCode behavior requires this to be set explicitly.
        prune = true;

        # Leave some breathing room for compaction itself.
        reserved = 10000;
      };
    };

    skills = ./skills;
  };

  programs.mcp = {
    enable = true;

    servers.serena = {
      command = "${serena}/bin/serena";

      args = [
        "start-mcp-server"
        "--transport"
        "stdio"
        "--context"
        "ide"
        "--project-from-cwd"
        "--open-web-dashboard=false"
      ];
    };
  };

  # RTK's native OpenCode integration.
  #
  # This is the exact plugin normally installed by:
  #
  #   rtk init --global --opencode
  #
  # but Home Manager owns it instead.
  xdg.configFile."opencode/plugins/rtk.ts".source = "${inputs.rtk-src}/hooks/opencode/rtk.ts";
}
