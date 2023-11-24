{ config, pkgs, ... }:

{
  imports = [
    "${builtins.fetchTarball { 
      url = "https://github.com/nix-community/disko/archive/master.tar.gz";
      sha256 = "sha256-LD+PIUbm1yQmQmGIbSsc/PB1dtJtGqXFgxRc1C7LlfQ=";
    }}/module.nix"
    ./disko-config.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Argentina/Cordoba";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_AR.UTF-8";
    LC_IDENTIFICATION = "es_AR.UTF-8";
    LC_MEASUREMENT = "es_AR.UTF-8";
    LC_MONETARY = "es_AR.UTF-8";
    LC_NAME = "es_AR.UTF-8";
    LC_NUMERIC = "es_AR.UTF-8";
    LC_PAPER = "es_AR.UTF-8";
    LC_TELEPHONE = "es_AR.UTF-8";
    LC_TIME = "es_AR.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Use systemd-boot as my bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # grahamc's "Erase your darlings" implemented for Btrfs. Thanks accelbread and oposs for the help
  boot.initrd.postResumeCommands = ''
    mkdir -vp /tmp
    MNTDIR=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/mapper/vda-opened "$MNTDIR"
      trap 'umount "$MNTDIR"; rm -rf $MNTDIR' EXIT

      echo "Creating needed directories"
      mkdir -vp "$MNTDIR"/persist/etc/nixos

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTDIR/fsroot" | cut -f9 -d ' ' |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTDIR/$subvolume"
      done && btrfs subvolume delete "$MNTDIR/fsroot"

      echo "Restoring blank subvolume"
      btrfs subvolume create "$MNTDIR/fsroot"
    )
  '';

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts = {
    fonts = with pkgs; [
      # icon fonts
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # nerdfonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];

    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    # fontconfig.defaultFonts = {
    #   serif = [ "Noto Serif" "Noto Color Emoji" ];
    #   sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    #   monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
    #   emoji = [ "Noto Color Emoji" ];
    # };
  };

  programs.dconf.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";         # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    hyfetch
    xfce.thunar  # xfce4's file manager
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.power-profiles-daemon = {
    enable = true;
  };
  security.polkit.enable = true;

  services = {
    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };

  users.mutableUsers = false;

  # Set the root password so we don't get screwed by our stateless system lol
  users.users.root.password = "1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.maru = {
    isNormalUser  = true;
    description  = "Maruwu";
    extraGroups  = [ "wheel" ];
    password = "1";
    uid = 1000;
    openssh.authorizedKeys.keys = [
        "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBE7BnQWE73D27wBYI9n1gvmftCMKbvGo27j/beAj65O+64Oh1T50MhT4Jnwa5xRufuYgGqVvjPDGkqkQe3UXgXYAAAAEc3NoOg== clear6860@tutanota.com"
    ];
  };
}