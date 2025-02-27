{ config, pkgs, ...}:

{
  services = {
    # Enable profile-sync-daemon service
    psd.enable = true;
    psd.resyncTimer = "10m";

    # Scx scheduler config
    scx = {
      package = pkgs.scx_git.full;
      scheduler = "scx_bpfland";
      enable = true;
    };

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    xserver.enable = true;

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