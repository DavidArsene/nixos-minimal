{
  lib,
  pkgs,
}:
with lib;

# Changes which should be unnoticeable
# for most use cases.

let

  # If they yell at you, it's force disable.
  # (To prevent nixpkgs from changing it.)

  DISABLE = {
    enable = mkForce false;
  };

  FALSE = mkForce false;

  # disable in lowercase is more of a chill guy,
  # he just suggests something be off by default,
  # but doesn't get in your way otherwise.

  disable = {
    enable = mkDefault false;
  };
in
{
  # These first ones (until plasma6) are taken
  # directly from profiles/minimal.nix
  # I assume they would be welcomed by enough
  # of a majority of users of such a project.
  #
  # I try to be mindful of that
  # everytime I use mkForce.

  documentation = DISABLE // {
    doc = DISABLE;
    info = DISABLE;
    nixos = DISABLE;
    man = DISABLE // {
      man-db = DISABLE;
    };
  };

  # Enabled by desktop environments when needed
  xdg = {
    autostart = disable;
    icons = disable;
    mime = disable;
    sounds = disable;
  };

  # What does "environment" even
  # mean for a grouping category?
  environment = {

    # [ perl rsync strace ]
    defaultPackages = mkForce [ ];

    # Now we're really nitpicking
    stub-ld = disable;

    # Pretty self-explanatory if I do say so myself
    # This selection is what I personally use
    plasma6.excludePackages = with pkgs.kdePackages; [
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
  };

  programs = {
    # use nix-community/nix-index-database
    command-not-found = DISABLE;

    # Other packages depend on normal git
    # anyway, so this is kinda useless.
    git.package = pkgs.gitMinimal;
  };

}
