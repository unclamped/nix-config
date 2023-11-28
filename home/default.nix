{ config, pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  home = {
    username = "${user.username}";
    homeDirectory = "/home/${user.username}";
    stateVersion = "23.05";
  };

  programs.git = {
    enable = true;
    userName = "${user.gitUsername}";
    userEmail = "${user.gitEmail}";
  };

  programs.home-manager.enable = true;
}