{
  pkgs,
  lib,
  neutral,
}:
with neutral;

# Experimental tweaks for which
# I recommend you know what you're doing!

{

  # ---------------------------------- \
  # The NixOS installer tools depend on  \
  # a specific version of nix. Remove most \
  # of them, except for rebuild. To add one  \
  # back, add it to environment.systemPackages \
  # -------------------------------------------- \

  system.disableInstallerTools = lib.mkForce true;

  # This is about all the ^ option does.
  environment.systemPackages = with pkgs; [
    # nixos-build-vms
    # nixos-enter
    # nixos-generate-config
    # nixos-install
    # nixos-option
    nixos-rebuild-ng # Keep this one
    # nixos-version
  ];

  nixpkgs.config = {
    
    # Allowing aliases means nixpkgs will import a module
    # called aliases.nix, in which old versions of packages
    # get either aliased to new ones, or given an error
    # with the required changes. May require updating configs.
    allowAliases = false;

    # > Variants are instances of the current nixpkgs instance
    # > with different stdenvs or other applied options.
    # > This allows for using different toolchains, libcs, or
    # > global build changes across nixpkgs. Disabling can ensure
    # > nixpkgs is only building for the platform which you specified.
    #
    # I don't exactly (care to) understand what that means,
    # but maybe has some effect.
    allowVariants = false;
  };

  # An attempt to reduce eval time similar to what allowAliases
  # does for packages, by not parsing all these options found
  # all throughout nixpkgs.
  lib = lib // {
    mkAliasOptionModule = (_: null);
    mkMergedOptionModule = (_: null);
    mkChangedOptionModule = (_: null);
    mkRemovedOptionModule = (_: null);
    mkRenamedOptionModule = (_: null);
  };

  # Oh this is a good one
  hardware = {
    firmware = with pkgs; [

      # The firmware package is huge, and contains firmware
      # for all devices that Linux has ever supported.
      #
      # Until I bother to find a method to detect and separate
      # only the required firmware for a given device,
      # the only method is to disable it and see what breaks.
      # 
      # sudo journalctl -b -1 | rg "Direct firmware load for"
      #
      # Use this to find what's missing. "-b -1" for the
      # previous boot if it fails, "-b" otherwise.
      #
      linux-firmware

      # The following firmware packages are redistributable and
      # considered useful enough to install by (almost) default.

      # intel2200BGFirmware
      # rtl8192su-firmware
      # rt5677-firmware
      # rtl8761b-firmware
      # zd1211fw
      # alsa-firmware
      # sof-firmware
      # libreelec-dvb-firmware

      # And those are for the people who thought "enable"
      # means enable, not "install something else".
      # FaceTime camera calibration‽ come on.

      # broadcom-bt-firmware
      # b43Firmware_5_1_138
      # b43Firmware_6_30_163_46
      # xow_dongle-firmware
      # facetimehd-calibration
      # facetimehd-firmware

      # Keep this one. Or don't, I'm not your father.
      wireless-regdb
    ];

    enableAllFirmware = FALSE;
    enableRedistributableFirmware = FALSE;
  };

  # Too much; maybe on servers?
  # fonts.fontconfig = DISABLE;

  # Also too much
  # programs.xwayland = DISABLE;
}
