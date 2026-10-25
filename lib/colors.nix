# Pure colour helpers for deriving extra shades from the theme palettes.
# Colours are "#rrggbb" strings; mixing uses integer percentages.
let
  digits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };
  hexChars = "0123456789abcdef";

  byte = s: digits.${builtins.substring 0 1 s} * 16 + digits.${builtins.substring 1 1 s};
  hexByte =
    n: builtins.substring (n / 16) 1 hexChars + builtins.substring (n - n / 16 * 16) 1 hexChars;
  # Weighted channel average, rounded to the nearest integer.
  mixChannel =
    a: b: pct:
    (a * (100 - pct) + b * pct + 50) / 100;
in
rec {
  stripHash = hex: if builtins.substring 0 1 hex == "#" then builtins.substring 1 6 hex else hex;

  hexToRgb =
    hex:
    let
      h = stripHash hex;
    in
    {
      r = byte (builtins.substring 0 2 h);
      g = byte (builtins.substring 2 2 h);
      b = byte (builtins.substring 4 2 h);
    };

  rgbToHex =
    {
      r,
      g,
      b,
    }:
    "#" + hexByte r + hexByte g + hexByte b;

  # Move `pct` percent of the way from colour `a` toward colour `b`.
  mix =
    a: b: pct:
    let
      x = hexToRgb a;
      y = hexToRgb b;
    in
    rgbToHex {
      r = mixChannel x.r y.r pct;
      g = mixChannel x.g y.g pct;
      b = mixChannel x.b y.b pct;
    };

  lighten = color: pct: mix color "#ffffff" pct;
  darken = color: pct: mix color "#000000" pct;
}
