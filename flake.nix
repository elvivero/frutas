{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, utils }: {
    overlay = final: prev: {
      elvivero-frutas-env = final.callPackage ({ bundlerEnv, ruby }: bundlerEnv {
        name = "elvivero-frutas-env";
        inherit ruby;
        gemfile = ./Gemfile;
        lockfile = ./Gemfile.lock;
        gemset = ./gemset.nix;
      }) {};
      elvivero-frutas-web = final.callPackage ({ stdenv, elvivero-frutas-env, bundler, ruby, nodejs }: stdenv.mkDerivation {
        name = "frutas-de-diseno";
        src = ./.;
        buildInputs = [ elvivero-frutas-env bundler ruby nodejs ];
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
    mkAppScript = name: script: {
      type = "app";
      program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
    };
  in rec {
    packages.elvivero-frutas-web = pkgs.elvivero-frutas-web;
    packages.elvivero-frutas-env = pkgs.elvivero-frutas-env;
    defaultPackage = packages.elvivero-frutas-web;

    apps.serve = mkAppScript "serve" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      ${pkgs.elvivero-frutas-env}/bin/bundle exec jekyll serve --watch --incremental --livereload
    '';

    apps.serve-prod = mkAppScript "serve-prod" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      JEKYLL_ENV=production ${pkgs.elvivero-frutas-env}/bin/jekyll serve --watch --incremental --livereload
    '';

    apps.push = mkAppScript "push" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      ${pkgs.rsync}/bin/rsync -aPv ${pkgs.elvivero-frutas-web}/www/ lambda:/var/www/elvivero.es/frutas
    '';

    defaultApp = apps.serve;

    devShell = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [ elvivero-frutas-env bundler ruby nodejs ];
      # shellHook = '' '';
    };
  });
}
