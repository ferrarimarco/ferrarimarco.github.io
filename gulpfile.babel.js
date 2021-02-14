'use strict'

import gulp from 'gulp'
// Loads the plugins without having to list all of them, but you need
// to call them as $.pluginname
import gulpLoadPlugins from 'gulp-load-plugins'
// Delete stuff
import del from 'del'
// Used to run shell commands
import shell from 'shelljs'
// BrowserSync is used to live-reload your website
import browserSync from 'browser-sync'
// AutoPrefixer
import autoprefixer from 'autoprefixer'
// Yargs for command line arguments
import { argv } from 'yargs'

const $ = gulpLoadPlugins()
const reload = browserSync.reload

const basePaths = {
  dest: 'docs',
  publish: '.publish',
  tmp: '.tmp'
}

const paths = {
  assetsBuilt: basePaths.tmp + '/assets-built',
  destAssets: basePaths.dest + '/assets',
  destFavicon: basePaths.dest + '/favicon.ico',
  jekyllBuilt: basePaths.tmp + '/jekyll-built',
  jekyllPreprocessedSrc: basePaths.tmp + '/jekyll-preprocessed-src'
}

// Handle SIGINT (example: sent via CTRL-C)
process.on('SIGINT', function () {
  setTimeout(function () {
    process.exit(1)
  }, 500)
})

// 'gulp clean:assets' -- deletes all assets except for images and favicon
// 'gulp clean:dist' -- erases the dist directory
// 'gulp clean:publish' --  deletes the .publish directory
// 'gulp clean:jekyll-built' -- deletes the jekyll-built directory
// 'gulp clean:jekyll-metadata' -- deletes the metadata file for Jekyll
// 'gulp clean:jekyll-preprocessed-src' -- deletes the jekyll build source
// 'gulp clean' -- cleans the project
gulp.task('clean:assets', () => {
  return del([paths.assetsBuilt + '/**/*', paths.assetsBuilt, paths.destAssets, paths.destFavicon])
})
gulp.task('clean:dist-jekyll', () => {
  return del([
    basePaths.dest + '/**/*',
    '!' + basePaths.dest,
    '!' + paths.destAssets,
    '!' + basePaths.dest + '/assets',
    '!' + paths.destAssets + '/**/*',
    '!' + paths.destFavicon]
  )
})
gulp.task('clean:dist', () => {
  return del([basePaths.dest + '/**/*'])
})
gulp.task('clean:publish', () => {
  return del([basePaths.publish])
})
gulp.task('clean:jekyll-built', () => {
  return del([paths.jekyllBuilt])
})
gulp.task('clean:jekyll-metadata', () => {
  return del(['src/.jekyll-metadata'])
})
gulp.task('clean:jekyll-preprocessed-src', () => {
  return del([paths.jekyllPreprocessedSrc + '/**/*', paths.jekyllPreprocessedSrc])
})
gulp.task('clean:jekyll', gulp.parallel(
  'clean:dist-jekyll',
  'clean:jekyll-built',
  'clean:jekyll-metadata',
  'clean:jekyll-preprocessed-src')
)
gulp.task('clean', gulp.parallel('clean:assets', 'clean:jekyll', 'clean:dist', 'clean:publish'))

// 'gulp jekyll-preprocessed-src' -- copies Jekyll data to temporary
// jekyll-preprocessed-src directory before running the source pre-processing
// tasks like inject:*
gulp.task('jekyll-preprocessed-src', () =>
  gulp.src(['src/**/*', '!src/assets/**/*', '!src/assets'])
    .pipe(gulp.dest(paths.jekyllPreprocessedSrc))
    .pipe($.size({ title: 'jekyll-preprocessed-src' }))
)

// 'gulp inject:head' -- injects our style.css file into the head of our HTML
gulp.task('inject:head', () =>
  gulp.src(paths.jekyllPreprocessedSrc + '/_includes/head.html')
    .pipe($.inject(gulp.src(paths.assetsBuilt + '/assets/stylesheets/*.css', { read: false }), { ignorePath: paths.assetsBuilt }))
    .pipe(gulp.dest(paths.jekyllPreprocessedSrc + '/_includes'))
)

// 'gulp inject:footer' -- injects our index.js file into the end of our HTML
gulp.task('inject:footer', () =>
  gulp.src(paths.jekyllPreprocessedSrc + '/_layouts/default.html')
    .pipe($.inject(gulp.src(paths.assetsBuilt + '/assets/javascript/*.js', { read: false }), { ignorePath: paths.assetsBuilt }))
    .pipe(gulp.dest(paths.jekyllPreprocessedSrc + '/_layouts'))
)

