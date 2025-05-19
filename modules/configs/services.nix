{ ... }:

{
  services = {
    sysprof.enable = true;

    # Enable profile-sync-daemon service
    psd.enable = true;
    psd.resyncTimer = "10m";
    
    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # xserver.libinput.enable = true;

    # Enable the OpenSSH daemon.
    # openssh.enable = true;
  };

  # Required for pipewire
  security.rtkit.enable = true;
}
