fs = require 'fs'
module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		BSpkg: grunt.file.readJSON('bootstrap.json')
		BSbanner: '/*!\n' +
			' * Bootstrap v<%= BSpkg.version %> (<%= BSpkg.homepage %>)\n' +
			' * Copyright <%= grunt.template.today("yyyy") %> <%= BSpkg.author %>\n' +
			' * Licensed under <%= _.pluck(BSpkg.licenses, "url").join(", ") %>\n' +
			' */\n\n'
		BSjqueryCheck: 'if (typeof jQuery === "undefined") { throw new Error("Bootstrap requires jQuery") }\n\n'
		# CSS
		less:
			options:
				strictMath: true
				strictUnits: true
				sourceMap: false # We're going to be post-processing the compiled output
			css:
				src:  'css/rohbot.less'
				dest: 'build/css/rohbot.css'
		myth:
			css:
				src:  'build/css/rohbot.css'
				dest: 'build/style.css'
		recess:
			options:
				compile: true
			bootstrap:
				options:
					banner: '<%= BSbanner %>'
					compress: true
				src: 'css/bootstrap/bootstrap.less'
				dest: 'build/bootstrap.min.css'
		# JS
		coffeelint:
			options:
				configFile: 'coffeelint.json'
			js: ['js/**/*.coffee']
		coffee:
			classes:
				src: 'js/classes/*.coffee'
				dest: 'build/js/rohbot-classes.js'
			js:
				src:  'js/*.coffee'
				dest: 'build/js/rohbot-coffee.js'
		concat:
			options:
				stripBanners: false
			js:
				src:  ['build/js/rohbot-classes.js','build/js/rohbot-coffee.js', 'build/js/rohbot.js']
				dest: 'build/rohbot.js'
			jslib:
				src:  'jslib/*.min.js'
				dest: 'build/jslibs.min.js'
			bootstrap:
				options:
					banner: '<%= BSjqueryCheck %>'
				src: [
					'jslib/bootstrap/transition.js'
					'jslib/bootstrap/alert.js'
					'jslib/bootstrap/button.js'
					'jslib/bootstrap/carousel.js'
					'jslib/bootstrap/collapse.js'
					'jslib/bootstrap/dropdown.js'
					'jslib/bootstrap/modal.js'
					'jslib/bootstrap/tooltip.js'
					'jslib/bootstrap/popover.js'
					'jslib/bootstrap/scrollspy.js'
					'jslib/bootstrap/tab.js'
					'jslib/bootstrap/affix.js'
				]
				dest: 'build/bootstrap/<%= BSpkg.name %>.js'
		uglify:
			bootstrap:
				options:
					banner: '<%= BSbanner %>'
					report: 'min'
				src: '<%= concat.bootstrap.dest %>'
				dest: 'build/bootstrap.min.js'

		# templates
		htmlmin:
			options:
				collapseWhitespace: true
			templates:
				src: 'templates/*'
				dest: 'build/'
				expand: true
		hogan:
			templates:
				templates: 'build/templates/*.mustache'
				output: 'build/templates.js'
				binderName: 'hulk'
		# Other
		copy:
			js:
				src:  'js/*.js'
				dest: 'build/js/'
				expand:  true
				flatten: true
			img:
				src:  'img/rohbot.png'
				dest: 'dist/'
			bootstrap:
				src: 'fonts/*'
				dest: 'dist/'
				expand: true
				flatten: true
			index:
				src:  'index.htm'
				dest: 'build/'
			dist:
				src:  'build/*'
				dest: 'dist/'
				expand: true
				flatten: true
				filter: 'isFile'
		clean:
			dist:  'dist'
			build: 'build'

	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-recess'
	grunt.loadNpmTasks 'grunt-myth'
	grunt.loadNpmTasks 'grunt-coffeelint'
	grunt.loadNpmTasks 'grunt-hogan'

	grunt.registerTask 'default', [
		'setup'
		'clean:dist'
		'css'
		'js'
		'templates'
		'misc'
		'dist'
	]

	grunt.registerTask 'setup', () ->
		fs.mkdirSync 'build' unless fs.existsSync 'build'
		grunt.task.run 'concat:jslib' unless fs.existsSync 'build/jslibs.min.js'
		grunt.task.run 'bootstrap' unless fs.existsSync 'build/bootstrap.min.js'

	grunt.registerTask 'css', [
		'less:css'
		'myth:css'
	]

	grunt.registerTask 'js', [
		'coffeelint:js'
		'coffee:classes'
		'coffee:js'
		'copy:js'
		'concat:js'
	]

	grunt.registerTask 'templates', [
		'copy:index'
		'htmlmin:templates'
		'hogan:templates'
	]

	grunt.registerTask 'misc', [
		'copy:img'
	]

	grunt.registerTask 'dist', [
		'copy:dist'
	]

	grunt.registerTask 'bootstrap', [
		'copy:bootstrap',
		'recess:bootstrap',
		'concat:bootstrap',
		'uglify:bootstrap'
	]

