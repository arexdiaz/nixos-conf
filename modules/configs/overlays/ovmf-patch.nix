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
    __intentionallyOverridingVersion = true;

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
              
              # FIX: Removed the entire OpenSSL replacement logic. The build will now
              # use the vendored OpenSSL source from EDK2, which is what the
              # build system expects.
              postPatch = ''
                # enable compilation using Clang
                # https://bugzilla.tianocore.org/show_bug.cgi?id=4620
                substituteInPlace BaseTools/Conf/tools_def.template --replace-fail \
                  'DEFINE CLANGPDB_WARNING_OVERRIDES    = ' \
                  'DEFINE CLANGPDB_WARNING_OVERRIDES    = -Wno-unneeded-internal-declaration '

                cp -f "${patchDir}/EDK2/Logo.bmp" "MdeModulePkg/Logo/Logo.bmp"
              '';
            });

            depsBuildBuild = [ prev.buildPackages.stdenv.cc ] ++ (attrs.depsBuildBuild or []);
            nativeBuildInputs = [ prev.bc pythonEnv ] ++ (attrs.nativeBuildInputs or []);
            strictDeps = true;

            ${"GCC5_${targetArch}_PREFIX"} = prev.stdenv.cc.targetPrefix;

            prePatch = ''
              rm -rf BaseTools
              cp -r ${prev.buildPackages.edk2}/BaseTools ./BaseTools
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
  OVMF = let
    # Step 1: Call the original OVMF package with your custom edk2
    unpatchedOVMF = final.callPackage (prev.path + "/pkgs/applications/virtualization/OVMF/default.nix") {
      stdenv = prev.stdenv;
      edk2 = edk2;
      # Change this line
      pexpect = final.python3Packages.pexpect;
    };

    # Step 2: Override the initial arguments for Secure Boot
    configuredOVMF = unpatchedOVMF.override {
      secureBoot = true;
      msVarsTemplate = true;
    };

  # Step 3: Override the final attributes to add the openssl build input
  in configuredOVMF.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ final.openssl ];
  });

}