{ config, ... }:

{
  # grahamc's "Erase your darlings" implemented for Btrfs. Thanks accelbread and oposs for the help
  boot.initrd.postResumeCommands = ''
    mkdir -vp /tmp
    MNTDIR=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/mapper/${config.system.disk}-opened "$MNTDIR"
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

  users.mutableUsers = false;

  # FIXME: For some reason this doesn't work!
  security.sudo.extraConfig = "Defaults lecture=\"never\"";

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
    users."${config.user.username}" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".nixops"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/share/direnv"
      ];
      files = [
        ".screenrc"
      ];
    };
  };
}