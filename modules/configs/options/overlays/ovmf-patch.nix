final: prev:
let
  edk2Version = "202505";

  patchDir = "${prev.fetchFromGitHub {
    owner = "Scrut1ny";
    repo = "Hypervisor-Phantom";
    rev = "18e67df0791c5c912d3eacab1ba8f2edd83fa43f";
    sha256 = "sha256-nHIzcb7qCQlD2v8Rwx4uL18fPDepw5ly94DNiyv/ZkY=";
  }}/Hypervisor-Phantom/patches/";

  pythonEnv = prev.buildPackages.python3.withPackages (ps: [ ps.tkinter ]);
  targetArch =
    if prev.stdenv.hostPlatform.isi686 then "IA32"
    else if prev.stdenv.hostPlatform.isx86_64 then "X64"
    else if prev.stdenv.hostPlatform.isAarch32 then "ARM"
    else if prev.stdenv.hostPlatform.isAarch64 then "AARCH64"
    else if prev.stdenv.hostPlatform.isRiscV64 then "RISCV64"
    else if prev.stdenv.hostPlatform.isLoongArch64 then "LOONGARCH64"
    else throw "Unsupported architecture";
  buildType = if prev.stdenv.hostPlatform.isDarwin then "CLANGPDB" else "GCC5";

  edk2 = prev.edk2.overrideAttrs (oldEdk2Attrs: rec {
    version = edk2Version;
    
    passthru = oldEdk2Attrs.passthru // {
      tests.uefiUsb = oldEdk2Attrs.passthru.tests.uefiUsb;
      updateScript = oldEdk2Attrs.passthru.updateScript;
      mkDerivation = projectDscPath: attrsOrFun:
        prev.stdenv.mkDerivation (
          finalAttrs:
          let
            attrs = prev.lib.toFunction attrsOrFun finalAttrs;
          in
          {
            src = oldEdk2Attrs.src.overrideAttrs (oldApplyPatchesAttrs: {
              name = "edk2-${version}-unvendored-src";
              src = prev.fetchFromGitHub {
                owner = "tianocore";
                repo = "edk2";
                rev = "edk2-stable${edk2Version}";
                fetchSubmodules = true;
                sha256 = "sha256-VuiEqVpG/k7pfy0cOC6XmY+8NBtU/OHdDB9Y52tyNe8=";
              };

              patches = (oldApplyPatchesAttrs.patches or []) ++ [
                "${patchDir}/EDK2/intel-edk2-stable${edk2Version}.patch"
              ];

              postPatch = '' # openssl_3 gave me a huge migrane
                # We don't want EDK2 to keep track of OpenSSL, they're frankly bad at it.
                rm -r CryptoPkg/Library/OpensslLib/openssl
                mkdir -p CryptoPkg/Library/OpensslLib/openssl
                (
                  cd CryptoPkg/Library/OpensslLib/openssl
                  tar --strip-components=1 -xf ${prev.buildPackages.openssl.src}

                  ${prev.lib.pipe prev.buildPackages.openssl.patches [
                    (builtins.filter (
                      patch:
                      !builtins.elem (baseNameOf patch) [
                        # Exclude patches not required in this context.
                        "nix-ssl-cert-file.patch"
                        "openssl-disable-kernel-detection.patch"
                        "use-etc-ssl-certs-darwin.patch"
                        "use-etc-ssl-certs.patch"
                      ]
                    ))
                    (map (patch: "patch -p1 < ${patch}\n"))
                    prev.lib.concatStrings
                  ]}
                )

                # enable compilation using Clang
                # https://bugzilla.tianocore.org/show_bug.cgi?id=4620
                substituteInPlace BaseTools/Conf/tools_def.template --replace-fail \
                  'DEFINE CLANGPDB_WARNING_OVERRIDES    = ' \
                  'DEFINE CLANGPDB_WARNING_OVERRIDES    = -Wno-unneeded-internal-declaration '
              '';
            });

            depsBuildBuild = [ prev.buildPackages.stdenv.cc ] ++ (attrs.depsBuildBuild or []);
            nativeBuildInputs = [ prev.bc pythonEnv ] ++ (attrs.nativeBuildInputs or []);
            strictDeps = true;

            ${"GCC5_${targetArch}_PREFIX"} = prev.stdenv.cc.targetPrefix;

            prePatch = ''
              rm -rf BaseTools
              ln -sv ${prev.buildPackages.edk2}/BaseTools BaseTools
            '';

            configurePhase = ''
              runHook preConfigure
              export WORKSPACE="$PWD"
              . ${prev.buildPackages.edk2}/edksetup.sh BaseTools
              runHook postConfigure
            '';

            buildPhase = ''
              runHook preBuild
              build -a ${targetArch} -b ${attrs.buildConfig or "RELEASE"} -t ${buildType} -p ${projectDscPath} -n $NIX_BUILD_CORES $buildFlags
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mv -v Build/*/* $out
              runHook postInstall
            '';
          }
          // prev.lib.removeAttrs attrs [
            "nativeBuildInputs"
            "depsBuildBuild"
          ]
        );
    };
  });
in {
  OVMF = final.callPackage (prev.path + "/pkgs/applications/virtualization/OVMF/default.nix") {
    stdenv = prev.stdenv;
    edk2 = edk2;
    pexpect = prev.pexpect or final.pexpect;
  };
}
