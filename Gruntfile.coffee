module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        files:
          'app.js': 'app.coffee'

    coffeelint:
      src: ['app.coffee']
      options:
        configFile: '.coffeelintrc'

  grunt.initConfig config

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  grunt.registerTask('compile', ['coffee:compile'])
  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('test', ['lint'])
