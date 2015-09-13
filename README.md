# apm

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with atom](#setup)
    * [What apm affects](#what-apm-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module extends the `package` provider to install Atom plugins using the Atom Package Management(apm) tool,
these include parser and syntax highlighting plugins.

## Setup

To begin ensure that `apm` tool is on your path by testing it with the appropriate
`where apm` or `which apm` command depending on your operating system and then install the module
~~~
$ puppet module install [--modulepath <PATH>] cyberious/apm
~~~

### What apm affects

* Manages plugins via the Atom Package Management system
* Requires Atom and command line tools to be previously installed

## Usage

As a Puppet user probably one of the first things you will want to do is install 'lanaguage-puppet' plugins

~~~puppet
package { 'language-puppet':
  ensure   => latest,
  provider => apm,
}
~~~

## Reference

### provider => apm

Extends the `package` provider and implements `:versionable`, `:installable`, `:upgradeable`, and `:uninstallable`

## Limitations

Plugins are only installed as part of the local and not global
There are no limitations as far as OS other than it must be supported by Atom and have the apm tool installed

## Development

Please create issues to go with any pull requests.  All code must should adhere to Puppet
style guides
