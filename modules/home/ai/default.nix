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
    extraPackages = [ pkgs.lua-language-server ];

    settings = {
      model = "openai/gpt-5.6-sol";
      autoupdate = false;
      compaction = {
        auto = true;
        prune = true;
        reserved = 10000;
      };
    };

    agents = ./agents;
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
