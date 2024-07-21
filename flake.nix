{inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  flake-utils.url = "github:numtide/flake-utils";
};

outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.git
          pkgs.nodejs
          pkgs.typescript
          pkgs.fnm
          pkgs.redis
          pkgs.mongodb
        ];

        preBuild = ''
          echo "PreBuild: Setting up the development environment..."

          case "$(uname)" in
            Linux)
              # Linux-specific settings
              sudo sysctl vm.overcommit_memory=1 || true
              export LC_ALL=C
              export LANG=C
              ;;
            Darwin)
              # macOS-specific settings
              export LC_ALL=C
              export LANG=C
              ;;
            CYGWIN*|MINGW32*|MSYS*|MINGW*)
              # Windows-specific settings
              echo "Running on Windows"
              ;;
            *)
              echo "Unknown OS"
              ;;
          esac
        '';

        installPhase = ''
          echo "InstallPhase: Installing dependencies and setting up the environment..."

          # Setup FNM
          if [ -d "$HOME/.fnm" ]; then
            export PATH="$HOME/.fnm:$PATH"
            eval "$(fnm env)"
          else
            echo "FNM not found"
          fi

          # Setup Redis
          export REDIS_CONF_FILE=$PWD/redis.conf
          mkdir -p $PWD/redis_data
          echo "dir $PWD/redis_data" > $REDIS_CONF_FILE
          redis-server $REDIS_CONF_FILE &

          # Setup MongoDB
         # export MONGO_DATA_DIR=$PWD/mongo_data
          #mkdir -p $MONGO_DATA_DIR
         # mongod --dbpath $MONGO_DATA_DIR --fork --logpath $PWD/mongodb.log

          # Set environment variables
          
#export NODE_ENV=development
         # export REDIS_URL=redis://localhost:6379
        #  export MONGO_URL=mongodb://localhost:27017
        '';

        postBuild = ''
          echo "PostBuild: Finalizing the setup..."
          echo "Installing Node.js dependencies..."
          npm install
          echo "Starting the development server..."
          npm run dev
        '';
      };
    });
}
