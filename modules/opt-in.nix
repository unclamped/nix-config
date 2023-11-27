{
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

  users.mutableUsers = false;

  security.sudo.extraConfig = "Defaults lecture=\"never\"";

  # TODO: Impermanence
}