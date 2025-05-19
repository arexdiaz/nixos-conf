final: prev:
let
  edk2Version = "202502";
  hyphantom = prev.fetchFromGitHub {
    owner = "Scrut1ny";
    repo = "Hypervisor-Phantom";
    rev = "c1ded2dff0724e5f4c4a8a79cd8105eef0cd24d7";
    sha256 = "sha256-uxfvNRCw/AZXYI7mH4fbzqohpQ9hMYIox8d75x6BLAc=";
  };
  patchDir = "${hyphantom}/Hypervisor-Phantom/patches/";
  edk2SecureBootUtilScript = pkgs: ''
    #!${pkgs.bash}/bin/bash

    # Helper for formatting text
    TEXT_BRIGHT_YELLOW='\033[1;33m'
    TEXT_BRIGHT_RED='\033[1;31m'
    TEXT_RESET='\033[0m'

    log_info() { echo -e "''${TEXT_BRIGHT_YELLOW}[INFO]''${TEXT_RESET} $1"; }
    log_error() { echo -e "''${TEXT_BRIGHT_RED}[ERROR]''${TEXT_RESET} $1"; }
    log_fatal() { echo -e "''${TEXT_BRIGHT_RED}[FATAL]''${TEXT_RESET} $1"; exit 1; }
    ask_prompt() { echo -en "''${TEXT_BRIGHT_YELLOW}[PROMPT]''${TEXT_RESET} $1"; }

    cert_injection_main() {
        local UUID
        local TEMP_DIR
        local VM_NAME
        local VARS_FILE
        # This path is a common default. User might need to ensure it's correct for their system.
        local NVRAM_DIR="/var/lib/libvirt/qemu/nvram"

        if ! command -v sudo &> /dev/null; then
            log_error "sudo command not found. This script requires sudo to interact with libvirt and modify system files."
            exit 1
        fi

        TEMP_DIR=$(${pkgs.coreutils}/bin/mktemp -d)
        # shellcheck disable=SC2064 # We want $TEMP_DIR to expand now for the trap
        trap 'log_info "Cleaning up $TEMP_DIR..."; ${pkgs.coreutils}/bin/rm -rf "$TEMP_DIR"' EXIT
        cd "$TEMP_DIR" || { log_error "Failed to cd into $TEMP_DIR"; exit 1; }

        log_info "Select the UUID type to use for Secure Boot:"
        echo -e "  ''${TEXT_BRIGHT_YELLOW}[1]''${TEXT_RESET} Randomly generated UUID"
        echo -e "  ''${TEXT_BRIGHT_YELLOW}[2]''${TEXT_RESET} UEFI Global Variable UUID (EFI_GLOBAL_VARIABLE)"
        echo -e "  ''${TEXT_BRIGHT_YELLOW}[3]''${TEXT_RESET} Microsoft Vendor UUID (Microsoft Corporation)"
        echo -e "\n  ''${TEXT_BRIGHT_RED}[0]''${TEXT_RESET} Exit"

        local uuid_choice
        ask_prompt "Enter choice [0-3]: "
        read -r uuid_choice
        case "$uuid_choice" in
          0) log_info "Exiting."; exit 0 ;;
          1) UUID=$(${pkgs.util-linux}/bin/uuidgen) ;;
          2) UUID="8be4df61-93ca-11d2-aa0d-00e098032b8c" ;;
          3) UUID="77fa9abd-0359-4d32-bd60-28f4e78f784b" ;;
          *) log_error "Invalid choice. Defaulting to random UUID."; UUID=$(${pkgs.util-linux}/bin/uuidgen) ;;
        esac
        log_info "Using UUID: $UUID"

        log_info "Downloading Microsoft Secure Boot certificates..."
        declare -a URLS=(
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/PK/Certificate/WindowsOEMDevicesPK.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/KEK/Certificates/MicCorKEKCA2011_2011-06-24.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/KEK/Certificates/microsoft%20corporation%20kek%202k%20ca%202023.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/DB/Certificates/MicCorUEFCA2011_2011-06-27.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/DB/Certificates/MicWinProPCA2011_2011-10-19.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/DB/Certificates/microsoft%20option%20rom%20uefi%20ca%202023.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/DB/Certificates/microsoft%20uefi%20ca%202023.der"
          "https://raw.githubusercontent.com/microsoft/secureboot_objects/main/PreSignedObjects/DB/Certificates/windows%20uefi%20ca%202023.der"
          "https://uefi.org/sites/default/files/resources/dbxupdate_x64.bin"
        )

        for url in "''${URLS[@]}"; do
          log_info "Downloading $url"
          if ! ${pkgs.curl}/bin/curl -sOL "$url"; then
            log_error "Failed to download $url. Please check your internet connection and the URL."
          fi
        done

        log_info "Converting .der to .pem certs..."
        for der in *.der; do
          if [ -f "$der" ]; then # Check if file exists, in case download failed
            pem="''${der%.der}.pem"
            log_info "Converting $der to $pem"
            if ! ${pkgs.openssl}/bin/openssl x509 -inform der -in "$der" -out "$pem"; then
              log_error "Failed to convert $der"
            fi
          fi
        done

        log_info "Available libvirt domains (requires sudo for virsh):"; echo ""
        # shellcheck disable=SC2207 # Word splitting is intended here
        VMS=($(sudo ${pkgs.libvirt}/bin/virsh list --all --name))
        if [ ''${#VMS[@]} -eq 0 ]; then
          log_fatal "No VMs found or sudo virsh failed! Ensure libvirtd service is running and you have permissions."
        fi

        for i in "''${!VMS[@]}"; do
          index=$((i + 1))
          echo -e "  ''${TEXT_BRIGHT_YELLOW}[$index]''${TEXT_RESET}  ''${VMS[$i]}"
        done
        echo -e "\n  ''${TEXT_BRIGHT_RED}[0]''${TEXT_RESET}  Cancel"

        local vm_choice
        while true; do
          ask_prompt "Enter your choice [0-''${#VMS[@]}]: "
          read -r vm_choice
          if [[ "$vm_choice" == "0" ]]; then
            log_info "Exiting Secure Boot setup."
            return
          elif [[ "$vm_choice" =~ ^[0-9]+$ ]] && (( vm_choice >= 1 && vm_choice <= ''${#VMS[@]} )); then
            VM_NAME="''${VMS[$((vm_choice - 1))]}"
            # Original script used _SECURE_VARS.qcow2. This script assumes that or a similar qcow2/fd file.
            VARS_FILE="$NVRAM_DIR/''${VM_NAME}_SECURE_VARS.qcow2" # Or adjust if your VM uses a different name like _VARS.fd

            if [ ! -f "$VARS_FILE" ]; then
                log_error "VARS File not found: $VARS_FILE"
                log_info "This script expects the QEMU VARS file (e.g., OVMF_VARS.fd, or a qcow2 like ''${VM_NAME}_SECURE_VARS.qcow2) for your VM to exist at this path."
                log_info "You may need to locate your VM's actual VARS file and either use that path, or copy/rename it for this script."
                log_info "Commonly, libvirt stores these in $NVRAM_DIR/<vm_name>_VARS.fd or similar."
                log_info "If you are setting up Secure Boot for the first time on this VARS file, it might be a copy of a clean OVMF_VARS.fd template."
                continue # Allow user to re-select or fix the issue
            fi
            log_info "Using $VARS_FILE as the base VARS file."
            break
          else
            log_error "Invalid selection, please try again."
          fi
        done

        log_info "Injecting Secure Boot certs into $VARS_FILE..."
        local output_vars_file="$VARS_FILE.new-secureboot" # Create a new file first

        log_info "The following command will be run with sudo using virt-fw-vars:"
        # Display the command clearly
        # Note: filenames with spaces like "microsoft corporation kek 2k ca 2023.pem" are handled by shell quoting.
        echo "sudo ${pkgs.virt-manager}/bin/virt-fw-vars \\"
        echo "  --input \"$VARS_FILE\" \\"
        echo "  --output \"$output_vars_file\" \\"
        echo "  --secure-boot \\"
        echo "  --set-pk \"$UUID\" \"WindowsOEMDevicesPK.pem\" \\"
        echo "  --add-kek \"$UUID\" \"MicCorKEKCA2011_2011-06-24.pem\" \\"
        echo "  --add-kek \"$UUID\" \"microsoft corporation kek 2k ca 2023.pem\" \\"
        echo "  --add-db \"$UUID\" \"MicCorUEFCA2011_2011-06-27.pem\" \\"
        echo "  --add-db \"$UUID\" \"MicWinProPCA2011_2011-10-19.pem\" \\"
        echo "  --add-db \"$UUID\" \"microsoft option rom uefi ca 2023.pem\" \\"
        echo "  --add-db \"$UUID\" \"microsoft uefi ca 2023.pem\" \\"
        echo "  --add-db \"$UUID\" \"windows uefi ca 2023.pem\" \\"
        echo "  --set-dbx dbxupdate_x64.bin"

        if sudo ${pkgs.virt-manager}/bin/virt-fw-vars \
          --input "$VARS_FILE" \
          --output "$output_vars_file" \
          --secure-boot \
          --set-pk "$UUID" "WindowsOEMDevicesPK.pem" \
          --add-kek "$UUID" "MicCorKEKCA2011_2011-06-24.pem" \
          --add-kek "$UUID" "microsoft corporation kek 2k ca 2023.pem" \
          --add-db "$UUID" "MicCorUEFCA2011_2011-06-27.pem" \
          --add-db "$UUID" "MicWinProPCA2011_2011-10-19.pem" \
          --add-db "$UUID" "microsoft option rom uefi ca 2023.pem" \
          --add-db "$UUID" "microsoft uefi ca 2023.pem" \
          --add-db "$UUID" "windows uefi ca 2023.pem" \
          --set-dbx dbxupdate_x64.bin; then
          log_info "virt-fw-vars command successful."
          log_info "The new VARS file with Secure Boot keys is at: $output_vars_file"
          log_info "You may need to update your VM configuration to use this new VARS file."
          ask_prompt "Do you want to attempt to replace $VARS_FILE with $output_vars_file? (y/N): "
          read -r replace_choice
          if [[ "$replace_choice" =~ ^[Yy]$ ]]; then
            if sudo ${pkgs.coreutils}/bin/mv "$output_vars_file" "$VARS_FILE"; then
              log_info "Successfully replaced $VARS_FILE."
              log_info "Ensure your VM is configured to use $VARS_FILE for its NVRAM store."
            else
              log_error "Failed to replace $VARS_FILE. The new file is still at $output_vars_file."
            fi
          else
            log_info "Original file $VARS_FILE was not modified. New file is at $output_vars_file."
          fi
        else
          log_error "virt-fw-vars command failed. Check output for details."
          log_error "Temporary files are in $TEMP_DIR. Output file $output_vars_file may be incomplete or missing."
        fi
        log_info "Script finished. Temporary directory $TEMP_DIR will be cleaned up on exit."
    }

    cert_injection_main
  '';
in {
  edk2 = prev.edk2.overrideAttrs (oldAttrs: rec{
    pname = "${oldAttrs.pname}-patched";
    version = "${edk2Version}";
    
    srcWithVendoring = prev.fetchFromGitHub {
      owner = "tianocore";
      repo = "edk2";
      rev = "edk2-stable${version}";
      fetchSubmodules = true;
      sha256 = "sha256-iobC0CeWSylS9sLuXOqAmL36hl/tY+IedT/I3xQ80Ag=";
    };
    
    nativeBuildInputs = (oldAttrs.nativeBuildInputs) ++ [];

    src = prev.applyPatches {
      name = "edk2-${version}-custom-src";
      src = srcWithVendoring;

      patches = (oldAttrs.src.patches) ++ [
        "${patchDir}/EDK2/intel-edk2-stable202502.patch"
      ];
    };
    # postInstall = (oldAttrs.postInstall or "") + ''
    #   mkdir -p $out/bin
    #   local script_path=$out/bin/edk2-secureboot-tool
    #   # Write the script content to the file
    #   # Note: prev is passed as pkgs to edk2SecureBootUtilScript
    #   cat > $script_path <<EOF
    #   ${edk2SecureBootUtilScript prev}
    #   EOF
    #   chmod +x $script_path

    #   # Wrap the script to make dependencies available in PATH
    #   wrapProgram $script_path \
    #     --prefix PATH : ${prev.lib.makeBinPath [
    #       prev.coreutils
    #       prev.curl
    #       prev.openssl
    #       prev.libvirt # for virsh
    #       prev.virt-manager # for virt-fw-vars
    #       prev.util-linux # for uuidgen
    #       prev.bash # bash itself for running the script
    #     ]}
    # '';
  });
}