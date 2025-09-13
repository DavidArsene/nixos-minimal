# NixOS Minimal

Description

### Usage

You know the drill

```nix
inputs.nixos-minimal.follows = "github:me/this";

lib.nixosSystem {
	...
	modules = [
		nixos-minimal.nixosModules.{lawful,neutral,chaotic}
	];
}
```

Each tier includes the ones below.

Reading source code required.