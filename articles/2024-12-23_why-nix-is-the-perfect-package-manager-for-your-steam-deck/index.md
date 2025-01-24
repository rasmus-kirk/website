---
title: Why Nix Is the Perfect Package Manager for Your Steam Deck
date: 2024-12-23
keywords: [nix, steamdeck, linux]
---

> **TLDR:** Three big reasons to consider Nix for your Steam Deck:
>
> 1. Not all packages are available as Flatpaks, Nixpkgs is the largest Linux
>    package repository by far with 120 000 packages, and is therefore a
>    nice supplement, or replacement, to Flatpaks.
> 2. Services can be set up in a single line using Home-manager
>    (`services.syncthing.enable`), which is MUCH easier than [configuring
>    systemd-services yourself](https://www.reddit.com/r/SteamDeck/comments/vocyi5/start_syncthing_automatically_on_steamdeck_even/).
> 3. Reproducible setups with Home Manager, allowing you to replicate packages
>    and configuration between your main machine and your Steam Deck.

In this article I'd like to show how to get Nix working on your Steam Deck
and explain why you might want to. Firstly, you need to install Nix. I've seen
a lot of people struggling using the official Nix installer, [this guide for
example](https://www.reddit.com/r/SteamDeck/comments/18d14l9/nix_packages_on_steam_deck/)
takes a lot of steps for something that really ought to be
a single command. Luckily, the wonderful folks at [Determinate
Systems](https://determinate.systems/) have made a more versatile [Nix
installer](https://github.com/DeterminateSystems/nix-installer) that works
wonderfully on the Steam Deck.

If you're new to Nix, the idea of using an unofficial installer might feel
jarring, but don't worry, Determinate Systems isn't a no-name company in
the Nix sphere. The creator of Nix, Eelco Dolstra, is even a co-founder and
continues to be involved in the company. To install Nix on your Steam Deck,
simply call the following command and follow the instructions:

```bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install
```

The installer will ask you to confirm a couple of times, and if anything goes
wrong it will undo its own changes. It also comes with its own uninstaller
for convenience. Now that you have Nix on your Steam Deck, what can you use
it for? Well, you can install packages of course! Nix has one of the largest
package sets of any package manager with over 120 000 packages. If a package
isn't available as a Flatpak, Nix can be an invaluable tool. To install a
package simply run:

```bash
 nix profile install nixpkgs#cowsay
```

To find other packages check out
[search.nixos.org](https://search.nixos.org/packages). But installing packages
this way is not _declarative_, so if you want to reproduce the package
set that is on your Steam Deck, you would have to remember every package
that you've installed. To install packages in the Nix Way™, you could use
[Home Manager](https://github.com/nix-community/home-manager) instead. Home
Manager allows you to define a list of packages for your system, you can
then copy that list to any machine that also has Home Manager and get the
exact same packages, even down to the version!

Home Manager doesn't just allow for configuring what packages are installed,
but also how they are configured. I, for example, use Home Manager on my work
laptop and can therefore port my text editor, including all LSPs that follow,
to my Steam Deck. It can also help set up services that run in the background,
they even continue to run while you're in gamemode. Take [this Reddit
post](https://www.reddit.com/r/SteamDeck/comments/vocyi5/start_syncthing_automatically_on_steamdeck_even/)
describing how to set up [Syncthing](https://syncthing.net/), an excellent
synchronization tool that could be used to synchronize saves and roms for
emulators between machines. The Reddit post describes a series of steps and
files you need to go through to get Syncthing running. Using Home Manager
all you need to do is add the following to your Home Manager configuration:

```nix
  services.syncthing.enable = true;
```

## How to install Home Manager

First, make sure you have Nix installed otherwise use the installer described above:

```bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install
```

To install Home Manager, use the following command

```bash
  nix run home-manager/master -- init --switch -b backup
```

Let's dissect the above command, the `nix run` tells nix you want to run
a program (Home Manager), without installing it globally, from the master
branch. The `--` indicates that the following parameters will be passed
to said program. The `init` means that we want to initialize the default
configuration at `~/.config/home-manager/` and `--switch` means that we want to
build the configuration and apply it. The `-b backup` tells Home Manager that
any files that it wants to overwrite will be renamed to `FILENAME.bak` instead.

We can see the file that it created:

```nix {.numberLines}
  { config, pkgs, ... }:

  {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "user";
    home.homeDirectory = "/home/user";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/user/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      # EDITOR = "emacs";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  }
```

We can add some packages, and enable the syncthing service. I have removed
the comments so as to not keep it concise:

```nix {.numberLines}
  { config, pkgs, ... }:

  {
    home.username = "user";
    home.homeDirectory = "/home/user";

    home.stateVersion = "24.11"; # Please read the comment before changing.

    home.packages = [
      pkgs.librewolf
      pkgs.helix
    ];

    services.syncthing.enable = true;

    home.sessionVariables = {
      EDITOR = "hx";
    };

    programs.home-manager.enable = true;
  }
```

This example defines a couple of packages, enables Syncthing, and sets the
default editor. Modify these options to suit your preferences. Now we can
apply the changes:

```bash
  home-manager switch -b backup
```

Which should build your new configuration. To see more options, you search
the relevant man page:

```bash
  man home-configuration.nix
```

Or you can use [a browser
version](https://home-manager-options.extranix.com/). To
learn more about Home-Manager, you should really read [the
manual](https://nix-community.github.io/home-manager/index.xhtml),
and maybe checkout the [simple-homemanager
guide](https://github.com/Evertras/simple-homemanager).

I hope this guide has clarified why and how you might want to add Nix to
your Steam Deck’s toolbelt. Perhaps it has even inspired you to start
exploring the powerful, yet confusing, world of Nix.

Have fun Nixing!

> This article is also available [in raw markdown](./index.md)
