{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs._1password-cli
  ];

  home.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";

  programs.ssh = {
    enable = true;
    settings."*".IdentityAgent = "~/.1password/agent.sock";
  };

  programs.firefox.profiles.default.extensions.packages = lib.mkIf config.programs.firefox.enable [
    pkgs.nur.repos.rycee.firefox-addons.onepassword-password-manager
  ];
}
