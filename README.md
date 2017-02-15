# Atom Autocomplete+ Ruby Suggestions
[![Dependency status](https://david-dm.org/ianhattendorf/autocomplete-ruby.svg)](https://david-dm.org/ianhattendorf/autocomplete-ruby)
[![GitHub version](https://badge.fury.io/gh/ianhattendorf%2Fautocomplete-ruby.svg)](http://badge.fury.io/gh/ianhattendorf%2Fautocomplete-ruby)

Provides intelligent code completion for Ruby. Requires [RSense](https://github.com/rsense/rsense) and [Autocomplete+](https://github.com/atom-community/autocomplete-plus).

## Status
Currently pre-alpha, buggy and not fully implemented. All help is welcome.

Note: It doesn't seem like [RSense](https://github.com/rsense/rsense) is being developed any more. Any bugs/issues related to rsense itself will need to be reported in that repo, and probably won't be fixed.

## Why?
Because I wanted Ruby code completion in Atom and [atom-rsense](https://github.com/rsense/atom-rsense) is broken and hasn't been updated since June 2014.

## Installation
Make sure you have Java installed on your machine.

Install rsense:
```shell
$ gem install rsense
```

If you get an error about not being able to find `rsense` after opening a ruby file, you will need to set the path to the rsense binary in the plugin settings. The path is different depending on which OS/Ruby environment manager you are using. Executing `which rsense` or `gem environment` might help you locate it.

## Usage
Just type some stuff, and autocomplete+ will automatically show you some suggestions.

Note: If you use Winows, it might take about 10 seconds after the first suggestions pop up before rsense will give you any suggestions.

## Bugs
A lot. If you're brave enough to try this out and notice any specifically, feel free to open an issue or even better submit a pull request.

## Development
Clone the repository into your working directory:
```shell
$ git clone git@github.com:ianhattendorf/autocomplete-ruby.git
```

Install dependencies:
```shell
$ cd autocomplete-ruby
$ apm install
```

Link to Atom as a dev package:
```shell
$ apm link --dev
```

Feel free to fork it and submit a pull request for any changes you make.
