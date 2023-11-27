{ config, lib, ... }: {
  options = {
    disk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/vda";
      description = "Disk where NixOS should be installed at";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "vm";
      description = "Hostname for your system";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Argentina/Cordoba";
      description = "Timezone for your system";
    };
  };
}