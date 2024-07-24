---
title: Don't use nixos
date: 2024-07-24
---

I feel like a lot of people tend to view nix/nixos as "just another distro",
and therefore tend to jump straight from ubuntu/arch/whatever into nixos, only
to then immediatly start complaining that the learning curve is essentially
one big wall. It has certainly been my own experience, but I will argue that
there are better ways.

Nix is not really an all or nothing. It's essentially a swiss army knife
that addresses the problem of "_software runs on computer A, now make it
run the same way on computer B_".

There is different "levels" of nix:

- **Nix as a unix package manager:** Nixpkgs has over 80.000 packages so
  instead of using pacman, apt or homebrew to get your packages you can use
  nix instead. Simply run `nix profile install nixpkgs#cowsay`[^1] to permenantly
  install the cowsay package. This is particularly useful on debian-based
  systems, as apt has an annoyingly small package set. Think of it like the
  AUR for arch, but on any distro! Even MacOS!
- **Nix as a temporary package manager:** Want to quickly run a package but
  don't want to pollute your system environment with one-off packages? Write
  `nix shell nixpkgs#cowsay` to get a shell environment with the package
  cowsay. Want to just _run_ the binary in the cowsay package? Use 
  `nix run nixpkgs#cowsay`.
- **Nix as a build environment:** Ever had a repo or piece of code with
  poorly documented dependencies? Sometimes there are even hidden undeclared
  dependencies (package that may be default on Ubuntu but not on Arch!). You
  can include a nix flake in your repo with build instructions such that anyone with
  nix can run `nix build github:github-account/repo` to build your software.
- **Nix for a reproducible dotfile managements:** You can use home-manager
  (nix module) to create a _declaritive_, _reproducible_ home environment
  containing all your dotfile configurations and all your packages. Quickly get
  all your tools, configured as you want on any unix-system in ~15 minutes.
- **Nixos for a reproducible linux system:** You can use nix to configure your
  entire system: Declaritively install programs, configure and run services
  (Syncthing, Plex, whatever), configure user programs (like a tiling window
  manager), anything you want to do on a linux system, but _declaritively_.

Notice, you don't even have to switch out apt, homebrew or pacman/aur for nix,
nor do you have to manage two package manager states with nix. You can choose
to only use it for tempoary package environments (`nix run`/`nix shell`)
and tempoary developments/build environments (`nix shell`/`nix build`).

Starting on a "lower level" of nix would help out a lot and avoid a lot
of the more esoteric issues one might have on the "higher levels", while
reaping most of the same benefits. You certainly don't have to do what I did
and take the plunge directly on something as complex as Nixos, just to fall
down and faceplant the concrete below.

## How I used nix

I started using Nixos after having to migrate my Arch configuration,
and finding everything a complete mess. What had I configured? What had I
installed? What state did I want to keep? Arch did not give me the proper
tools to organize this, and I considered writing a bash script that set
everything up to organize myself. Then I discovered Nixos and knew that this
was exactly the tool I needed!

Learning to use Nixos was tough though. I spent a lot of time just getting
basic stuff to work, and this was despite coming from Arch. Everything had
to be done the "Nix way", and as I maximized for reproducibility, I ended
up playing whack-a-mole with countless of tedious issues. All of it for
increasingly diminishing returns.

So I ended up abandoning Nixos. The final nail in the coffin was when I got
a job and had to build the in-house software on my machine, and none of it
were trivial examples, requiring deeper knowledge of packaging. Sure, I could
have spun up Ubuntu docker containers as a clutch, but why? The Nixos/Arch
way of setting up everything manually became too tedious anyways, and I
wanted something that _just worked._

I don't want to try to build a package from a github description just to find
out that my "snowflake distro" doesn't support a weird pseudostandard that
most of the other distros does. I also don't have time to configure every
little thing such as bluetooth modules or wifi, I want to have a starting
point that gets me the day-to-day features I need and _then_ configure my
tooling around that.

So I ended up installing PopOS.

## How I _currently_ use nix

The entirety of my Linux journey was:

> Kubuntu → Arch → Nixos → Popos

I had arrived back in the land of statefulness and I found myself longing
for just a little of that sweet reproducibility and declarability that I had
given up. I then recalled something that I had been researching before,
Home Manager. I never really got the point from my Nixos point of view,
but sitting on Popos it was a lifesaver. I quickly discovered that I could
have a "just works" distro with 80% of the reproducibility and benefits of
Nix with 20% of the headaches.

I could create a reproducible, declaritive toolbox using home manager and
let popos handle all the boring bells and whistles you'd expect from a modern
distro. This unfortunately meant that nix couldn't handle the system-level stuff
I _do_ want to configure like tweaking popos, setting up docker or routing
my traffic through a VPN. Sure, I won't have a 100% reproducibility this way,
however I save myself from almost all of the headaches. If anything should fail
the "Nix Way" I could easily fall back on statefully installing or configuring
whatever program I needed on the fly, so I always had an "escape hatch".

I gained the ability to bring my toolbox on any unix[^2] machine with just
two commands:

```sh
  # Install Nix
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Install configuration using flakes for the chosen "$MACHINE" (like "work-laptop")
  nix run home-manager/master -- switch -b backup --flake .#"$MACHINE"
```

This is great! I can now have my toolbox on my work laptop, home laptop,
NAS or even my steam deck, no matter the flavor of linux they're running.

Here is some of the uses I happily use nix for today:

- As a build-tool geared for reproducibility for various software projects
- I use a [nix
  flake](https://gist.github.com/rasmus-kirk/c56267f2256a5b1326eefdcb2da33d92)
  to reproducibly compile pandoc-flavoured markdown into a pdf[^3]. It can also
  run a script that waits for `$file.md` files to change and then compile
  it into `$file.pdf`.
- I use [home-manager](<!-- TODO: insert link -->) to manage all my dotfiles
  and user-level packages.
- I use Nixos on my NAS to host various services.
- Both my home-manager and nixos configurations are declared in a single
  [flake](<!-- TODO: insert link -->).

Using nix is software heaven when it works, but as soon as you stray from the
"happy path" you quickly find your way to software hell. While I learned a
lot from my own journey, and _now_ certainly find myself comfortable using
this complicated, messy but altogether wonderful tool, I find that some
people new to nix are tempted to follow the same path that I did, but the
"hard way" isn't always better. So don't use nixos, _use nix_.

[^1]: Note that this is using the "new" experimental features: `nix-command`
      and `flakes`
[^2]: If I used a mac then not _all_ packages will be available, but you get
      the point
[^3]: On that same note, I am using nix and pandoc-flavored markdown to
      build this very site!
