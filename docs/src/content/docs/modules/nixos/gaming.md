---
title: Gaming
description: Steam, Gamescope, GameMode, controllers, and a low-latency scheduler.
sidebar:
  order: 4
---

[`modules/nixos/gaming.nix`](https://github.com/cbrst/nix/blob/main/modules/nixos/gaming.nix)
is imported directly by [Asgard](/nix/hosts/asgard/).

| Feature | Configuration |
| --- | --- |
| Steam | Enabled with Extest (Steam Input on Wayland), Protontricks, and Proton-GE as an extra compatibility tool |
| Gamescope | Enabled with the WSI layer and `CAP_SYS_NICE` so it can raise its priority |
| GameMode | Enabled with a renice of 10; the user must be in the `gamemode` group |
| Controllers | `xone` driver for Xbox wireless controllers and the dongle |
| IRQ balancing | `irqbalance` spreads interrupts across cores |
| Scheduler | `sched_ext` with `scx_lavd`, which targets low-latency interactive workloads and falls back to the kernel scheduler if it exits |

## Related configuration

- The [gaming home profile](/nix/profiles/home/#gaming) adds MangoHud and Prism
  Launcher.
- [Niri](/nix/modules/home/niri/) enables on-demand variable refresh rate for
  Steam games and Gamescope on the display named in `settings.gaming.vrrOutput`.
