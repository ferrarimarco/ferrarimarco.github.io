---
layout: post
date: 2016-04-25
title: Install Ansible roles with Ansible!
categories: development devops provisioning
tags:
  - ansible
  - ruby
  - chruby
  - ruby-install
---

Before using any Ansible role in your playbook, that role must be already
available, otherwise the playbook is not even executed. For publicly available
roles it's as easy as running a command that downloads the desired role from
Ansible Galaxy:

```shell
ansible-galaxy install rolename
```
