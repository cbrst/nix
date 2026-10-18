---
title: Development
description: Rootless Docker and JetBrains IDEs.
sidebar:
  order: 6
---

The [NixOS development profile](/nix/profiles/nixos/#development) imports two
modules.

## Rootless Docker

`docker.nix` runs Docker in **rootless** mode: the daemon runs as the user, not
as root, and `DOCKER_HOST` points at the user's socket. Containers work without
`sudo` or membership in a `docker` group. LazyDocker comes from the
[development home profile](/nix/profiles/home/#development).

## JetBrains IDEs

`jetbrains.nix` installs PhpStorm, PyCharm, and WebStorm system-wide.
