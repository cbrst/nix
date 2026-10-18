// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

const repo = "https://github.com/cbrst/nix";

export default defineConfig({
  site: "https://cbrst.github.io",
  base: "/nix",
  integrations: [
    starlight({
      title: "cbrst/nix",
      description:
        "A NixOS and Home Manager flake for Linux workstations and macOS.",
      social: [{ icon: "github", label: "GitHub", href: repo }],
      editLink: { baseUrl: `${repo}/edit/main/docs/` },
      lastUpdated: true,
      sidebar: [
        { label: "Getting started", items: [{ autogenerate: { directory: "getting-started" } }] },
        { label: "Architecture", items: [{ autogenerate: { directory: "architecture" } }] },
        { label: "Hosts", items: [{ autogenerate: { directory: "hosts" } }] },
        { label: "Profiles", items: [{ autogenerate: { directory: "profiles" } }] },
        {
          label: "Home Manager modules",
          items: [{ autogenerate: { directory: "modules/home" } }],
        },
        {
          label: "NixOS modules",
          items: [{ autogenerate: { directory: "modules/nixos" } }],
        },
        { label: "Workflows", items: [{ autogenerate: { directory: "workflows" } }] },
      ],
    }),
  ],
});
