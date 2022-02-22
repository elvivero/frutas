{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, utils }: {
    overlay = final: prev: {
      jekyll_env = final.callPackage ({ bundlerEnv, ruby }: bundlerEnv {
        name = "jekyll_env";
        inherit ruby;
        gemfile = ./Gemfile;
        lockfile = ./Gemfile.lock;
        gemset = ./gemset.nix;
      }) {};
      website = final.callPackage ({ stdenv, jekyll_env, bundler, ruby, nodejs }: stdenv.mkDerivation {
        name = "frutas-de-diseno";
        src = ./.;
        buildInputs = [ jekyll_env bundler ruby nodejs ];
        buildPhase = ''
	      JEKYLL_ENV=production jekyll build
        '';
        installPhase = ''
          mkdir -p $out
          cp -Tr _site $out/www/
        '';
      }) {};
    };

  } // utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; overlays = [self.overlay]; }; 
    serve = pkgs.writeShellScriptBin "serve" ''
      ${pkgs.jekyll_env}/bin/bundle exec jekyll serve --watch --incremental
    '';
    push = pkgs.writeShellScriptBin "push" ''
      ${pkgs.rsync}/bin/rsync -aPv ${pkgs.website}/www/ lambda:/var/www/elvivero.es/frutas
    '';
  in
  rec {
    packages.website = pkgs.website;
    packages.jekyll_env = pkgs.jekyll_env;
    defaultPackage = packages.website;

    apps.serve = {
      type = "app";
      program = "${serve}/bin/serve";
    };

    apps.push = {
      type = "app";
      program = "${push}/bin/push";
    };

    defaultApp = apps.serve;

    devShell = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [ jekyll_env bundler ruby ];
      shellHook = ''
      '';
    };
  });
}
