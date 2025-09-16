{
  pkgs,
  lib,
  config,
}:
let
  inherit (lib)
    mkDefault
    mkForce
    mkEnableOption
    ;

  cfg = config.nixos.ensmallen;

  # DISABLE yells to prevent your config
  # or nixpkgs from changing something.
  DISABLE = {
    enable = FALSE;
  };

  FALSE = mkForce false;

  # disable in lowercase is more of a chill guy,
  # he just suggests something be off by default,
  # but doesn't get in your way otherwise.

  disable = {
    enable = mkDefault false;
  };

  ifEnabled = opt: lib.mkIf (opt || cfg.everything);
in
{
  options.nixos.ensmallen = {
    minimalDefault = mkEnableOption "Opinionated sensible defaults" // {
      default = true;
    };

    everything = mkEnableOption "Everything this module has to offer";
    experimental = mkEnableOption "Works on my machine";

    noDocs = mkEnableOption "Disable documentation";

    plasma6deps = mkEnableOption "Disable some default programs included with Plasma 6." // {
      default = true;
      readOnly = true;
    };

    # TODO: better description
    noInstallerTools = mkEnableOption "Remove most NixOS installer tools for building VMs, installing new systems, etc.; nixos-rebuild is always kept.";

    noAccessibility =
      mkEnableOption "Disable accessibility services (screen readers, text-to-speech, etc.)"
      // {
        default = true;
      };
  };

  config =
    ifEnabled cfg.minimalDefault {
      # Enabled by desktop environments when needed
      xdg = {
        autostart = disable;
        icons = disable;
        mime = disable;
        sounds = disable;
      };

      environment = {
        # [ perl rsync strace ]
        defaultPackages = lib.mkForce [ ];

        stub-ld = disable;
      };

      programs = {
        # meh default or not
        fish.generateCompletions = mkDefault false;

        # use nix-community/nix-index-database
        command-not-found = DISABLE;

        # Other packages depend on normal git
        # anyway, so this is kinda useless.
        git.package = pkgs.gitMinimal;
      };

      # Modems? In the Year of our Lord ${year}?
      networking.modemmanager = DISABLE;

      # Keyboard still works so /shrug
      # Maybe on-screen-keyboard / CJK something
      i18n.inputMethod = DISABLE;

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

      # Not related but has the same vibe
      boot.tmp = {
        useTmpfs = mkDefault true;
        tmpfsHugeMemoryPages = "within_size";
      };

      services = {
        logrotate = disable;
        udisks2 = disable;

        # Saving the planet, one paper at a time
        printing = DISABLE;

        desktopManager.plasma6.enableQt5Integration = false;
      };

      # something something reducing dependencies on X libs
      security.pam.services.su.forwardXAuth = FALSE;
    }

    // {
      documentation = ifEnabled cfg.noDocs DISABLE // {
        doc = DISABLE;
        info = DISABLE;
        nixos = DISABLE;
      }; # TODO: custom top-level

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        # aurorae
        # plasma-browser-integration
        plasma-workspace-wallpapers
        # konsole
        kwin-x11
        # (lib.getBin qttools) # Expose qdbus in PATH
        # ark
        # elisa
        # gwenview
        # okular
        # kate
        # ktexteditor # provides elevated actions for kate
        khelpcenter
        # dolphin
        # baloo-widgets # baloo information in Dolphin
        # dolphin-plugins
        # spectacle
        ffmpegthumbs
        krdp
        xwaylandvideobridge # exposes Wayland windows to X11 screen capture
      ];

      services = {
        orca = ifEnabled cfg.noAccessibility DISABLE; # Screen reader
        speechd = ifEnabled cfg.noAccessibility DISABLE; # TTS
      };

      programs = {
        firefox.wrapperConfig = ifEnabled cfg.noAccessibility {
          speechSynthesisSupport = false;
        };
      };

      # The NixOS installer tools depend on a specific version of nix.
      system.disableInstallerTools = mkForce ifEnabled cfg.noInstallerTools;

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

    }

    // ifEnabled cfg.experimental {

      # "vconsole" is the one with Ctrl+Alt+F1
      # doesn't seem to have side effects
      console = DISABLE;

      # I meeeaaaaaan....
      networking.firewall = DISABLE;

      # Not entirely sure about this,
      # maybe I'll regret it some time.
      systemd.coredump.extraConfig = "Storage=none";

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

      # Ooh this is a good one
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

        # Don't conflict with above
        enableAllFirmware = FALSE;
        enableRedistributableFirmware = FALSE;
      };

    };
}