// 'gulp jekyll-build' -- builds your site with development settings
// 'gulp jekyll-build --prod' -- builds your site with production settings
gulp.task('jekyll-build', done => {
  let jekyllExecCommand = ''
  if (!argv.prod) {
    jekyllExecCommand = 'jekyll build'
  } else {
    jekyllExecCommand = 'jekyll build --config _config.yml,_config.build.yml'
  }

  if (shell.exec(jekyllExecCommand).code !== 0) {
    shell.echo('Error while running ' + jekyllExecCommand)
    shell.exit(1)
  }
  done()
})

// 'gulp copy:jekyll' -- copies jekyll site into the dist directory
gulp.task('copy:jekyll', () =>
  gulp.src(paths.jekyllBuilt + '/**/*')
    .pipe(gulp.dest(basePaths.dest))
)

// 'gulp html' -- does nothing
// 'gulp html --prod' -- minifies and gzips our HTML files
gulp.task('html', () =>
  gulp.src(basePaths.dest + '/**/*.html')
    .pipe($.if(argv.prod, $.htmlmin({
      removeComments: true,
      collapseWhitespace: true,
      collapseBooleanAttributes: true,
      removeAttributeQuotes: false,
      removeRedundantAttributes: true
    })))
    .pipe($.if(argv.prod, $.size({ title: 'optimized HTML' })))
    .pipe($.if(argv.prod, gulp.dest(basePaths.dest)))
    .pipe($.if(argv.prod, $.gzip({ append: true })))
    .pipe($.if(argv.prod, $.size({
      title: 'gzipped HTML',
      gzip: true
    })))
    .pipe($.if(argv.prod, gulp.dest(basePaths.dest)))
)

// 'gulp jekyll' -- cleans destinations and builds your site with development settings
// 'gulp jekyll --prod' -- cleans destinations and builds your site with production settings
gulp.task('jekyll', gulp.series(
  'clean:dist-jekyll',
  'clean:jekyll-built',
  'clean:jekyll-preprocessed-src',
  'jekyll-preprocessed-src',
  'inject:head',
  'inject:footer',
  'jekyll-build',
  'copy:jekyll',
  'html'
))

// 'gulp styles' -- creates a CSS file from your SASS, adds prefixes and
// creates a Sourcemap
// 'gulp styles --prod' -- creates a CSS file from your SASS, adds prefixes and
// then minifies, gzips and cache busts it. Does not create a Sourcemap
gulp.task('styles', () =>
  gulp.src('src/assets/scss/style.scss')
    .pipe($.if(!argv.prod, $.sourcemaps.init()))
    .pipe($.sass({
      precision: 10
    }).on('error', $.sass.logError))
    .pipe($.postcss([
      autoprefixer()
    ]))
    .pipe($.size({
      title: 'styles',
      showFiles: true
    }))
    .pipe($.if(argv.prod, $.rename({ suffix: '.min' })))
    .pipe($.if(argv.prod, $.if('*.css', $.cssnano({ autoprefixer: false }))))
    .pipe($.if(argv.prod, $.size({
      title: 'minified styles',
      showFiles: true
    })))
    .pipe($.if(argv.prod, $.rev()))
    .pipe($.if(!argv.prod, $.sourcemaps.write('.')))
    .pipe($.if(argv.prod, gulp.dest(paths.assetsBuilt + '/assets/stylesheets')))
    .pipe($.if(argv.prod, $.if('*.css', $.gzip({ append: true }))))
    .pipe($.if(argv.prod, $.size({
      title: 'gzipped styles',
      gzip: true,
      showFiles: true
    })))
    .pipe(gulp.dest(paths.assetsBuilt + '/assets/stylesheets'))
    .pipe($.if(!argv.prod, browserSync.stream({ match: '**/*.css' })))
)

