{
  description = "Nix flake for Coucou - AI coding agent companion and dynamic island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      packages = forAllSystems (system: {
        coucou = pkgsFor.${system}.callPackage ./package.nix { };
        default = self.packages.${system}.coucou;
      });

      checks = forAllSystems (system: {
        inherit (self.packages.${system}) coucou;
      });

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor.${system};
          updateScript = pkgs.writeShellApplication {
            name = "update-coucou";
            runtimeInputs = with pkgs; [ curl jq gnugrep gnused nix git coreutils ];
            text = ''
              exec ${./update.sh} "$@"
            '';
          };
        in
        {
          coucou = {
            type = "app";
            program = "${self.packages.${system}.coucou}/bin/coucou";
            meta = {
              description = "Coucou";
            };
          };
          update = {
            type = "app";
            program = "${updateScript}/bin/update-coucou";
            meta = {
              description = "Update Coucou package to the latest release";
            };
          };
          default = self.apps.${system}.coucou;
        });

      overlays.default = final: prev: {
        coucou = self.packages.${final.system}.coucou;
      };

      nixosModules.default = { pkgs, ... }: {
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.coucou
        ];
      };
    };
}
