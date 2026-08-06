# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Executable:  nix (Flakes enabled)
# Source:      nixpkgs (nixos-unstable), home-manager, nixgl

{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixgl }@inputs:
    let
      user = "kuba";
      system = "x86_64-linux";
    in
    {
      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit user nixgl; };
        modules = [
          ./home.nix
        ];
      };
    };
}
