{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/25.05;
  };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.brain-ghost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix = {
            registry.nixpkgs.flake = nixpkgs;
            nixPath = [ "nixpkgs=${nixpkgs}" ];
          };
        }
        ./configuration.nix
      ];
    };
  };
}
