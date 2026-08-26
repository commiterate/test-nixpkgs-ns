{
  mkShell,
  nixfmt,
  treefmt,
}:
# https://nixos.org/manual/nixpkgs/unstable#sec-pkgs-mkShell
mkShell {
  packages = [
    # Nix.
    nixfmt
    # Treefmt.
    treefmt
  ];

  shellHook = ''
    echo "❄️"
  '';
}
