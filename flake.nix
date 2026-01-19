{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }: {
    nixosConfigurations.brain-ghost = nixpkgs.lib.nixosSystem rec {
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
        ./fan/module.nix
        {
          nixpkgs.overlays = [
            (_: _: {
              fancontrol = self.packages.${system}.fancontrol;
            })
          ];
          services.fancontrol = {
            enable = true;
            listenAddress = "192.168.122.1";
            profiles.nvidia = {
              fans = [
                { hwmon = 1; fan = 3; }
                { hwmon = 1; fan = 5; }
              ];
              curve = [
                { temperature = 29; speed = 10; }
                { temperature = 68; speed = 179; }
                { temperature = 80; speed = 255; }
              ];
            };
          };
        }
        # Import the actual system config
        ./system/brain-ghost/configuration.nix
      ];
    };
    nixosConfigurations.autoresponder = nixpkgs.lib.nixosSystem rec {
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
        ./fan/module.nix
        {
          nixpkgs.overlays = [
            (_: _: {
              fancontrol = self.packages.${system}.fancontrol;
            })
            (final: prev: {
              cudaPackages = final.cudaPackages_12_6;
            })
          ];
        }
        # Import the actual system config
        ./system/autoresponder/configuration.nix
      ];
    };
  } // (
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        rust_toolchain =
          p: pkgs.rust-bin.stable.latest;
        craneLib = (crane.mkLib pkgs).overrideToolchain (p: (rust_toolchain p).minimal);
        llvm_packages = pkgs.llvmPackages_21;
        nativeBuildInputs = [ pkgs.pkg-config llvm_packages.clang ];
        buildInputs = [ ];
      in
      rec {
        packages = rec {
          fancontrol = craneLib.buildPackage {
            buildInputs = buildInputs ++ [ ];
            nativeBuildInputs = nativeBuildInputs ++ [ ];
            src = craneLib.cleanCargoSource ./fan;
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = buildInputs ++ [ ];
          nativeBuildInputs = nativeBuildInputs ++ [
            ((rust_toolchain pkgs).default.override {
              extensions = [ "rust-src" "rustfmt" "rust-analyzer" "clippy" ];
            })
          ];
        };
      }
    ));
}
