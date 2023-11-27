{ config, lib, ... }: {
  options = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "maru";
      description = "Username for your user account";
    };
    gitUsername = lib.mkOption {
      type = lib.types.str;
      default = "unclamped";
      description = "Username for your git account";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "clear6860@tutanota.com";
      description = "Email for your git account";
    };
  };
}