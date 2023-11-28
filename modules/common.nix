{ config, pkgs, ... }:

let
  system = import ./settings/system.nix { inherit config pkgs; };
  user = import ./settings/user.nix { inherit config pkgs; };
in
{
  imports = [
    "${builtins.fetchTarball { 
      url = "https://github.com/nix-community/disko/archive/master.tar.gz";
      sha256 = "sha256-LD+PIUbm1yQmQmGIbSsc/PB1dtJtGqXFgxRc1C7LlfQ=";
    }}/module.nix"
    ./disko-config.nix
    ./opt-in.nix
  ];

  system = system;
  user = user;

  # Set your time zone.
  time.timeZone = "${system.timeZone}";

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

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts = {
    packages = with pkgs; [
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
    enableDefaultPackages = false;

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

  # Set the root password so we don't get screwed by our stateless system lol
  users.users.root.password = "1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users."${user.username}" = {
    isNormalUser  = true;
    description  = "Maruwu";
    extraGroups  = [ "wheel" ];
    password = "1";
    uid = 1000;
    # TODO: Move this to modules/settings
    openssh.authorizedKeys.keys = [
        "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBE7BnQWE73D27wBYI9n1gvmftCMKbvGo27j/beAj65O+64Oh1T50MhT4Jnwa5xRufuYgGqVvjPDGkqkQe3UXgXYAAAAEc3NoOg== clear6860@tutanota.com"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnw1jM9dmXiYjg3zZxIik2tbC+GgHoI7f8iahPYm3ACW7EUIC1yy0sx3wP8uElshioLegAQ/dY6hooLx+G32gOP13uRHd2fPRX6XuTOhNkY1C1tG0b9SHUSqi4ihzSrvvarUV+2el7rirEKbXbKmaY8cScA7JwijUSeGqrtHslQIVCWbYu7Bz/waacmQPFDIDAzm8uo3VxMYQ3pJxy+vvgmtSPfoPTBxgfJl72a+x74IejjXeq35tJKQZ+BohBREYjmwfmvmY0X4wgQ0Q4cLyUWFgMYahhNTqISet4PlKtk4Wge7J5AIL/8kWH0EoiZeoc13zXjNDIg1+vg880rIJDpFzS9Vu9OfgQTliKfNezlDrMmNc6HMD5lqRrBVOu5TeNoJC+a2yVxgbeCn+uTIEh6RDt2/gy+sDdGjbvWzcr4c5hXoasU5qqaUINq2MR6gGwIBXOdHkNLPh9ZzcKhuzFK7/BBrdEDIHoYenXpPkrxjW9CCXcjXfZtdyv39ylNf8= maru@nixos"
    ];
  };
}