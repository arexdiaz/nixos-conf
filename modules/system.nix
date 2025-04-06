{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Puerto_Rico";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
  };

  # Bootloader configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true; };
    
    # Load OverlayFS kernel module (required for OverlayFS)
    kernelModules = [ "overlay" "i2c-dev" "i2c-i801" ];
  };

  hardware = {
    # Enable Bluetooth
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };
}