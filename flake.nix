{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.05;
  };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.brain-ghost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # These are in the flake so we dont have to bother with passing the nixpkgs
        # flake to configuration.nxi
        {
          # Sets system revision from git revision of this repo
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          # Sets up nix shell and nix-shell type refs
          nix = {
            registry.nixpkgs.flake = nixpkgs;
            nixPath = [ "nixpkgs=${nixpkgs}" ];
          };
        }
        # Import the actual system config
        ./system/brain-ghost/configuration.nix
      ];
    };
  };
}
