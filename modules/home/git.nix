{ ... }:
{
  # Home Manager generates ~/.gitconfig from these declarative settings.
  programs.git = {
    enable = true;
    settings.user = {
      name = "Christian Brassat";
      email = "christian@brassat.eu";
    };
  };
}
