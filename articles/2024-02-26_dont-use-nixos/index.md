---
title: Don't use nixos
date: 2024-02-26
---

I feel like a lot of people tend to view nix/nixos as "just another distro",
and therefore tend to jump straight from ubuntu/arch/whatever into nixos,
only to immediatly complain that the learning curve is one big wall. It's
certainly my own experience, but there is a better way.

Nix is not really an all or nothing. It's essentially a swiss army knife
that addresses the problem of "_software runs on computer A, now make it
run the same way on computer B_".

There is different levels of nix:

- **Nix as a unix package manager:** Nixpkgs has over 80.000 packages so
  instead of using pacman, apt or homebrew to get your packages you can use
  nix instead. Simply run `nix profile install nixpkgs#cowsay`^[1] to permenantly
  install the cowsay package.
- **Nix as a temporary package manager:** Want to quickly run a package but
  don't want to pollute your system environment with one-off packages? Write
  `nix shell nixpkgs#cowsay` to get a shell environment with the package
  cowsay. Want to just run the binary in the cowsay package? Use `nix run
  nixpkgs#cowsay`.
- **Nix as a build environment:** Ever had a repo or piece of code with
  poorly documented dependencies? Sometimes there are even hidden undeclared
  dependencies (package that may be default on Ubuntu but not on Arch!). You
  can include a nix flake in your repo with build instructions and anyone with
  nix can run `nix build github:github-account/repo` to build your software
- **Nix for a reproducible dotfile managements:** You can use home-manager
  (nix module) to create a _declaritive_ reproducible home environment
  containing all your dotfile configurations and all your packages. Quickly get
  all your tools, configured as you want on any unix-system in like 15 minutes.
- **Nixos for a reproducible linux system:** You can use nix to configure your
  entire system: Declaritively install programs, configure and run services
  (like plex or something), configure user programs (like a tiling window
  manager), anything you want to do on a linux system, but _declaritively_.

Notice, you don't even have to switch out apt, homebrew or pacman/aur for nix,
nor do you have to manage two package manager states with nix. You can choose
to only use it for tempoary package environments (`nix run`/`nix shell`)
and tempoary developments/build environments (`nix shell`/`nix build`).

Starting on a "lower level" of nix would help out a lot and avoid a lot
of the more esoteric issues one might have on the "higher levels", while
reaping most of the same benefits. You certainly don't have to do what I did
and take the plunge directly on something as complex as Nixos, just to fall
30 meters and land on concrete.

## How I used nix

TODO: asdf

## How I _use_ nix

Today, I use just standard boring popos on my laptop. I don't want to
try to build a package from a github description just to find out that my
"snowflake distro" doesn't support weird pseudostandard that most of the
other distros does. I also don't have time to configure every little thing
such as bluetooth modules or wifi, I want to have a starting point that gets
me the day-to-day features I need and _then_ configure my tooling on that.

But nix can also do that for me. I can create a reproducible, declaritive
toolbox using home manager and let popos handle all the boring system-level
stuff. This unfortunately means that nix can't handle some system-level stuff
I _do_ want to configure like tweaking popos, setting up docker or routing
my traffic through a VPN. Sure, I won't have a 100% reproducibility this way,
however I save myself from most of the headaches.

What I do get, is the ability to have my toolbox on any unix[^2] machine
with only two commands:

```sh
TODO: Add cmd lines here
```

This is great! I can now have my toolbox on my work laptop, home laptop,
NAS or even my steam deck, no matter the flavour of linux they're running.

Here is some of the uses I happily use nix for today:

- As a build-tool geared for reproducibility for various software projects
- I use a [nix
  flake](https://gist.github.com/rasmus-kirk/c56267f2256a5b1326eefdcb2da33d92)
  to reproducibly compile pandoc-flavoured markdown into a pdf. It can also
  run a script that waits for `$file.md` files to change and then compile
  it into `$file.pdf`.
- I use [home-manager](<!-- TODO: insert link -->) to manage all my dotfiles
  and user-level packages.
- I use Nixos on my NAS to host various services.
- Both my home-manager and nixos configuration are declared in a single
  [flake](<!-- TODO: insert link -->).

Using nix is software heaven when it works, but as soon as you stray from the
"happy path" you quickly find your way to software hell. While I learned a
lot from my own journey, and _now_ certainly find myself comfortable using
this complicated, messy but altogether wonderful tool, I find that some
people new to nix are tempted to follow the same path that I did, but the
"hard way" isn't always the better. So don't use nixos, use nix.

[1]: Note that this is using the "new" experimental features: `nix-command`
     and `flakes`
[2]: If I used a mac then not _all_ packages will be available, but you get
     the point
