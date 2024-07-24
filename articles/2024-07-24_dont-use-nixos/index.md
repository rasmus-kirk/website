---
title: Don't use NixOS
date: 2024-07-24
keywords: [nix, nixos, linux]
---

> You're on vacation and you wish to get some food. You find a restaurant,
> Ubuntu — an unusual name, perhaps African — but it's right next to your
> hotel. You enjoy the food and, feeling emboldened, you decide to try more
> places. You venture further out, trying different restaurants like Popos and
> Arch. Sure, each time the accent is a little heavier and harder to understand,
> but it's manageable.
>
> Finally, one day, you venture further than ever before and find a charming
> little place called Nixos. Greek, perhaps? No problem, you think. After your
> difficulties at Arch’s, this should be a piece of cake. But you quickly
> realize not a single person there speaks a word of English, not even Google
> Translate can save you. Desperately, you try to order anything, but nothing
> comes out right. Humbled, you walk back, cursing the restaurant for your
> terrible experience.

Many people tend to view [NixOS](https://nixos.org/) as "just another distro",
and therefore tend to jump straight from Ubuntu/Arch/whatever into NixOS, only
to then immediately start complaining that the learning curve is essentially
a great cliff. It has certainly been my own experience, but I will argue that
there are better ways to approach it.

Nix is definitely not an all-or-nothing. It essentially functions as a swiss
army knife that addresses the problem of:

> _"software runs on computer A, now make it run the same way on computer B"_

There are different "levels" of Nix:

- **Nix as a unix package manager:** Nixpkgs has over 80.000 packages so
  instead of using pacman, apt or homebrew to get your packages you can use
  Nix instead. Simply run `nix profile install nixpkgs#cowsay`[^1] to permanently
  install the cowsay package. This is particularly useful on debian-based
  systems, as apt has an annoyingly small package set. Think of it like the
  AUR for Arch, but on any distro - even MacOS!
- **Nix as a temporary package manager:** Want to quickly run a package but
  don't want to pollute your system environment with one-off packages? Write
  `nix shell nixpkgs#cowsay` to get a shell environment with the package
  cowsay. Want to just _run_ the binary in the cowsay package? Use 
  `nix run nixpkgs#cowsay`.
- **Nix as a build environment:** Ever had a repo or piece of code with
  poorly documented dependencies? Sometimes there are even hidden undeclared
  dependencies (package that may be default on Ubuntu but not on Arch!). You
  can include a Nix flake in your repo with build instructions such that anyone with
  Nix can run `nix build github:github-account/repo` to build your software.
- **Nix for a reproducible dotfile managements:** You can use [Home
  Manager](https://github.com/nix-community/home-manager) to create
  a _declarative_, _reproducible_ home environment containing all your
  dotfile configurations and all your packages. Quickly get all your tools,
  configured as you want on any unix-system in ~15 minutes.
- **NixOS for a reproducible linux system:** You can use Nix to configure your
  entire system: Declaratively install programs, configure and run services
  (Syncthing, Plex, whatever), configure user programs (like a tiling window
  manager), anything you want to do on a linux system, but _declaratively_.

Notice, you don't even have to switch out apt, homebrew or pacman/AUR for Nix,
nor do you have to manage two package managing states with Nix. You can choose
to only use it for temporary package environments (`nix run`/`nix shell`)
and temporary developments/build environments (`nix develop`/`nix build`).

Starting on a "lower level" of Nix would help out a lot and avoid a lot
of the more esoteric issues one might have on the "higher levels", while
reaping most of the same benefits. You certainly don't have to do what I did
and take the plunge directly on something as complex as NixOS, just to fall
down and faceplant the concrete below.

## How I used Nix

I started using NixOS after having to migrate my Arch configuration,
and finding everything a complete mess. What had I configured? What had I
installed? What state did I want to keep? Arch did not give me the proper
tools to organize this, and I considered writing a bash script myself that set
everything up. It seemed hacky and error-prone though, but then I discovered
NixOS and knew that this was exactly the tool I needed!

Learning to use NixOS was rough though. I spent a lot of time just getting
basic stuff to work, and this was despite coming from Arch. Everything had
to be done the "Nix Way", and as I maximized for reproducibility, I ended
up playing whack-a-mole with countless of tedious issues. All of it for
increasingly diminishing returns.

So I ended up abandoning NixOS. The final nail in the coffin was when I got
a job and had to build the in-house software on my machine, and none of it
were trivial examples, requiring deeper knowledge of packaging. Sure, I could
have spun up Ubuntu docker containers as a clutch, but why? The NixOS/Arch
way of setting up everything manually became too tedious anyways, and I
wanted something that _just worked._

I don't want to try to build a package from a github description just to find
out that my "snowflake distro" doesn't support a weird pseudostandard that
most of the other distros does. I also don't have time to configure every
little thing such as bluetooth modules or wifi, I want to have a starting
point that gets me the day-to-day features I need and _then_ configure my
tooling around that.

So I ended up installing PopOS.

## How I _currently_ use Nix

The entirety of my Linux journey was:

> Kubuntu → Arch → NixOS → PopOS

I had arrived back in the land of statefulness and I found myself longing
for just a little of that sweet reproducibility and declarability that I
had given up. I then recalled something that I had been researching before;
[Home Manager](https://github.com/nix-community/home-manager). I never really
got the point from my NixOS point of view, but sitting on PopOS it was a
lifesaver. I quickly discovered that I could have a "Just Works™" distro with
80% of the benefits of Nix with 20% of the headaches.

I could create a reproducible, declarative toolbox using home manager
and let PopOS handle all the boring bells and whistles you'd expect from
a modern distro. This unfortunately meant that Nix couldn't handle the
system-level stuff that I _do_ want to configure, like tweaking PopOS,
setting up docker or routing my traffic through a VPN. Sure, I won't have
a 100% reproducibility this way, however I save myself from almost all of
the pains I had previously. If anything should fail the "Nix Way" I could
easily fall back on statefully installing or configuring whatever program
I needed on the fly, so I always had an "escape hatch".

I gained the ability to bring my toolbox on any unix[^2] machine with just
two commands:

```sh
  # Install Nix
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Install configuration using flakes for the chosen "$MACHINE" (like "work-laptop")
  nix run home-manager/master -- switch -b backup --flake .#"$MACHINE"
```

This is great! I can now have my toolbox on my work laptop, home laptop,
NAS or even my Steam Deck, no matter the flavor of linux they're running.

Here is some of the uses I happily use Nix for today:

- As a build-tool geared for reproducibility for various software projects
- I use a [Nix
  flake](https://gist.github.com/rasmus-kirk/c56267f2256a5b1326eefdcb2da33d92)
  to reproducibly compile pandoc-flavoured markdown into pdf's[^3]. It can also
  run a script that waits for `$file.md` files to change and then compile
  it into `$file.pdf`.
- I use Home Manager to manage all my dotfiles and user-level packages.
- I use NixOS on my Raspberry Pi NAS to self-host various services.
- Both my home-manager and NixOS configurations are declared in a single
  [Nix flake](https://github.com/rasmus-kirk/nix-home-manager).

_Maybe_ you should use NixOS. I do, after all, still use it today on my
server. In that context it's excellent, I get to have a declarative server
environment with top-notch reproducibility, all without using Docker! But
just installing it on your main work machine is, in my opinion, not the
best way to use NixOS, nor is it the best way to get into Nix. It should be
reserved for situations where there's clear benefits or for enthusiasts.

Using Nix is software heaven when it works, but as soon as you stray from the
"happy path" you quickly find your way to software hell. While I learned a
lot from my own journey, and _now_ certainly find myself comfortable using
this complicated, messy but altogether wonderful tool, I find that some
people new to Nix are tempted to follow the same path that I did, but the
"hard way" isn't always best way. So don't use NixOS, _use Nix_.

> This article is also available [in raw markdown](./index.md)

> Discuss at [Hacker News](https://news.ycombinator.com/item?id=41057688)
  or [Reddit](https://old.reddit.com/r/NixOS/comments/1eb6tcf/dont_use_nixos/)

[^1]: Note that this is using the "new" experimental features: `nix-command`
      and `flakes`.
[^2]: If I ran MacOS then not _all_ packages will be available, as the
      program itself needs to also target Darwin, but you get the point.
[^3]: On that same note, I am using Nix and pandoc-flavored markdown to
      build this very site!
