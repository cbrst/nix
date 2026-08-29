{
  pkgs,
  settings,
  ...
}:
let
  marketplaceExtensions = {
    meowsoot = pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "meowsoot-vscode";
      publisher = "local";
      version = "0.1.0";
      vsix = ./extensions/meowsoot-vscode-0.1.0.vsix;
    };
    kanagawa = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "kanagawa-vscode-color-theme";
        publisher = "metaphore";
        version = "1.1.0";
        hash = "sha256-HjKlDzXc6HkDyNZJGK0wAdC2F6VAk3utywu0R+dI3RA=";
      };
    };
  };
in
{
  programs.vscodium = {
    enable = true;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      enableMcpIntegration = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        jnoortheen.nix-ide
        svelte.svelte-vscode
        timonwong.shellcheck
        usernamehw.errorlens
        bradlc.vscode-tailwindcss
        gruntfuggly.todo-tree
        editorconfig.editorconfig
        tamasfe.even-better-toml
        marketplaceExtensions.meowsoot
        marketplaceExtensions.kanagawa
      ];
      userSettings = builtins.fromJSON (builtins.readFile ./configs/userSettings.json) // {
        "window.autoDetectColorScheme" = true;
        "workbench.colorTheme" = settings.theme.apps.vscodium.dark;
        "workbench.preferredDarkColorTheme" = settings.theme.apps.vscodium.dark;
        "workbench.preferredLightColorTheme" = settings.theme.apps.vscodium.light;
      };
    };
  };
}
