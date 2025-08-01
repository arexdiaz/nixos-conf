final: prev:
let
  qemuVersion = "10.0.0";

  hyphantom = prev.fetchFromGitHub {
    owner = "Scrut1ny";
    repo = "Hypervisor-Phantom";
    rev = "18e67df0791c5c912d3eacab1ba8f2edd83fa43f";
    sha256 = "sha256-nHIzcb7qCQlD2v8Rwx4uL18fPDepw5ly94DNiyv/ZkY=";
  };
  rxpatches = prev.fetchFromGitHub {
    owner = "arexdiaz";
    repo = "patches";
    rev = "78d9dc4ada018f26276106108fdc59568d879204";
    sha256 = "sha256-Hs5HpuWN1biHWnPcKXP5YNVWhbT/Z+AryurXaO00Ino=";
  };
  patchDir = "${hyphantom}/Hypervisor-Phantom/patches/";
in {
  qemu = prev.qemu.overrideAttrs (oldAttrs: rec {

    pname = "${oldAttrs.pname}";
    version = "${qemuVersion}";

    src = prev.fetchurl {
      url = "https://download.qemu.org/qemu-${qemuVersion}.tar.xz";
      sha256 = "sha256-IsB1YB/c+MeyZxqDnr3O8dTylz62c1JU/S4b0PMLOJY=";
    };

    patches = (oldAttrs.patches) ++ [
      "${rxpatches}/qemu-10.0-pcileech.patch"
      "${rxpatches}/qemu-osi.patch"
      "${patchDir}/QEMU/intel-qemu-${qemuVersion}.patch"
      "${patchDir}/QEMU/qemu-${qemuVersion}-libnfs6.patch"
    ];

    nativeBuildInputs = (oldAttrs.nativeBuildInputs) ++ [
      prev.coreutils
      prev.gnugrep
      prev.gnused
      prev.dmidecode
      prev.findutils
      prev.bash
    ];

    postPatch = (oldAttrs.postPatch) + ''
      readonly CPU_VENDOR="intel"
      readonly QEMU_VERSION="${qemuVersion}"
      readonly pm_type=1
      readonly chassis_type="Desktop"

      spoof_serial_numbers() {
        get_random_serial() { head /dev/urandom | tr -dc 'A-Z0-9' | head -c "$1"; }

        local patterns=("STRING_SERIALNUMBER" "STR_SERIALNUMBER" "STR_SERIAL_MOUSE" "STR_SERIAL_TABLET" "STR_SERIAL_KEYBOARD" "STR_SERIAL_COMPAT")
        local regex_pattern="($(IFS=\|; echo "''${patterns[*]}"))"

        find "$(pwd)/hw/usb" -type f -exec grep -lE "\[$regex_pattern\]" {} + | while read -r file; do
          tmpfile=$(mktemp)

          while IFS= read -r line; do
            if [[ $line =~ \[$regex_pattern\] ]]; then
              local new_serial="$(get_random_serial 10)"
              line=$(echo "$line" | sed -E "s/(\[$regex_pattern\] *= *\")[^\"]*/\1''${new_serial}/")
            fi
            echo "$line" >> "$tmpfile"
          done < "$file"

          mv "$tmpfile" "$file"
        done
      }

      spoof_drive_serial_number() {
        local core_file="$(pwd)/hw/ide/core.c"
        local new_serial="$(get_random_serial 15)"

        local ide_cd_models=(
          "HL-DT-ST BD-RE WH16NS60" "HL-DT-ST DVDRAM GH24NSC0"
          "HL-DT-ST BD-RE BH16NS40" "HL-DT-ST DVD+-RW GT80N"
          "HL-DT-ST DVD-RAM GH22NS30" "HL-DT-ST DVD+RW GCA-4040N"
          "Pioneer BDR-XD07B" "Pioneer DVR-221LBK" "Pioneer BDR-209DBK"
          "Pioneer DVR-S21WBK" "Pioneer BDR-XD05B" "ASUS BW-16D1HT"
          "ASUS DRW-24B1ST" "ASUS SDRW-08D2S-U" "ASUS BC-12D2HT"
          "ASUS SBW-06D2X-U" "Samsung SH-224FB" "Samsung SE-506BB"
          "Samsung SH-B123L" "Samsung SE-208GB" "Samsung SN-208DB"
          "Sony NEC Optiarc AD-5280S" "Sony DRU-870S" "Sony BWU-500S"
          "Sony NEC Optiarc AD-7261S" "Sony AD-7200S" "Lite-On iHAS124-14"
          "Lite-On iHBS112-04" "Lite-On eTAU108" "Lite-On iHAS324-17"
          "Lite-On eBAU108" "HP DVD1260i" "HP DVD640"
          "HP BD-RE BH30L" "HP DVD Writer 300n" "HP DVD Writer 1265i"
        )

        local ide_cfata_models=(
          "SanDisk Ultra microSDXC UHS-I" "SanDisk Extreme microSDXC UHS-I"
          "SanDisk High Endurance microSDXC" "SanDisk Industrial microSD"
          "SanDisk Mobile Ultra microSDHC" "Samsung EVO Select microSDXC"
          "Samsung PRO Endurance microSDHC" "Samsung PRO Plus microSDXC"
          "Samsung EVO Plus microSDXC" "Samsung PRO Ultimate microSDHC"
          "Kingston Canvas React Plus microSD" "Kingston Canvas Go! Plus microSD"
          "Kingston Canvas Select Plus microSD" "Kingston Industrial microSD"
          "Kingston Endurance microSD" "Lexar Professional 1066x microSDXC"
          "Lexar High-Performance 633x microSDHC" "Lexar PLAY microSDXC"
          "Lexar Endurance microSD" "Lexar Professional 1000x microSDHC"
          "PNY Elite-X microSD" "PNY PRO Elite microSD"
          "PNY High Performance microSD" "PNY Turbo Performance microSD"
          "PNY Premier-X microSD" "Transcend High Endurance microSDXC"
          "Transcend Ultimate microSDXC" "Transcend Industrial Temp microSD"
          "Transcend Premium microSDHC" "Transcend Superior microSD"
          "ADATA Premier Pro microSDXC" "ADATA XPG microSDXC"
          "ADATA High Endurance microSDXC" "ADATA Premier microSDHC"
          "ADATA Industrial microSD" "Toshiba Exceria Pro microSDXC"
          "Toshiba Exceria microSDHC" "Toshiba M203 microSD"
          "Toshiba N203 microSD" "Toshiba High Endurance microSD"
        )

        local default_models=(
          "Samsung SSD 970 EVO 1TB" "Samsung SSD 860 QVO 1TB"
          "Samsung SSD 850 PRO 1TB" "Samsung SSD T7 Touch 1TB"
          "Samsung SSD 840 EVO 1TB" "WD Blue SN570 NVMe SSD 1TB"
          "WD Black SN850 NVMe SSD 1TB" "WD Green 1TB SSD"
          "WD Blue 3D NAND 1TB SSD" "Crucial P3 1TB PCIe 3.0 3D NAND NVMe SSD"
          "Seagate BarraCuda SSD 1TB" "Seagate FireCuda 520 SSD 1TB"
          "Seagate IronWolf 110 SSD 1TB" "SanDisk Ultra 3D NAND SSD 1TB"
          "Seagate Fast SSD 1TB" "Crucial MX500 1TB 3D NAND SSD"
          "Crucial P5 Plus NVMe SSD 1TB" "Crucial BX500 1TB 3D NAND SSD"
          "Crucial P3 1TB PCIe 3.0 3D NAND NVMe SSD"
          "Kingston A2000 NVMe SSD 1TB" "Kingston KC2500 NVMe SSD 1TB"
          "Kingston A400 SSD 1TB" "Kingston HyperX Savage SSD 1TB"
          "SanDisk SSD PLUS 1TB" "SanDisk Ultra 3D 1TB NAND SSD"
        )

        get_random_element() {
          local array=("$@")
          echo "''${array[RANDOM % ''${#array[@]}]}"
        }

        local new_ide_cd_model=$(get_random_element "''${ide_cd_models[@]}")
        local new_ide_cfata_model=$(get_random_element "''${ide_cfata_models[@]}")
        local new_default_model=$(get_random_element "''${default_models[@]}")

        sed -i "$core_file" -Ee "s/\"[^\"]*%05d\", s->drive_serial\);/\"''${new_serial}%05d\", s->drive_serial\);/"
        sed -i "$core_file" -Ee "s/\"HL-DT-ST BD-RE WH16NS60\"/\"''${new_ide_cd_model}\"/"
        sed -i "$core_file" -Ee "s/\"MicroSD J45S9\"/\"''${new_ide_cfata_model}\"/"
        sed -i "$core_file" -Ee "s/\"Samsung SSD 980 500GB\"/\"''${new_default_model}\"/"

      }

      spoof_acpi_table_data() {
        # Spoofs 'OEM ID' and 'OEM Table ID' for ACPI tables.

        local oem_pairs=(
          'DELL  ' 'Dell Inc' ' ASUS ' 'Notebook'
          'MSI NB' 'MEGABOOK' 'LENOVO' 'TC-O5Z  '
          'LENOVO' 'CB-01   ' 'SECCSD' 'LH43STAR'
          'LGE   ' 'ICL     '
        )

        if [[ "$CPU_VENDOR" == "amd" ]]; then
          oem_pairs+=('ALASKA' 'A M I ')
        elif [[ "$CPU_VENDOR" == "intel" ]]; then
          oem_pairs+=('INTEL ' 'U Rvp   ')
        fi

        local total_pairs=$(( ''${#oem_pairs[@]} / 2 ))
        local random_index=''$(( RANDOM % total_pairs * 2 ))
        local appname6=''${oem_pairs[''$random_index]}
        local appname8=''${oem_pairs[''$random_index + 1]}
        local h_file="$(pwd)/include/hw/acpi/aml-build.h"

        sed -i "$h_file" -e "s/^#define ACPI_BUILD_APPNAME6 \".*\"/#define ACPI_BUILD_APPNAME6 \"''${appname6}\"/"
        sed -i "$h_file" -e "s/^#define ACPI_BUILD_APPNAME8 \".*\"/#define ACPI_BUILD_APPNAME8 \"''${appname8}\"/"

        # Default QEMU has an unspecified PM type in the FACP ACPI table.
        # On baremetal normally vendors specify either 1 (Desktop) or 2 (Notebook).
        # We patch the PM type integer based on the chassis type output from dmidecode.

        echo "Obtaining machine's chassis-type..."

        local c_file="$(pwd)/hw/acpi/aml-build.c"
        # local pm_type="1" # Desktop
        # local chassis_type=$(sudo dmidecode --string chassis-type)


        sed -i 's/build_append_int_noprefix(tbl, 0 \/\* Unspecified \*\//build_append_int_noprefix(tbl, '"$pm_type"' \/\* '"$chassis_type"' \*\//g' "$c_file"
      }

      spoof_processor_manufacturer() {

        local chipset_file
        case "$QEMU_VERSION" in
          "8.2.6") chipset_file="$(pwd)/hw/i386/pc_q35.c" ;;
          "9.2.3"|"10.0.0") chipset_file="$(pwd)/hw/i386/fw_cfg.c" ;;
          *) echo "Unsupported QEMU version: $QEMU_VERSION" ;;
        esac

        local manufacturer=$(dmidecode --string processor-manufacturer)
        sed -i "$chipset_file" -e "s/smbios_set_defaults(\"[^\"]*\",/smbios_set_defaults(\"''${manufacturer}\",/"
      }

      spoof_serial_numbers
      spoof_drive_serial_number
      spoof_acpi_table_data
      spoof_processor_manufacturer
    '';
  });
}
