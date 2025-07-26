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
    rev = "8fa197f7bebaa1520fdbb4a4a5aae768d14aa84c";
    sha256 = "sha256-A1tNbsP0wVVBalO1I4baktd+25IcPMyUYfeCrrxJw5M=";
  };
  leechcorePluginFetched = fetchFromGitHub {
    owner = "ufrisk";
    repo = "LeechCore-plugins";
    rev = "12cde3099269367540f7ed73376135e65c437955";
    sha256 = "sha256-tMGOCVX1jrBU5riSk/yTRVAmIxYDpoPpvJlTlR5AOao=";
  };
  pcileechFetched = fetchFromGitHub {
    owner = "ufrisk";
    repo = "pcileech";
    rev = "3ca4e7be4f4c33ab30ad0b1c7d31514bc4840022";
    sha256 = "sha256-9nsmWkmUw6y2rnsL0VNH4THSrwVyNtHox/ZJs9y/+Es=";
  };
  combinedSources = runCommand "memprocfs-combined-sources" {} ''
    mkdir -p $out
    cp -r ${leechcoreFetched} $out/LeechCore
    cp -r ${memprocfsFetched} $out/MemProcFS
    cp -r ${pcileechFetched} $out/pcileech
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
    make -C ./pcileech/pcileech -j$c
    make -C ./plugins/leechcore_device_qemu -j$c
    make -C ./plugins/leechcore_device_qemu_pcileech -j$c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d $out/bin $out/lib
    install -m 755 ./MemProcFS/files/memprocfs $out/bin/
    install -m 755 ./pcileech/files/pcileech $out/bin/
    install -m 644 ./MemProcFS/files/vmm.so $out/lib/
    install -m 644 ./LeechCore/files/leechcore.so $out/lib/
    install -m 644 ./plugins/files/leechcore_device_qemu.so $out/lib/
    install -m 644 ./plugins/files/leechcore_device_qemupcileech.so $out/lib/
    runHook postInstall
  '';

}