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
      nixosModules = rec {

        lawful = import ./1-lawful.nix {
          inherit pkgs lib;
        };

        neutral = import ./2-neutral.nix {
          inherit pkgs lib lawful;
        };

        chaotic = import ./3-chaotic.nix {
          inherit pkgs lib neutral;
        };

        default = throw "Use one of lawful, neutral, chaotic. Lower tiers are included in higher tiers.";
      };
    };
}
