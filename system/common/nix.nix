{ pkgs, lib, ... }: {
  nix = {
    # Use lesbian nix
    package = pkgs.lix;
    # Automatically GC to avoid wasting disk
    gc = {
      automatic = true;
      persistent = true;
    };
    settings = {
      # Better builds
      sandbox = true;
      # Reduce disk use
      auto-optimise-store = true;
      # Sudoers are good
      trusted-users = lib.mkAfter [ "root" "@wheel" ];
      # Enable flakes
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
