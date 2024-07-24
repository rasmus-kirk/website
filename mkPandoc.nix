{pkgs, debug, ...}:
pkgs.stdenv.mkDerivation {
  name = "buildpandoc";
  src = ./.;
  buildInputs = with pkgs; [pandoc];
  phases = ["unpackPhase" "buildPhase"];
  buildPhase = ''
    debug=${toString debug}
    css="/pandoc/style.css"

    mkdir $out
    echo $debug >> $out/log.log

    if [ "$debug" = 1 ] ; then
      css=$out/pandoc/style.css
    else
      css="/pandoc/style.css"
    fi

    mkdir -p $out/articles
    cp -r ./articles ./pandoc ./documents $out

    buildarticle () {
      file_path="$1"
      filename=$(basename -- "$file_path")
      dir_path=$(dirname "$file_path")
      filename_no_ext="''${filename%.*}"

      if [ "$debug" = 1 ] ; then
        echo $file_path >> $out/log.log
        echo $filename >> $out/log.log
        echo $dir_path >> $out/log.log
        echo $filename_no_ext >> $out/log.log
        echo "" >> $out/log.log
      fi

      mkdir -p "$out"/"$dir_path"

      pandoc \
        --standalone \
        --highlight-style pandoc/gruvbox.theme \
        --css "$css" \
        --lua-filter pandoc/lua/anchor-links.lua \
        --metadata timestamp="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
        --template pandoc/template.html \
        -V lang=en \
        -V --mathjax \
        -f markdown+smart \
        -o $out/"$dir_path"/"$filename_no_ext".html \
        "$file_path"
    }

    # Make wiki pages
    find articles -type f -name "*.md" | while IFS= read -r file; do
      buildarticle "$file"
    done

    pandoc \
      --standalone \
      --highlight-style pandoc/gruvbox.theme \
      --template pandoc/template.html \
      --metadata timestamp="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
      --css "$css" \
      -V lang=en \
      -V --mathjax \
      -f markdown+smart \
      -o $out/index.html \
      index.md

    pandoc \
      --standalone \
      --highlight-style pandoc/gruvbox.theme \
      --template pandoc/template.html \
      --metadata timestamp="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
      --css "$css" \
      -V lang=en \
      -V --mathjax \
      -f markdown+smart \
      -o $out/articles/index.html \
      articles/index.md
  '';
}
