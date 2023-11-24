{
  description = "Maru's NixOS config flake";
      
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
  };
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          (import home-manager.nixosModules.home-manager)
          {
            home-manager.extraSpecialArgs = { inherit unstable; };
          }
        ];
      };
    };
  };
}