// 'gulp scripts' -- creates a index.js file from your JavaScript files and
// creates a Sourcemap for it
// 'gulp scripts --prod' -- creates a index.js file from your JavaScript files,
// minifies, gzips and cache busts it. Does not create a Sourcemap
gulp.task('scripts', () =>
  // NOTE: The order here is important since it's concatenated in order from
  // top to bottom, so you want vendor scripts etc on top
  gulp.src([
    'src/assets/javascript/vendor.js',
    'src/assets/javascript/main.js'
  ])
    .pipe($.newer(
      paths.assetsBuilt + '/assets/javascript/index.js',
      { dest: paths.assetsBuilt + '/assets/javascript', ext: '.js' }
    ))
    .pipe($.if(!argv.prod, $.sourcemaps.init()))
    .pipe($.concat('index.js'))
    .pipe($.size({
      title: 'scripts',
      showFiles: true
    }))
    .pipe($.if(argv.prod, $.rename({ suffix: '.min' })))
    .pipe($.if(argv.prod, $.if('*.js', $.uglify())))
    .pipe($.if(argv.prod, $.size({
      title: 'minified scripts',
      showFiles: true
    })))
    .pipe($.if(argv.prod, $.rev()))
    .pipe($.if(!argv.prod, $.sourcemaps.write('.')))
    .pipe($.if(argv.prod, gulp.dest(paths.assetsBuilt + '/assets/javascript')))
    .pipe($.if(argv.prod, $.if('*.js', $.gzip({ append: true }))))
    .pipe($.if(argv.prod, $.size({
      title: 'gzipped scripts',
      gzip: true,
      showFiles: true
    })))
    .pipe(gulp.dest(paths.assetsBuilt + '/assets/javascript'))
    .pipe($.if(!argv.prod, browserSync.stream({ match: '**/*.js' })))
)

// 'gulp images' -- optimizes and caches your images
gulp.task('images', () =>
  gulp.src('src/assets/images/**/*')
    .pipe($.cache($.imagemin({
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest(paths.assetsBuilt + '/assets/images'))
    .pipe($.size({ title: 'images' }))
)

// 'gulp favicon' -- copies your favicon to the temporary assets directory
gulp.task('favicon', () =>
  gulp.src('src/assets/favicon.ico')
    .pipe(gulp.dest(paths.assetsBuilt))
    .pipe($.size({ title: 'favicon' }))
)

// 'gulp copy:assets' -- copies the assets into the dist directory
gulp.task('copy:assets', () =>
  gulp.src(paths.assetsBuilt + '/**/*')
    .pipe(gulp.dest(basePaths.dest))
)

// 'gulp assets' -- cleans out your assets and rebuilds them
// 'gulp assets --prod' -- cleans out your assets and rebuilds them with production settings
gulp.task('assets', gulp.series(
  gulp.series('clean:assets'),
  gulp.parallel('styles', 'scripts', 'images', 'favicon'),
  gulp.series('copy:assets')
))

// 'gulp doctor' -- literally just runs jekyll doctor
gulp.task('jekyll:doctor', done => {
  if (shell.exec('jekyll doctor').code !== 0) {
    shell.echo('Error: jekyll doctor found issues! Exiting...')
    shell.exit(1)
  }
  done()
})

// 'gulp check' -- checks your Jekyll configuration for errors and lint HTML
gulp.task('check', gulp.series('jekyll:doctor'))

// 'gulp build' -- same as 'gulp' but doesn't serve your site in your browser
// 'gulp build --prod' -- same as above but with production settings
gulp.task('build',
  gulp.series('clean', 'assets', 'jekyll', 'check')
)

// 'gulp serve' -- open up your website in your browser and watch for changes
// in all your files and update them when needed
gulp.task('serve', () => {
  browserSync({
    server: {
      baseDir: [paths.assetsBuilt, paths.jekyllBuilt]
    }
  })

  // Watch various files for changes and do the needful
  gulp.watch(
    ['src/**/*.md', 'src/**/*.html', 'src/**/*.yml', '*.yml'],
    { usePolling: true },
    gulp.series('jekyll', function (done) {
      reload()
      done()
    }))
  gulp.watch('src/assets/**/*', { usePolling: true }, gulp.series('assets'), function (done) {
    reload()
    done()
  })
})

// 'gulp serve' -- open up your website in your browser and watch for changes
// in all your files and update them when needed
gulp.task('serve-dest', () => {
  browserSync({
    server: {
      baseDir: [basePaths.dest]
    }
  })
})

// 'gulp' -- cleans your assets, gzipped files and temp files, creates your assets and
// injects them into the templates, builds the site with Jekyll and serves it
// 'gulp --prod' -- same as above but with production settings
gulp.task('default', gulp.series('build', 'serve'))

gulp.task('build-serve-dest', gulp.series('build', 'serve-dest'))
