# Scripts

If you aren't familiar with Nix and want to contribute a script, start here! For custom Nix packages (i.e. packages that have a `default.nix` or `flake.nix` at the root), use `pkgs/` instead.

This directory contains scripts, each in its own subdirectory. A script can be written in any interpreted language, provided that it has a corresponding interpreter [available](https://nixos.org/manual/nixpkgs/unstable/#chap-language-support) in [nixpkgs](https://github.com/nixos/nixpkgs/).

The code in this directory should be Nix-free and should work on its own provided a properly configured environment. The Nix packaging of this code happens in the `flake.nix` in the top-level root directory.

## Contributing

**TL;DR &mdash;** to contribute a script, create a subdirectory in `scripts` named after the script, place the script inside named `<script-name>.<ext>`, and add a line to the top-level `flake.nix` that packages the script.

All of the Nix language is available, but beginners are recommended to use the `mk*` helper functions provided in this flake. Currently these helpers support Bash scripts (`mkShellScript` and `mkShellScript2`) and Python scripts backed by Poetry (`mkPythonPoetryScript`). 

### Tutorial: Contributing a new Bash script

In more detail, let's step through an example of contributing a Bash script called `my-new-script.sh`:

```bash
#!/bin/bash

# Print a message from an arbitrarily-named cow.

set -euo pipefail

cow_statement="$1"
cow_name="$2"

cowsay << EOF
$cow_statement

- $cow_name
EOF
```

Notice this script calls `cowsay`, an external package. This package must be available in the environment running the script, or the script will fail. Rather than ask users to install `cowsay` manually, we will bundle it with our script so that when a new user runs the script on a machine without `cowsay` already installed, it "just works."

```
$ nix run .\#my-new-script -- "Hello, world!" "MooMoo"
 _____________________________________ 
/ Hello, world!                       \
|                                     |
\ - MooMoo                            /
 ------------------------------------- 
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

How do we bundle the script?

First, create a directory called `scripts/my-new-script`. Note the hyphens and lowercase.

Next, place the script itself in `scripts/my-new-script/my-new-script.sh`.

Now we are ready to package the script so others can use it. We will do this in the top-level `flake.nix`. Think of `flake.nix` as a root-level index or manifest file that makes code within the project available to outside users, kind of like `pyproject.toml` or `package.json` + `index.js` or `mix.exs`. 

In the top-level `flake.nix`, inside `packages`, add the following code. It contains a bug, but don't worry - we will fix it in a moment:

```nix
    packages = {
      # ...
      my-new-script = mkShellScript2 {
        name = "script-with-deps";
        ext = "sh";
        runtimeInputs = [  ];
      };
      # ...
    }
```

Now let's try running our script. From the top-level directory, run this shell command:

```
$ nix run .\#my-new-script -- "Hello, world!" "MooMoo"
/nix/store/2g5k52cgma1z2wx9iqvl0ysrqjr1z0sy-my-new-script/bin/my-new-script: line 8: cowsay: command not found
```

It will take a few seconds to build the script before running it. And it looks like `cowsay` was unavailable on the machine!

(Don't worry if the `/nix/store` path looks slightly different; the hash part `/nix/store/<hash-part>-my-new-script/bin/my-new-script` will likely differ from the above.)

We need to fix this by informing Nix that `cowsay` is a dependency of this script. In `flake.nix`, add `pkgs.cowsay` to the `runtimeInputs`:

```nix
    packages = {
      # ...
      my-new-script = mkShellScript2 {
        name = "script-with-deps";
        ext = "sh";
        runtimeInputs = [ pkgs.cowsay ]; # <= add this
      };
      # ...
    }
```

Now run the script again:

```
$ nix run .\#my-new-script -- "Hello, world!" "MooMoo"
 _____________________________________ 
/ Hello, world!                       \
|                                     |
\ - MooMoo                            /
 ------------------------------------- 
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

It worked!

TODO: discuss *why* it worked.


