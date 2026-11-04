{ config, lib, ... }:
let
  cfg = config.vmHost;
in
{
  # The host supplies the physical interface (and optionally its MAC address),
  # so this module stays free of machine-specific values.
  options.vmHost.bridge = {
    interface = lib.mkOption {
      type = lib.types.str;
      example = "eno1";
      description = "Wired interface to enslave to the br0 LAN bridge.";
    };
    macAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "e0:d5:5e:0c:07:4d";
      description = ''
        MAC address for br0. Set it to the physical interface's address to keep
        the host's DHCP lease and any router reservation.
      '';
    };
  };

  config = {
    # KVM/QEMU through libvirt, managed with virt-manager or virsh against
    # qemu:///system. Members of the libvirtd group need no root password.
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # Guests attach to br0 and appear on the LAN as their own hosts, which
    # mDNS, Matter and Thread border routing need; libvirt's default NAT
    # network would hide them.
    networking.networkmanager.ensureProfiles.profiles = {
      br0 = {
        connection = {
          id = "br0";
          type = "bridge";
          interface-name = "br0";
          autoconnect-ports = 1;
        };
        bridge.stp = false;
        ethernet = lib.optionalAttrs (cfg.bridge.macAddress != null) {
          cloned-mac-address = cfg.bridge.macAddress;
        };
        ipv4.method = "auto";
        ipv6 = {
          method = "auto";
          addr-gen-mode = "stable-privacy";
        };
      };
      "br0-port-${cfg.bridge.interface}" = {
        connection = {
          id = "br0-port-${cfg.bridge.interface}";
          type = "ethernet";
          interface-name = cfg.bridge.interface;
          controller = "br0";
          port-type = "bridge";
          # Win over NetworkManager's auto-generated "Wired connection" profile.
          autoconnect-priority = 10;
        };
      };
    };
  };
}
