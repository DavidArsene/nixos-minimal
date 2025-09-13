{ lawful }:
with lawful;

# Changes that bring larger gains to most
# use cases, may need manually tweaking.

{
  services = {
    # TODO: docs
    logrotate = disable;
    udisks2 = disable;

    # No accessibility for most
    orca = DISABLE; # Screen reader
    speechd = DISABLE; # TTS

    # Saving the planet, one paper at a time
    printing = DISABLE;

    # all alone here, so sad
    desktopManager.plasma6.enableQt5Integration = FALSE;
  };

  # Not related but has the same vibe
  boot.tmp = {
    useTmpfs = mkDefault true;
    tmpfsHugeMemoryPages = "within_size";

    # Can't get it to work yet
    # useZram = true;
    # zramSettings.zram-size = "ram * 1"; # X-mount?
    # zramSettings.options = "mode=0755,discard";
  };

  programs = {
    fish.generateCompletions = mkDefault false;

    firefox.wrapperConfig = {
      speechSynthesisSupport = false;
    };
  };

  # "vconsole" is the one with Ctrl+Alt+F1
  console = DISABLE;

  # I meeeaaaaaan....
  networking.firewall = DISABLE;

  # Modems? In the Year of our Lord ${year}?
  networking.modemmanager = DISABLE;

  # Keyboard still works so /shrug
  # Maybe on-screen-keyboard / CJK something
  i18n.inputMethod = DISABLE;

  # Not entirely sure about this,
  # maybe I'll regret it some time.
  systemd.coredump.extraConfig = "Storage=none";

  # something something reducing dependencies on X libs
  security.pam.services.su.forwardXAuth = FALSE;


}
