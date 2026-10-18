---
title: Network
description: DNS, firewall, and Tailscale.
sidebar:
  order: 2
---

[`modules/nixos/network.nix`](https://github.com/cbrst/nix/blob/main/modules/nixos/network.nix)
is imported by the [desktop profile](/nix/profiles/nixos/#desktop).

## DNS

NetworkManager does not take DNS servers from the router. The system uses
**Quad9** (IPv4 and IPv6), with **Cloudflare** as the fallback.

## Firewall

The firewall is enabled and uses nftables. The Tailscale interface is trusted,
and Tailscale's UDP port is open so direct connections work.

## Tailscale

The Tailscale daemon is enabled and told to use nftables mode for its own
firewall rules. Each host chooses its operator; Asgard sets `cbrst`, so the CLI
and the [tray application](/nix/modules/home/desktop-apps/#other-applications)
work without `sudo`.

## Boot

The "wait online" units are disabled in both the system and the initrd, so a
slow or missing network never delays boot.
