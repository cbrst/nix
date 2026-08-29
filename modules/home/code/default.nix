{ pkgs, ... }:
let
  marketplaceExtensions = {
    meowsoot = pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "meowsoot-vscode";
      publisher = "local";
      version = "0.1.0";
      vsix = ./extensions/meowsoot-vscode-0.1.0.vsix;
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
      ];
      userSettings = ./configs/userSettings.json;
    };
  };
}
