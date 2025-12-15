{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "arexdiaz";
      email = "arexito@icloud.com";
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      font = let meslo = "MesloLGS NF"; in {
        normal = {
          family = meslo;
          style = "Regular";
        };
        bold = {
          family = meslo;
          style = "Bold";
        };
        italic = {
          family = meslo;
          style = "Italic";
        };
        bold_italic = {
          family = meslo;
          style = "Bold Italic";
        };
        size = 12.0;
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = "1";
    gtk4.extraConfig."gtk-application-prefer-dark-theme" = "1";
  };

  home = {
    username = "rx";
    homeDirectory = "/home/rx";
    
    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/rx/etc/profile.d/hm-session-vars.sh
    sessionVariables = { };

    packages = [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # Setting psd.conf content immediately.
      ".config/psd/psd.conf".text = ''
        USE_OVERLAYFS="yes"
      '';

      ".config/autostart/ulauncher.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Exec=ulauncher --hide-window
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
        Name=Ulauncher
        Comment=Application launcher
      '';

      ".local/share/konsole/Meslo.profile".text = ''
        [Appearance]
        ColorScheme=Breeze
        Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0

        [General]
        Name=Meslo
        Parent=FALLBACK/

        [Scrolling]
        HistoryMode=2
      '';

      ".config/konsolerc".text = ''
        [Desktop Entry]
        DefaultProfile=Meslo.profile
      '';

      ".config/yakuakerc".text = ''
        [Appearance]
        Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0

        [General]
        DefaultProfile=Meslo.profile
      '';
    };

    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
