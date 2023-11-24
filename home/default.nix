{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "maru";
    homeDirectory = "/home/maru";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  programs.git = {
    enable = true;
    userName = "unclamped";
    userEmail = "clear6860@tutanota.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}