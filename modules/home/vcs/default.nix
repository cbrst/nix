{ lib, pkgs, ... }:
let
  # Shared by the Git/jj hook and Neovim's NeoJJ description buffer.
  claudeCommitDraft = pkgs.writeShellApplication {
    name = "claude-commit-draft";
    text = builtins.readFile ./hooks/claude-commit-draft;
  };

  prepareCommitMessage = pkgs.writeTextFile {
    name = "prepare-commit-msg";
    executable = true;
    text =
      builtins.replaceStrings
        [ "@claudeCommitDraft@" ]
        [ "${claudeCommitDraft}/bin/claude-commit-draft" ]
        (builtins.readFile ./hooks/prepare-commit-msg);
  };

  jjCommitEditor = pkgs.writeShellApplication {
    name = "jj-commit-editor";
    text = ''
      ${prepareCommitMessage} "$1" "" jj
      # Tells Neovim's description-buffer autocmd the hook already ran.
      export CLAUDE_COMMIT_DRAFT_DONE=1
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
      # The mutable commits connected to x, i.e. the stack x belongs to.
      revset-aliases."stack(x)" = "reachable(x, mutable())";
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
            -o "trunk()"
          ''
        ];
        # Moves the nearest bookmark at or behind @ forward to the newest
        # described, non-empty commit at or behind @, then pushes it.
        push = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            names=$(jj bookmark list -r "heads(::@ & bookmarks())" \
              -T 'name ++ "\n"') &&
            if [ -z "$names" ]; then
              echo "No bookmark at or behind @ to move."
              exit 1
            fi &&
            target='heads(::@ & ~empty() & ~description(exact:""))' &&
            jj bookmark move --from "heads(::@ & bookmarks())" --to "$target" &&
            jj git push $(printf '%s\n' "$names" | sed 's/^/-b exact:/')
          ''
        ];
        # Pushes every bookmark in the stack; -b also tracks new ones.
        sync = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            jj git fetch &&
            jj rebase -s "roots(trunk()..stack(@))" \
            -o "trunk()" &&
            bookmarks=$(jj bookmark list -r "stack(@)" \
              -T '"-b exact:" ++ name ++ "\n"') &&
            if [ -n "$bookmarks" ]; then
              jj git push $bookmarks
            else
              echo "No bookmarks in the current stack to push."
            fi
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
    claudeCommitDraft
  ];
}
