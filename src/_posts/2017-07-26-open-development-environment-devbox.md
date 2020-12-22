---
layout: post
date: 2017-07-26
title: An Automatically Configured Development Box
categories: development devops configuration
tags:
  - ansible
  - docker
  - vagrant
---

In the past months I was assigned a new task at work, that essentially boiled
down to this question: *how can we simplify the deployment of new development
workstations?*

In my development team at the time, we were tired of repeating the same (mostly
manual and not documented) steps. The configuration process resulted in
different development environment leading to confusion (it works on my machine!)
and deployment issues.

## Baseline

We were in the situation where each developer, depending on his/her experience,
installed and configured a set of development tools at his/her own will.
This process was largely undocumented (READMEs were Holy Grails) and led to all
sort of environment disparity issues. Moreover the configuration could not be
easily changed because of the fear of breaking something. For the same reason
no one actually bothered to install upgrades for such tools (we had
someone who was stuck on a 3-years-ago Eclipse version!).

## List of Requirements

1. Automated Setup: there must be no manual steps involved in the setup of a
workstation
1. Versioning: the configuration should be stored in a Version Control System
1. Reproducibility: the setup process of a new workstation should be easily
reproducible
1. Environments should be ephemeral: each instance should be easily created and
destroyed without any loss of configuration
1. Minimize the time needed to spin up a new instance

## Research

After some research, I could not find a out-of-the-box solution or even a set of
established best practices to follow. Everyone was (is?) focusing on
*development environments* and not on the configuration process of the
development tools.

## Solution

This solution ([ferrarimarco/open-development-environment-devbox][1]) is a
process that produces a packaged machine with the needed tools already installed
and ready to be used. For a list of the available tools refer to the README in
[ferrarimarco/open-development-environment-devbox][1].

Some of the included tools run inside [Docker][5] containers to ease and speed up the
setup and deployment.

### Build

To automate the creation of images for various platforms I implemented a
[Packer][2] template to execute the following tasks:

1. Provision a new machine
1. Start the new machine
1. Install the Operating System
1. Configure the running instance by running provisioning tools
1. Package the machine

I chose Packer because it let me write a recipe (a single JSON file called
*template*) to provision and configure the machine in a totally
automated way. I just run the `packer build` command to start the build process.

The other interesting Packer feature is that you can use multiple providers (
different hypervisors and/or cloud providers), multiple configuration methods (
shell scripts, [Ansible][4] playbooks, Chef recipes, etc.) and different post
processors to package the created images. This gives you maximum deployment
flexibility (i.e. start with a local virtualized environment and move to a cloud
based one in the future).

I chose to run the configuration process while building the image so I had to
execute this process only once per build and not every time an instance is
started.

### Configuration

The configuration process was implemented by developing a set of [Ansible][4] roles.
I decided to use a dedicated configuration tool ([Ansible][4]) instead of writing
shell scripts to avoid the complexity of ensuring the compatibility of such
scripts across multiple platforms. I also benefited from the built-in node
management mechanisms that these dedicated tools implement out-of-the-box.

The adoption of this kind of tools has the added plus of letting you reuse your
code on different platforms (Virtual Machines, Physical Machines) without much
effort. You just need to tell to such tools where your instances are and they
will do the rest.

### Deployment

For now I deployed instances of this Development Box in two ways:

1. Virtual Machines managed with [Vagrant][3] to manage
the life cycle of each instance. You can bring up a new instance in matter of
seconds with just `vagrant up` command;
1. Physical machines, by applying the same set of [Ansible][4] roles to a given
host. In this case [Vagrant][3] can be used as a development environment before
applying any role to the production node.

[1]: https://github.com/ferrarimarco/open-development-environment-devbox
[2]: https://www.packer.io
[3]: https://www.vagrantup.com
[4]: https://www.ansible.com/
[5]: https://www.docker.com/
