workDir = "build"
srcDir = "src"
testSrcDir = "test"
{name} = require "./package"


module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON "package.json"

    clean: ["#{workDir}/**/*.js"]

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

    mochacov:
      unit:
        options:
          reporter: "spec"
      coverage:
        options:
          reporter: "mocha-term-cov-reporter"
          coverage: true
      coveralls:
        options:
          coveralls:
            serviceName: "travis-ci"
            repoToken: "WesptL0TOfo5X8P33s8yV0c88nNMSp5GN"
      options:
        files: "#{workDir}/**/*.js"

    copy:
      markup:
        src: "*.md"
        dest: "#{workDir}/#{srcDir}/"

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

    karma:
      unit:
        options:
          files: ["build/ut1l.js", "build/tests.js"]
        singleRun: true
        browsers: ["PhantomJS"]
        frameworks: ["jasmine"]

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-karma"


  grunt.registerTask "default", ["clean", "coffee", "copy", "browserify", "uglify", "karma"]

  grunt.registerTask "travis", ["clean", "coffee", "mochacov", "copy"]

