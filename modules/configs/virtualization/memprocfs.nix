{ stdenv
, fetchFromGitHub
, runCommand
, pkg-config
, libusb1, fuse, lz4, autoPatchelfHook
}:

let
  leechcoreFetched = fetchFromGitHub {
    owner = "ufrisk";
    repo = "LeechCore";
    rev = "65f82f18c75160c4897d2e3b7153861c2086f1a1";
    sha256 = "sha256-TY/GhlVsJUCkZUpd4VRdDIwPCFDY4W8B8w3yQLOJlEc=";
  };
  memprocfsFetched = fetchFromGitHub {
    owner = "ufrisk";
    repo = "MemProcFS";
    rev = "ba39cf3bdab2cc791029ace476aeabe7ab7755cd";
    sha256 = "sha256-UAgM/tNEUoo6nCVMmGsLZg+xMke7jseudPdXPkJLNs0=";
  };
  leechcorePluginFetched = fetchFromGitHub {
    owner = "ufrisk";
    repo = "LeechCore-plugins";
    rev = "103fb1fdc9c2c328caede4151221ba0f8be64cd0";
    sha256 = "sha256-Z+gn9PyPhLG1qZAYnbZDzEuPK51JY0XPhzOj3U/n5C0=";
  };
  combinedSources = runCommand "memprocfs-combined-sources" {} ''
    mkdir -p $out
    cp -r ${leechcoreFetched} $out/LeechCore
    cp -r ${memprocfsFetched} $out/MemProcFS
    cp -r ${leechcorePluginFetched} $out/plugins
    # The build environment ensures these are writable; explicit chmod not usually needed here.
  '';
in
stdenv.mkDerivation {
  pname = "MemProcFS";
  version = "5.14.13";

  src = combinedSources;

  nativeBuildInputs = [ pkg-config autoPatchelfHook ];
  buildInputs = [ libusb1 fuse lz4 ];

  buildPhase = ''
    runHook preBuild
    export CFLAGS="-Wno-unused-result -Wno-maybe-uninitialized"
    c=$(nproc)
    make -C ./LeechCore/leechcore -j$c
    make -C ./MemProcFS/vmm -j$c
    make -C ./MemProcFS/memprocfs -j$c
    make -C ./plugins/leechcore_device_qemu -j$c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d $out/bin
    install -d $out/lib/memprocfs
    install -m 755 ./MemProcFS/files/memprocfs $out/bin/
    install -m 644 ./MemProcFS/files/vmm.so $out/lib/memprocfs/
    install -m 644 ./LeechCore/files/leechcore.so $out/lib/memprocfs/
    install -m 644 ./plugins/files/leechcore_device_qemu.so $out/lib/memprocfs/
    runHook postInstall
  '';
}