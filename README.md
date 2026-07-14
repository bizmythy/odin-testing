# Odin Raylib Testing

A small Odin project using Raylib, with a reproducible Nix development shell.

## Development

Enter the project directory with direnv enabled, or run:

```sh
nix develop
odin run .
```

The development shell provides Odin, OLS, Raylib, and the linker library path required by Odin's `vendor:raylib` package.
