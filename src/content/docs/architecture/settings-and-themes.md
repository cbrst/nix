---
title: Settings and themes
description: Shared fonts and theme palettes, per-host overrides, and how they are rendered into configuration files.
sidebar:
  order: 3
---

One set of fonts and one colour theme is applied across the terminal, editors,
browser, shell prompt, compositor, desktop shell, GTK, and the boot loader. The
values are defined once in `flake.nix` and reach every module as the `settings`
argument.

## Default settings

```nix
defaultSettings = {
  fonts = {
    sans = "0xPropo";
    mono = "0xProto";
    terminalSize = 11;
  };
  gaming.vrrOutput = null;
  theme = import ./lib/themes.nix { family = "meowsoot"; };
};
```

- `fonts.sans` and `fonts.mono` name the families used by fontconfig, GTK,
  Ghostty, Noctalia, and the editors. The fonts are installed through the
  portable [desktop-base](/nix/profiles/home/) profile.
- `fonts.terminalSize` is the terminal font size.
- `gaming.vrrOutput` names the display that gets on-demand variable refresh in
  Niri; `null` disables it.
- `theme` is a whole theme family loaded from `lib/themes.nix`.

## Per-host overrides

`defaultSettings` is passed to every host through `specialArgs` (NixOS) or
`extraSpecialArgs` (Home Manager). Each host then publishes its **resolved**
settings through `_module.args.settings`. This lets a host layer overrides on
top of the defaults before any module reads them:

```nix
# hosts/home/niflheim.nix
_module.args.settings = lib.recursiveUpdate defaultSettings {
  fonts.terminalSize = 14;
};
```

Asgard sets `gaming.vrrOutput` to its monitor this way, and Niflheim raises the
terminal font size to 14. The template hosts use `defaultSettings` unchanged.
For Asgard, the resolved `settings` are also passed into Home Manager, so system
and user modules see the same values.

## Theme families

[`lib/themes.nix`](https://github.com/cbrst/nix/blob/main/lib/themes.nix)
defines two families, **Meowsoot** (the default) and **Kanagawa**. An unknown
family name fails evaluation. Each family provides:

- A `light` and a `dark` palette with the same semantic keys: background,
  foreground, muted, border, hover, selected, accents, link, status colours
  (error, warning, success, info), diff colours, syntax colours, and five
  surface shades (`shade0` to `shade4`).
- `apps`: the theme names that applications use for their own built-in themes,
  such as Ghostty, Neovim, VS Code, and the GTK theme and package.
- `niri`: the window border gradient and inactive colour.

Most applications follow the system's light or dark appearance and receive both
palettes.

## Rendering templates

Configuration files that need theme colours are checked in as ordinary files
with `@placeholder@` markers. `configLib.renderTemplate` in
[`lib/default.nix`](https://github.com/cbrst/nix/blob/main/lib/default.nix)
reads the file and substitutes each marker:

```nix
xdg.configFile."niri/config.kdl".text =
  configLib.renderTemplate {
    "@active-from@" = settings.theme.niri.activeFrom;
    "@active-to@" = settings.theme.niri.activeTo;
    "@inactive@" = settings.theme.niri.inactive;
  } ./config.kdl;
```

The same mechanism themes the Oh My Posh prompt, the Firefox and Tridactyl CSS,
Noctalia's palette and font, and Niri's borders. The OpenCode theme, imv
background, GTK settings, and Neovim (`CONFIG_THEME_FAMILY`) read the palette
values directly. Asgard's Limine boot menu uses the Meowsoot dark colours.

To switch the whole setup to Kanagawa, change `family` in `defaultSettings` (or
override `theme` for one host) and rebuild.
