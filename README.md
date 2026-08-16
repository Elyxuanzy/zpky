# Welcome to  zpky

zpky is a teaching-oriented, script-style package manager, entirely written in POSIX-compliant Ash shell scripts. Its most distinctive features are simple configuration, an easy learning curve, and clear, straightforward code. It is intended to provide a minimal and understandable package manager for embedded systems or resource-constrained operating systems, and can also serve as a reference implementation for other package managers.





### Dependencies

- `wget` (for downloading)
- `tar` (for extracting archives)
- standard POSIX utilities: `grep`, `sed`, `find`, `mkdir`, `rm`, etc.


Usage

```bash
zpky install <package...>      # install one or more packages
zpky remove <package...>       # remove one or more packages
zpky reinstall <package...>    # reinstall one or more packages
zpky search <package>          # check if a package exists
zpky list                      # list installed packages
zpky version                   # show version
zpky help                      # show help
```

## Configuration: list.ini
*Let not the package bend to the manager;
let the manager bend to the package.*



Place a list.ini file in the directory where you run zpky. The format is extremely simple:

```ini
[package-name]
download-url
[another-package]
another-url
```

In Zpky, configuring a new package is straightforward. You only need to ensure that the original project is actually written using shell scripts — there is no need to add any special configuration files to the original project. Zpky handles the linking automatically.

## Sponsors
*@my boyfriend*






 
