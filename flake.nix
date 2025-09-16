{
  description = "Ensmallen your NixOS system!";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
    in
    {
      nixosModules.default = import ./combined.nix {
        inherit pkgs lib;
      };
    };
}
