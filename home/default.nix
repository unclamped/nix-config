{ config, pkgs, ... }:

{
  imports = [
    ./settings/user.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  home = {
    username = config.user.username;
    homeDirectory = "/home/${config.user.username}";
    stateVersion = "23.05";
  };

  programs.git = {
    enable = true;
    userName = config.user.gitUsername;
    userEmail = config.user.gitEmail;
  };

  programs.home-manager.enable = true;
}