{ ... }:
{
  # Home Manager installs and configures Zsh for this user.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # Variables declared here are written into the user's shell environment.
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
