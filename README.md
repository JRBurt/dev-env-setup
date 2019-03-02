# Auto Configure Development Environment in macOS
This script is used to setup developer tools on a fresh install of macOS.


## Clone this repo:

```
$ git clone https://github.com/JRBurt/dev-env-setup.git
```

## Run the master script:

```
$ ./install.sh
```

This will: (in order)

- install /update Homebrew
- install git
- install Ruby
- install PostgreSQL
- overwrite .gitconfig
- overwrite .bash_profile
- install macOS application bundle
- overwrite bashrc
- install VS Code extensions
- set VS Code settings
- set up VS Code snippets
- set firmware password
- set computer name
- set preferred macOS defaults