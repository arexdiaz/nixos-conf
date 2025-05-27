{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.preconfs.pkgs.kernel.iommu.enable {
    programs = {
      fish = {
        interactiveShellInit = ''
          set -gx PCIDEVICES '[
            { "name": "GPU", "device": "10de:2489", "driver": "nvidia" },
            { "name": "GPU Audio", "device": "10de:228b", "driver": "snd_hda_intel" },
            { "name": "SSD", "device": "1b21:0612", "driver": "ahci" },
            { "name": "Wifi", "device": "8086:43f0", "driver": "iwlwifi" }]'
          '';

        shellAliases = lib.mkMerge [{
          vfio = "PATH=${pkgs.pciutils}/bin:$PATH ${(pkgs.python313.withPackages (ps: with ps; [ rich ]))}/bin/python ${./vfio.py}";
        }];
      };
    };
  };
}