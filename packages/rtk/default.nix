{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  sqlite,
  inputs,
}:

rustPlatform.buildRustPackage {
  pname = "rtk";
  version = "0.42.4";

  src = inputs.rtk-src;

  cargoLock = {
    lockFile = "${inputs.rtk-src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  # RTK 0.42.4 fails during `cargo test` because its crate has
  # `warnings = "deny"` and some code is only considered unused
  # in the test build.
  #
  # The release binary itself builds successfully.
  doCheck = false;

  meta = {
    description = "Rust Token Killer - CLI output compression for AI agents";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.asl20;
    mainProgram = "rtk";
    platforms = lib.platforms.unix;
  };
}
