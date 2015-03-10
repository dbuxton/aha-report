module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    cjsx:
      compile:
        files:
          'app-react.js': 'app-react.coffee'

    coffeelint:
      src: ['app-react.coffee']
      options:
        configFile: '.coffeelintrc'

  grunt.initConfig config

  grunt.loadNpmTasks('grunt-coffee-react');
  grunt.loadNpmTasks('grunt-coffeelint-cjsx');

  grunt.registerTask('compile', ['coffee:compile'])
  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('test', ['lint'])
