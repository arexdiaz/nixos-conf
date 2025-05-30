{ lib, stdenvNoCC, fetchurl, makeWrapper, appimage-run, libxcb, qt6, libglvnd, libxkbcommon, xcbutil, xcbutilwm, xcbutilimage, xcbutilkeysyms, xcbutilrenderutil, vulkan-loader }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pcsx2";
  version = "2.3.355";

  src = fetchurl {
    url = "https://github.com/PCSX2/pcsx2/releases/download/v${finalAttrs.version}/pcsx2-v${finalAttrs.version}-linux-appimage-x64-Qt.AppImage";
    hash = "sha256-Ta4pvdxVoXnpHvihEe/BxI9pLXfUhUPmdtkuB75nSp4=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper appimage-run ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    # Create a dedicated directory in share for the AppImage and related files
    mkdir -p $out/share/${finalAttrs.pname}

    # Copy the AppImage and make it executable
    cp $src $out/share/${finalAttrs.pname}/${finalAttrs.pname}.AppImage
    chmod +x $out/share/${finalAttrs.pname}/${finalAttrs.pname}.AppImage

    # Create a wrapper script in $out/bin
    # This script will call appimage-run with the AppImage as an argument
    # For QT_QPA_PLATFORM: Keep this to guide Qt
    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/${finalAttrs.pname} \
      --set QT_DEBUG_PLUGINS "1" \
      --set QT_QPA_PLATFORM "xcb;wayland" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        qt6.qtbase
        vulkan-loader
        libxcb
        xcbutil
        xcbutilwm
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        libxkbcommon
        qt6.qtwayland
        libglvnd
      ]}" \
      --add-flags "$out/share/${finalAttrs.pname}/${finalAttrs.pname}.AppImage"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://pcsx2.net";
    description = "Playstation 2 emulator (Linux AppImage)";
    downloadPage = "https://github.com/PCSX2/pcsx2";
    license = with licenses; [ gpl3Plus lgpl3Plus ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})