{
  description = "Deep Live Cam with CUDA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    let
      python = pkgs.python311.withPackages (ps: [ ps.tkinter ]);

      ldPath = pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.linuxPackages.nvidia_x11
        pkgs.ncurses5
        pkgs.libGL
        pkgs.glib
        pkgs.cudaPackages_11.cudatoolkit
      ] + ":/run/opengl-driver/lib";

      run-script = pkgs.writeShellApplication {
        name = "deep-live-cam";
        runtimeInputs = [ pkgs.uv pkgs.git pkgs.findutils python ];
        text = ''
          export CUDA_PATH=${pkgs.cudaPackages_11.cudatoolkit}
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export LD_LIBRARY_PATH="${ldPath}"
          PRJ_ROOT="$(git rev-parse --show-toplevel)"
          cd "$PRJ_ROOT"
          export UV_PYTHON="${python}/bin/python"
          uv sync
          VENV_SITE="$(find .venv/lib -name site-packages -type d)"
          export PYTHONPATH="$VENV_SITE''${PYTHONPATH:+:$PYTHONPATH}"
          exec python Deep-Live-Cam/run.py --execution-provider cuda "$@"
        '';
      };
    in
    {
      apps.${system}.default = {
        type = "app";
        program = "${run-script}/bin/deep-live-cam";
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          gnupg autoconf
          procps gnumake
          util-linux m4
          gperf unzip
          libGLU libGL
          xorg.libXi xorg.libXmu freeglut
          xorg.libXext xorg.libX11
          xorg.libXv xorg.libXrandr zlib
          ncurses5 stdenv.cc
          binutils glib
          ffmpeg curl
          cudaPackages_11.cudatoolkit cudaPackages_11.cudnn_8_9
          linuxPackages.nvidia_x11
          python
          uv
          run-script
        ];

        LD_LIBRARY_PATH = ldPath;

        shellHook = ''
          export CUDA_PATH=${pkgs.cudaPackages_11.cudatoolkit}
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export PRJ_ROOT="$(git rev-parse --show-toplevel)"
          export UV_PYTHON="${python}/bin/python"
          uv sync
          VENV_SITE="$(find .venv/lib -name site-packages -type d)"
          export PYTHONPATH="$VENV_SITE''${PYTHONPATH:+:$PYTHONPATH}"
        '';
      };
    };
}
