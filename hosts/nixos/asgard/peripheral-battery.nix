{ pkgs, ... }:
let
  # Asgard's wireless peripherals: a Logitech mouse on a Lightspeed receiver
  # (046d:c54d, read through Solaar) and a Logitech PRO X Wireless headset
  # (046d:0aba, read through HeadsetControl). The Womier SK75 keyboard has no
  # software battery report.
  #
  # The Noctalia peripheral-battery bar widget runs this command. It prints a
  # JSON array of { name, icon, level, charging } objects, where icon is a
  # Tabler glyph name and level is a percentage or null. Devices that are off
  # or unreachable are left out.
  peripheralBattery = pkgs.writeShellApplication {
    name = "peripheral-battery";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.headsetcontrol
      pkgs.jq
      pkgs.solaar
    ];
    text = ''
      mouse() {
        local out
        out="$(timeout 20 solaar show all 2>/dev/null)" || true
        # "Battery: 80%, BatteryStatus.DISCHARGING." (an optional voltage can
        # follow the percentage).
        [[ $out =~ Battery:\ ([0-9]+)%[^,]*,\ ([^[:space:]]+) ]] || return 0
        local charging=false
        if [[ ''${BASH_REMATCH[2],,} == *recharg* ]]; then
          charging=true
        fi
        jq -nc --argjson level "''${BASH_REMATCH[1]}" --argjson charging "$charging" \
          '{name: "Mouse", icon: "mouse", $level, $charging}'
      }

      headset() {
        local out
        out="$(timeout 10 headsetcontrol --battery --output json 2>/dev/null)" || return 0
        jq -c '
          .devices[]?
          | select(.battery.status == "BATTERY_AVAILABLE" or .battery.status == "BATTERY_CHARGING")
          | {
              name: "Headset",
              icon: "headphones",
              level: (if .battery.level >= 0 then .battery.level else null end),
              charging: (.battery.status == "BATTERY_CHARGING")
            }
        ' <<<"$out" || true
      }

      {
        mouse
        headset
      } | jq -sc .
    '';
  };
in
{
  # Solaar's udev rules give the logged-in user access to Logitech hidraw
  # nodes, which also covers the headset.
  programs.solaar.enable = true;
  services.udev.packages = [ pkgs.headsetcontrol ];

  environment.systemPackages = [
    pkgs.headsetcontrol
    peripheralBattery
  ];
}
