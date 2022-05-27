{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    jekyll-flake = { url = "github:haztecaso/flakes?dir=jekyll-flake"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, utils, jekyll-flake, ... }:
    utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; }; 
    mkAppScript = name: script: {
      type = "app";
      program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
    };
    jekyllPackages = jekyll-flake.packages.${system};
    jekyllApps = jekyll-flake.apps.${system};
  in rec {
    packages.elvivero-frutas = jekyllPackages.mkWeb {
      pname = "elvivero-frutas";
      version = "1.1";
      src = ./.;
    };
    defaultPackage = packages.elvivero-frutas;

    apps = jekyllApps // {
      push = mkAppScript "push" ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        ${pkgs.rsync}/bin/rsync -aPv ${packages.elvivero-frutas}/www/ lambda:/var/www/elvivero.es/frutas
      '';
    };
    defaultApp = apps.serve;

    devShell = pkgs.mkShell {
      packages = [ pkgs.ruby pkgs.nodejs jekyllPackages.jekyllFull ];
      shellHook = ''
        alias serve="jekyll serve --watch --livereload"
        alias preview="jekyll serve --watch --livereload --drafts"
        alias serve-prod="JEKYLL_ENV=production jekyll serve --watch --livereload"
      '';
    };

  });
}
