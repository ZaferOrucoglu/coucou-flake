{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, wrapGAppsHook3
, gtk3
, webkitgtk_4_1
, gtk-layer-shell
, libayatana-appindicator
, alsa-lib
, dbus
, openssl
, glib
, libsoup_3
, cairo
, gdk-pixbuf
, libpulseaudio
, gst_all_1
, libx11
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxi
, libxrandr
, libxrender
, libxtst
, libxkbcommon
, wayland
}:

stdenv.mkDerivation rec {
  pname = "coucou";
  version = "0.5.9";

  src = fetchurl {
    url = "https://github.com/Louis-CFM/coucou/releases/download/linux-v${version}/Coucou-Linux-${version}-amd64.deb";
    hash = "sha256-gZq/nc4anwvgIwjXwqSVEFy9EzU+W1ryrCKWwo9qJ50=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    gtk3
    webkitgtk_4_1
    gtk-layer-shell
    libayatana-appindicator
    alsa-lib
    dbus
    openssl
    glib
    libsoup_3
    cairo
    gdk-pixbuf
    libpulseaudio
    libxkbcommon
    wayland
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  appendRunpaths = [
    "${libayatana-appindicator}/lib"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    # Ensure coucou-hook is directly available in $out/bin and $out/lib/Coucou
    if [ -f $out/lib/Coucou/coucou-hook ] && [ ! -f $out/bin/coucou-hook ]; then
      cp $out/lib/Coucou/coucou-hook $out/bin/coucou-hook
    fi
    chmod +x $out/bin/coucou $out/bin/coucou-hook $out/lib/Coucou/coucou-hook

    # Use fr.louisraille.coucou.desktop so XDG Desktop Portal matches app id and avoid duplicate entries in menus
    mkdir -p $out/share/applications
    if [ -f $out/share/applications/Coucou.desktop ]; then
      mv $out/share/applications/Coucou.desktop $out/share/applications/fr.louisraille.coucou.desktop
    fi

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
    )
  '';

  meta = with lib; {
    description = "Mochi lives at the top of your screen and keeps an eye on your AI coding agent sessions";
    homepage = "https://github.com/Louis-CFM/coucou";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "coucou";
  };
}
