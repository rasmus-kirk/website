{ pkgs, debug ? false }: let
  loopOut = "out";
in rec {
  dependencies = with pkgs; [ pandoc ];

  script = pkgs.writeShellApplication {
    name = "mk-pandoc";

    runtimeInputs = dependencies;

    text = ''
      out=$1
      debug=${toString debug}
      css="/pandoc/style.css"

      mkdir -p "$out"
      mkdir -p "$out"/articles

      cp -r ./articles ./pandoc "$out"

      buildarticle () {
        file_path="$1"
        filename=$(basename -- "$file_path")
        dir_path=$(dirname "$file_path")
        filename_no_ext="''${filename%.*}"

        if [ "$debug" = 1 ] ; then
          { 
            echo "$file_path"
            echo "$filename"
            echo "$dir_path"
            echo "$filename_no_ext"
            echo ""
          } >> "$out"/log.log
        fi

        mkdir -p "$out"/"$dir_path"

        pandoc \
          --standalone \
          --highlight-style pandoc/gruvbox-light.theme \
          --css "$css" \
          --lua-filter pandoc/lua/anchor-links.lua \
          --metadata debug="$debug" \
          --metadata timestamp="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
          --template pandoc/template.html \
          -V lang=en \
          -V --mathjax \
          -f markdown+smart \
          -o "$out"/"$dir_path"/"$filename_no_ext".html \
          "$file_path"
      }

      # Make wiki pages
      find articles -type f -name "*.md" | while IFS= read -r file; do
        buildarticle "$file"
      done

      # Make misc
      find misc -type f -name "*.md" | while IFS= read -r file; do
        buildarticle "$file"
      done

      pandoc \
        --standalone \
        --highlight-style pandoc/gruvbox-light.theme \
        --template pandoc/template.html \
        --metadata timestamp="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
        --css "$css" \
        -V lang=en \
        -V --mathjax \
        -f markdown+smart \
        -o "$out"/index.html \
        index.md
      '';
  };

  loop = pkgs.writeShellApplication {
    name = "mk-pandoc-loop";
    runtimeInputs = [ pkgs.fswatch script pkgs.fd ];
    text = ''
      set +e
      echo "Listening for file changes"
      fd --extension md | xargs fswatch --event Updated | xargs -n 1 sh -c "date '+%Y-%m-%d - %H:%M:%S %Z'; mk-pandoc ${loopOut}"
    '';
  };

  server = pkgs.writeShellApplication {
    name = "mk-pandoc-server";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      mkdir -p ${loopOut}
      cd ${loopOut}
      python -m http.server --bind 127.0.0.1 
    '';
  };

  package = pkgs.stdenv.mkDerivation {
    name = "mk-pandoc-package";
    src = ./.;
    buildInputs = [ script ];
    phases = ["unpackPhase" "buildPhase"];
    buildPhase = "${pkgs.lib.getExe script} $out";
  };
}

