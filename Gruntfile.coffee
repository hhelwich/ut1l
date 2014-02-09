workDir = "build"
srcDir = "src"
testSrcDir = "test"
{name} = require "./package"


module.exports = (grunt) ->

  pkg = grunt.file.readJSON "package.json"

  browsers = []
  browsers.push browser for browser in ({browserName: "iphone", version: "#{vers}"} for vers in [4, "5.0", "5.1", "6.0", "6.1", 7])
  browsers.push browser for browser in ({browserName: "android", version: "#{vers}"} for vers in ["4.0"])
  browsers.push browser for browser in ({browserName: "safari", version: "#{vers}"} for vers in [5..7])
  browsers.push browser for browser in ({platform: "XP", browserName: "opera", version: "#{vers}"} for vers in [11..12])
  browsers.push browser for browser in ({platform: "XP", browserName: "googlechrome", version: "#{vers}"} for vers in [26..31])
  browsers.push browser for browser in ({browserName: "firefox", version: "#{vers}"} for vers in [3..26])
  browsers.push browser for browser in ({browserName: "internet explorer", version: "#{vers}"} for vers in [6..11])

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
          files["#{workDir}/tests.js"] = ["#{workDir}/#{testSrcDir}/browser/src/**/*.js"]
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
          #hostname: "*"


    'saucelabs-jasmine':
      all:
        options:
          urls: ["http://127.0.0.1:9999/build/test/browser/jasmine/SpecRunner.html"]
          tunnelTimeout: 5
          build: process.env.TRAVIS_JOB_ID
          concurrency: 3
          browsers: browsers
          testname: "browser black box tests"
          tags: ["master"]


  # Loading dependencies
  for name of pkg.devDependencies
    if name != "grunt" and name != "grunt-cli" and (name.indexOf "grunt") == 0
      grunt.loadNpmTasks name

  grunt.registerTask "travis", ["clean", "coffee", "copy", "browserify", "uglify", "connect", "saucelabs-jasmine"]
  grunt.registerTask "dev", ["clean", "coffee", "copy", "browserify", "uglify", "connect", "watch"]
  grunt.registerTask "default", ["dev"]

