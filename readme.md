# test-nixpkgs-ns

Making Nixpkgs namespacing look more like typical programming language namespacing.

Main ideas:

1. Namespaces are hierarchical (e.g. `test-nixpkgs-ns` is the parent of `test-nixpkgs-ns.packages`).
2. Namespace layout mirrors the source layout.
3. Nixpkgs provides the base namespaces (what other programming languages have built in).
4. Nixpkgs overlays (what other programming language package managers call "packages") provide additional namespaces added to the Nixpkgs base namespaces.

1 + 2 are done with `nixpkgs.lib.filesystem.packagesFromDirectoryRecursive` which makes nested attribute sets the namespacing mechanism.

3 is an unstable foundation because Nixpkgs often makes breaking changes (e.g. dropping unmaintained + end-of-life derivations).

4 is done with `lib.fixedPoints.composeManyExtensions` to specify dependencies between Nixpkgs overlays + `nixpkgs.lib.attrsets.recursiveUpdate` to do deep namespace merges (`lib.fixedPoints.composeManyExtensions` does shallow merges by default).

## Layout

Notable landmarks:

```text
Key:
🤖 = Generated

.
│   # Nix sources.
├── inputs
│   │   # Nixpkgs overlays.
│   ├── overlays
│   │   └── {overlay}
│   │       └── test-nixpkgs-ns
│   │           │   # Packages.
│   │           ├── packages
│   │           │   └── {package}
│   │           │       ├── package.nix
│   │           │       └── {package support file (e.g. patch)}
│   │           │
│   │           │   # Checks.
│   │           ├── checks
│   │           │   └── {check}
│   │           │       ├── package.nix
│   │           │       └── {check support file (e.g. script)}
│   │           │
│   │           │   # Development shells.
│   │           └── devShells
│   │               └── {shell}.nix
│   │
│   │   # NixOS modules.
│   ├── nixosModules
│   │   └── {module}.nix
│   │
│   │   # NixOS configurations.
│   └── nixosConfigurations
│       └── {configuration}.nix
│
│   # Nix configuration.
├── flake.nix
└── flake.lock 🤖
```

## Notes

### Inspecting Flakes Interactively

Sometimes you might want to inspect flakes interactively for things like finding what attributes exist on an attribute set.

You can use the Nix REPL to load a flake and inspect it.

```shell
# Start the Nix REPL.
nix repl

# Load the flake.
nix-repl> :load-flake .

# Inspect the flake.
#
# Tab completion lists available attributes.
nix-repl> outputs.
nix-repl> outputs.overlays.
nix-repl> :print outputs
{
  defaultInputs = {
    # ...
    nixpkgs = {
      # ...
      legacyPackages = {
        # ...
        aarch64-darwin = {
          # ...
          test-nixpkgs-ns = {
            packages = {
              hello = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
              hello_2 = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
            };
          };
          # ...
        };
        # ...
      };
      # ...
    };
    # ...
  };
  developmentInputs = {
    # ...
    nixpkgs = {
      # ...
      legacyPackages = {
        # ...
        aarch64-darwin = {
          # ...
          test-nixpkgs-ns = {
            devShells = {
              default = «derivation /nix/store/6afqc8gl7y2lv4xrf5myzhgcr1j60x75-nix-shell.drv»;
            };
            packages = {
              hello = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
              hello_2 = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
            };
          };
          # ...
        };
        # ...
      };
      # ...
    };
    # ...
  };
  devShells = {
    aarch64-darwin = {
      default = «derivation /nix/store/6afqc8gl7y2lv4xrf5myzhgcr1j60x75-nix-shell.drv»;
    };
    aarch64-linux = {
      default = «derivation /nix/store/wm661wk7dh09afw82s80jarikf8g5hsk-nix-shell.drv»;
    };
    x86_64-linux = {
      default = «derivation /nix/store/8sqb8ii38s67cgzi2r4jvsdqingi3ypc-nix-shell.drv»;
    };
  };
  overlays = {
    default = «lambda default @ /nix/store/mlwpv8x0pc2l1lbvprrsfb3gi1271brg-source/flake.nix:29:11»;
    development = «lambda composeExtensions @ /nix/store/zl3blp4cr2wjq2qhac4q4fzi0vh4dfac-source/lib/fixed-points.nix:341:11»;
  };
  packages = {
    aarch64-darwin = {
      hello = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
      hello_2 = «derivation /nix/store/plfav5xcizh269kaf1x1xv85varpmwdk-hello-2.12.3.drv»;
    };
    aarch64-linux = {
      hello = «derivation /nix/store/49jn8kyawar5qn8fl13bdvjwkyiyw565-hello-2.12.3.drv»;
      hello_2 = «derivation /nix/store/49jn8kyawar5qn8fl13bdvjwkyiyw565-hello-2.12.3.drv»;
    };
    x86_64-linux = {
      hello = «derivation /nix/store/mbsh3ww15zljsr6xmgyla1zwwd8rrf5j-hello-2.12.3.drv»;
      hello_2 = «derivation /nix/store/mbsh3ww15zljsr6xmgyla1zwwd8rrf5j-hello-2.12.3.drv»;
    };
  };
}
```
