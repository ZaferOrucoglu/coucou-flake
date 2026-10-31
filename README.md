# Coucou Nix Flake

Nix Flake for [Coucou](https://github.com/Louis-CFM/coucou) — a notch companion / dynamic island for monitoring AI coding agent sessions (Claude Code, Antigravity, Cursor, Gemini CLI, Codex, etc.).

## Özellikler

- **Yerel ve Sandbox'sız:** AppImage veya Gear Lever'ın bubblewrap sandbox'ı olmadan doğrudan yerel kütüphanelerle çalışır.
- **Wayland / Hyprland Desteği:** `gtk-layer-shell` ile tam uyumlu overlay yüzeyi.
- **Agent Relay (coucou-hook):** Claude Code ve diğer agent'ların hook mekanizmaları (`coucou.sock` / `coucou-hook`) tam erişimle çalışır.
- **XDG Desktop Portal & Kısayollar:** `fr.louisraille.coucou.desktop` kimliğiyle global kısayollar (GlobalShortcuts portalı) desteklenir.
- **Ses & Bildirimler:** GStreamer eklentileri ve ALSA/PulseAudio/PipeWire desteği paketlenmiştir.

## Kullanım

### Doğrudan Çalıştırma

```bash
nix run github:kullanici/coucou-flake # veya yerel klasörden:
nix run .#
```

### Profile Kurulumu

```bash
nix profile install .#
```

### NixOS / Home Manager Entegrasyonu

`flake.nix` dosyanıza girdi olarak ekleyin:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    coucou.url = "path:/home/zafer/Projects/coucou-flake"; # veya GitHub URL'niz
  };

  outputs = { self, nixpkgs, coucou, ... }: {
    # NixOS sistem paketleri:
    nixosConfigurations.nixosBTW = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            coucou.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

## Linux Ortam Değişkenleri (Gerekirse)

Coucou varsayılan olarak Wayland üzerinde `gtk-layer-shell` overlay moduyla çalışır:

- `COUCOU_LAYER_SHELL=0` : Layer-shell yerine standart pencere olarak açılmasını zorlar.
- `COUCOU_X11=0` : Wayland yerel penceresini korur.
- `COUCOU_DOCK=0` : X11/XWayland modunda Dock yerine Utility pencere türünü kullanır.
