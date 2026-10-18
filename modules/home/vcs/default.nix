{ lib, pkgs, ... }:
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
      aliases = {
        logn = [
          "log"
          "-r"
          "trunk()..@ | (trunk()..@)-"
        ];
        pull = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            jj git fetch &&
            jj rebase -s "roots(trunk()..stack(@))" \
            -d "trunk()"
          ''
        ];
        sync = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            jj git fetch &&
            jj rebase -s "roots(trunk()..stack(@))" \
            -d "trunk()" &&
            jj git push --changed --allow-new
          ''
        ];
      };
    };
  };

  # jj's dynamic completer only offers changed paths and matches them by
  # literal prefix. Fall back to zsh's file completion when it finds nothing,
  # so partial paths such as m/h/f expand to modules/home/f*.
  programs.zsh.initContent = lib.mkOrder 1010 ''
    _jj_with_files() {
      if (( ! $+functions[_clap_dynamic_completer_jj] )); then
        source <(COMPLETE=zsh command jj)
        compdef _jj_with_files jj
      fi
      _clap_dynamic_completer_jj "$@"
      (( compstate[nmatches] )) || [[ $PREFIX == -* ]] || _files
    }
    compdef _jj_with_files jj
  '';

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = [
    pkgs.blazingjj
  ];
}
