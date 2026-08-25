# Users

Each subdirectory contains the settings that belong to one person regardless of
which machine they use. Keep reusable personal preferences here: Home Manager
state version, common dotfiles, and identity-independent preferences.

Machine-specific choices belong in `../hosts`. Role-specific sets of
applications belong in `../profiles`.

For standalone Home Manager, `flake.nix` imports both the user file and the host
file. For NixOS, the host imports the user file in
`home-manager.users.<name>`.
