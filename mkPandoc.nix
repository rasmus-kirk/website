{pkgs, ...}:
pkgs.writeShellApplication {
  name = "my-script";
  runtimeInputs = with pkgs; [ pandoc ];
  text = ''
    mkdir -p out
    cp styling img documents out
    pandoc \
      --standalone \
      --highlight-style styling/gruvbox.theme \
      --metadata title="Rasmus Kirk" \
      --metadata date="$(date -u '+%Y-%m-%d - %H:%M:%S %Z')" \
      --css=styling/style.css \
      -V lang=en \
      -V --mathjax \
      -f markdown+smart \
      -o out/index.html \
      index.md
  '';
}
