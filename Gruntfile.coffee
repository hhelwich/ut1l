workDir = "build"
srcDir = "src"
testSrcDir = "test"
{name} = require "./package"


module.exports = (grunt) ->

  pkg = grunt.file.readJSON "package.json"

  browsers = [
    browserName: "firefox"
    version: "19"
    platform: "XP"
  ,
    browserName: "chrome"
    platform: "XP"
  ,
    browserName: "chrome"
    platform: "linux"
  ,
    browserName: "internet explorer"
    platform: "WIN8"
    version: "10"
  ,
    browserName: "internet explorer"
    platform: "VISTA"
    version: "9"
  ]

  grunt.initConfig


    clean: ["#{workDir}"]

    watch:
      files: [
        "Gruntfile.*"
        "#{srcDir}/**/*.coffee"
        "#{testSrcDir}/**/*.coffee"
      ]
      tasks: ["default"]

    # Transcompile CoffeeScript to JavaScript files
    coffee:
      main:
        options:
          bare: true
        cwd: "#{srcDir}"
        expand: true
        src: ["**/*.coffee"]
        dest: "#{workDir}/#{srcDir}"
        ext: ".js"
      test:
        options:
          bare: true
        cwd: "#{testSrcDir}"
        expand: true
        src: ["**/*.coffee"]
        dest: "#{workDir}/#{testSrcDir}"
        ext: ".js"


    copy:
      markup:
        src: "*.md"
        dest: "#{workDir}/#{srcDir}/"
      packageJson:
        src: "package.json"
        dest: "#{workDir}/#{srcDir}/"
      jasmine:
        src: ["test/**/*.html", "test/**/*.js", "test/**/*.css"]
        dest: "#{workDir}/"

    browserify:
      dist:
        files: do ->
          files = {}
          files["#{workDir}/#{name}.js"] = ["#{workDir}/#{srcDir}/index.js"]
          files
      tests:
        files: do ->
          files = {}
          files["#{workDir}/tests.js"] = ["#{workDir}/#{testSrcDir}/browser/**/*.js"]
          files

    uglify:
      dist:
        files:do ->
          files = {}
          files["#{workDir}/#{name}.min.js"] = ["#{workDir}/#{name}.js"]
          files

    connect:
      server:
        options:
          base: ""
          port: 9999


    'saucelabs-jasmine':
      all:
        options:
          urls: ["http://127.0.0.1:9999/build/test/browser/jasmine/SpecRunner.html"]
          tunnelTimeout: 5
          build: process.env.TRAVIS_JOB_ID
          concurrency: 3
          browsers: browsers
          testname: "pasta tests"
          tags: ["master"]


  # Loading dependencies
  for name of pkg.devDependencies
    if name != "grunt" and name != "grunt-cli" and (name.indexOf "grunt") == 0
      grunt.loadNpmTasks name

  grunt.registerTask "travis", ["clean", "coffee", "copy", "browserify", "uglify", "connect", "saucelabs-jasmine"]

