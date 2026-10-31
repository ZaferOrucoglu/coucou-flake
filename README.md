# Coucou Flake

[![CI Build Check](https://github.com/ZaferOrucoglu/coucou-flake/actions/workflows/check.yml/badge.svg)](https://github.com/ZaferOrucoglu/coucou-flake/actions/workflows/check.yml)
[![Auto Update Coucou](https://github.com/ZaferOrucoglu/coucou-flake/actions/workflows/update.yml/badge.svg)](https://github.com/ZaferOrucoglu/coucou-flake/actions/workflows/update.yml)

Nix flake for [Coucou](https://github.com/Louis-CFM/coucou) — a notch companion and dynamic island for monitoring AI coding agent sessions (Claude Code, Cursor, Antigravity, Gemini CLI, Codex, etc.).

This flake packages the official Linux release natively for NixOS without bubblewrap or AppImage sandboxes, ensuring full integration with Wayland (`gtk-layer-shell`), Secret Service (keyring), D-Bus, and agent relay sockets.

---

## Features

- **Native & Sandbox-Free:** Runs directly against Nixpkgs libraries (`gtk3`, `webkitgtk_4_1`, `gtk-layer-shell`, `libayatana-appindicator`, `alsa-lib`, `gstreamer`, `pulseaudio`), avoiding Gear Lever / AppImage sandbox restrictions.
- **Full Agent Support (`coucou-hook`):** Installs both `coucou` and the `coucou-hook` agent relay binary into `$out/bin`, allowing CLI coding agents to communicate over `$XDG_RUNTIME_DIR/coucou.sock` without permission issues.
- **XDG Desktop Portal & Shortcuts:** Installs `fr.louisraille.coucou.desktop` to ensure the portal recognizes the application ID for global shortcuts.
- **Hyprland / Wayland Layer-Shell:** Operates as a native overlay layer surface at the top of the screen.
- **Daily Auto-Updates:** GitHub Actions workflow automatically checks for new upstream Linux releases, updates the package hash, verifies the build, and commits updates.

---

## Usage

### Direct Run

Run Coucou without installation:

```bash
# Starts Mochi directly (Hub window hidden):
nix run github:ZaferOrucoglu/coucou-flake -- --autostart

# Or from local clone:
nix run .# -- --autostart
```

### In NixOS Configuration (`flake.nix`)

1. Add the flake to your `inputs`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    coucou = {
      url = "github:ZaferOrucoglu/coucou-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, coucou, ... }@inputs: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # Option A: Import as a NixOS module
        coucou.nixosModules.default

        # Option B: Add to systemPackages manually
        # ({ pkgs, ... }: {
        #   environment.systemPackages = [ coucou.packages.${pkgs.system}.default ];
        # })
      ];
    };
  };
}
```

### In Home Manager

```nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.coucou.packages.${pkgs.system}.default
  ];
}
```

---

## Hyprland Integration & Tips

### 1. Toggle Island Shortcut

Wayland does not allow background key grabs. You can bind Coucou's CLI toggle command in your Hyprland configuration (`binds.lua` or `hyprland.conf`):

```lua
-- In binds.lua:
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd("coucou --shortcut toggleIsland"))
```

### 2. Float the Settings/Hub Window

Coucou contains a settings/hub window (Flow dictation, API keys, etc.). To prevent Hyprland from tiling it and splitting your screen, add a floating window rule (`windowRules.lua`):

```lua
hl.window_rule({
    name = "coucou-hub",
    match = {
        class = "coucou",
        title = "Coucou",
    },
    float = true,
    center = true,
    size = { 1000, 650 },
})
```

*To close/hide the Hub window in Hyprland, simply use your close keybinding (`SUPER + SHIFT + Q`).*

---

## Updating

You can manually trigger the update script:

```bash
nix run .#update
# or
./update.sh
```

---

## License

This packaging flake is licensed under the [MIT License](LICENSE).  
Upstream Coucou code is licensed under the [MIT License](https://github.com/Louis-CFM/coucou/blob/main/LICENSE) (© Louis Raillé). Character designs and assets are © Louis Raillé.
