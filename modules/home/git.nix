{ ... }:
{
  # Home Manager generates ~/.gitconfig from these declarative settings.
  programs.git = {
    enable = true;
    settings.user = {
      name = "Replace with your name";
      email = "replace-with-your-email@example.com";
    };
  };
}
