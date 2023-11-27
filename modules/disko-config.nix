{ config, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${system.disk}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "main-opened";
                passwordFile = "/tmp/secret.key"; # Interactive
                settings.allowDiscards = true;
                extraFormatArgs = [
                  "--cipher serpent-xts-plain64"
                  "--key-size 512"
                  "--iter-time 10000"
                  #"--hash whirlpool"
                  "--label vda-crypt"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "--label vda" ];
                  subvolumes = {
                    "/fsroot" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "20M";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
