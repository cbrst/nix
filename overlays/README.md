# Overlays

An overlay changes or adds packages in `nixpkgs`. Use it only when the existing
package set is insufficient, for example to patch a package or package software
that is not in nixpkgs.

Overlays are not needed for ordinary user configuration. When you add one,
expose it from `flake.nix` and pass it when importing nixpkgs. Keep each overlay
narrowly focused because it changes the package set for every configuration that
uses it.
