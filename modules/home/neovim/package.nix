# A standalone Neovim built from `spec.nix`, without Home Manager.
#
# Published as `packages.<system>.nvim`, so `nix run .#nvim` starts the same
# editor that Home Manager installs, on any machine with Nix. The Lua
# configuration is bundled into the store and loaded through the wrapper's own
# init file; nothing is read from or written to `~/.config/nvim`.
{
  pkgs,
  lib,
  inputs,
  settings,
  # Overrides for `editor.neovim.features`, in the same shape a Home Manager
  # host would set them, e.g. `{ debug.enable = false; }`.
  features ? { },
}:
let
  # Evaluate the same option declarations Home Manager uses, so defaults and
  # type checks are identical.
  resolvedFeatures =
    (lib.evalModules {
      modules = [
        ./options.nix
        { editor.neovim.features = features; }
      ];
    }).config.editor.neovim.features;

  spec = import ./spec.nix {
    inherit
      pkgs
      lib
      inputs
      settings
      ;
    features = resolvedFeatures;
    # Without Home Manager there is no configured `programs.claude-code`.
    claudeCode = pkgs.claude-code;
  };

  # Interpolation copies the configuration directory into the store as a
  # single path, which the generated init file then points at.
  configDir = "${spec.configDir}";
in
pkgs.wrapNeovimUnstable spec.package {
  inherit (spec) plugins;
  # Match the Home Manager module: no language providers.
  withPython3 = false;
  withRuby = false;

  wrapperArgs = [
    # Same placement as Home Manager's `extraPackages`.
    "--suffix"
    "PATH"
    ":"
    (lib.makeBinPath spec.extraPackages)
    # Keep shada, undo, swap, and state apart from any other Neovim on the
    # machine. `--set-default` lets the caller override it.
    "--set-default"
    "NVIM_APPNAME"
    "nvim-flake"
  ];

  # `wrapRc` (the default) starts Neovim with `-u` pointing at this content.
  # Home Manager always creates the data directory; on a fresh machine it is
  # missing, and plugins such as Neo-tree warn on every start when they cannot
  # open their log files there.
  luaRcContent = ''
    vim.fn.mkdir(vim.fn.stdpath("data"), "p")
    vim.g.flake_config_dir = "${configDir}"
    vim.opt.runtimepath:prepend(vim.g.flake_config_dir)
    dofile(vim.g.flake_config_dir .. "/init.lua")
  '';
}
