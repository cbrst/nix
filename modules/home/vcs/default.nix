{ pkgs, ... }:
let
  prepareCommitMessage = pkgs.writeTextFile {
    name = "prepare-commit-msg";
    executable = true;
    text = builtins.readFile ./hooks/prepare-commit-msg;
  };

  jjCommitEditor = pkgs.writeShellApplication {
    name = "jj-commit-editor";
    text = ''
      ${prepareCommitMessage} "$1" "" jj
      exec "''${EDITOR:-nvim}" "$@"
    '';
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Christian Brassat";
        email = "christian@brassat.eu";
      };
      pull = {
        rebase = true;
      };
    };
    hooks.prepare-commit-msg = prepareCommitMessage;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Christian Brassat";
        email = "christian@brassat.eu";
      };
      ui.editor = [ "${jjCommitEditor}/bin/jj-commit-editor" ];
      templates.draft_commit_description = "builtin_draft_commit_description_with_diff";
    };
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = [
    pkgs.blazingjj
  ];
}
