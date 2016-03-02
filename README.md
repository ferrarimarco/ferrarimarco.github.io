# personal-website
This is the source code of my personal website: http://ferrarimarco.info

It was scaffolded with [Yeoman](http://yeoman.io/) using [generator-webapp]([https://github.com/yeoman/generator-webapp]).

## Dependencies
Check the [package.json](../blob/master/package.json) descriptor. you basically need:
- Node.js (>= 0.12.0)
- gulp (>= 3.9.0)

## How to run
To start developing, run:

```sh
$ gulp serve
```

This will start local web server, open http://localhost:9000 in your default browser and watch files for changes, reloading the browser automatically.

To make a production-ready build of the app, run:

```sh
$ gulp
```

To preview the production-ready build to check if everything, run:

```sh
$ gulp serve:dist
```
