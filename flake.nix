{

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;

  # inputs.bookmansrc.url = "./bookman.exe";
  # inputs.bookmansrc.flake = false;


  inputs.install4j.url = "https://maven.ej-technologies.com/repository/com/install4j/install4j-runtime/10.0.8/install4j-runtime-10.0.8.jar";
  inputs.install4j.flake = false;

  inputs.bookman-windows-download.url = "https://cockpit.bookman-gmbh.de/api/java/update/newest/WINDOWS/file"; # 1.15.0
  inputs.bookman-windows-download.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";

  description = "Bookman Executable for Linux";

  outputs = { self, nixpkgs, install4j, flake-utils, bookman-windows-download }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        packages.default = pkgs.writeShellApplication
          {
            name = "bookman";
            runtimeInputs = [ packages.coreutils ];
            text = ''
              mkdir -p "$HOME/.config/bookman"
              "${pkgs.jdk}/bin/java" \
                  -Duser.home="$HOME/.config/bookman" \
                  -Dde.bookman.deployMode=LIVE \
                  -Dde.bookman.javaBackendUri=https://cockpit.bookman-gmbh.de/api/java/ \
                  -Dde.bookman.microsoftApplicationId=a7719d9a-1877-4bd1-a3c7-e3f8edf86485 \
                  -Dde.bookman.microsoftSsoRedirectUrl=http://localhost:4826 \
                  --add-modules ALL-MODULE-PATH \
                  --add-exports javafx.base/com.sun.javafx.event=org.controlsfx.controls \
                  --add-opens javafx.base/com.sun.javafx.event=ALL-UNNAMED \
                  -cp "${packages.bookman-overrides}:${pkgs.jdk}/lib/*:${packages.bookman-jars}/*" \
                  de.bookman.start.MainGradle
            '';
          };

        packages.bookman-overrides = pkgs.runCommand "bookman-overrides"
          {
            src = ./override;
          } ''
          mkdir -p $out
          find $src -type f -name '*.java' -exec ${pkgs.jdk}/bin/javac -d $out  '{}' \;
        '';


        packages.bookman-jars =
          pkgs.runCommand "bookman-jars"
            {
              src = ./override;
            } ''
            ls ${bookman-windows-download}

            ${pkgs.unzip}/bin/unzip ${bookman-windows-download} -d bookman-files
            
            ${pkgs.unzip}/bin/unzip bookman-files/bookman_windows.exe -d installer_output || true

            ls installer_output/**
            mkdir -p jars
            mkdir -p home
            cp -a $src/. override
            ls ./installer_output/**
            cp -v ./installer_output/bin/lib/*  jars
            cp -v ./installer_output/bin/bookman-*.jar jars
            cp -v ${install4j} jars/install4j-runtime.jar
            chmod +x jars/install4j-runtime.jar
            
            cp -r jars $out
          '';

      });
}
