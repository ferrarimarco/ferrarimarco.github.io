# personal-website
This is the source code of my personal website: http://ferrarimarco.info

It was scaffolded with [Yeoman](http://yeoman.io/) using [generator-webapp]([https://github.com/yeoman/generator-jekyllized]).

## Dependencies
Check the [package.json](../blob/master/package.json) descriptor. you basically need:
- Node.js (>= 5.10.1)
- gulp (>= 4.0.0)

### Install
If you have cloned this repo or want to reinstall, make sure there's no `node_modules` or `Gemfile.lock` folder/file and then run `npm install` and `bundle install`.

## To get started

```sh
$ gulp [--prod]
```

And you'll have a new Jekyll site generated for you and displayed in your browser. If you want to run it with production settings, just add `--prod`.

## Usage

```sh
$ gulp build [--prod]
```

```sh
$ gulp deploy
```
