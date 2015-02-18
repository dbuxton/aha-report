module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        files:
          'app.js': 'app.coffee'

  grunt.initConfig config

  grunt.loadNpmTasks('grunt-contrib-coffee');

  grunt.registerTask('compile', ['coffee:compile'])
