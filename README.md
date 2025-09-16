# NixOS Minimal

Ensmallen your NixOS system!

### Usage

You know the drill

```nix
inputs.nixos-minimal.follows = "github:me/this";

lib.nixosSystem {
	# ...
	modules = [
		nixos-minimal.nixosModules.default

		{
			nixos.ensmallen.noAccessibility = true;
			# ...
			nixos.ensmallen.everything = true;
		}
	];
}
```

Reading source code strongly recommended.
