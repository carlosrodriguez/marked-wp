# Modules
path = require 'path'
fs = require 'fs'
lodash = require 'lodash'
util = require 'util'
file = require 'file'

# Custom modules
config = require('./config.js').config()
marked = require './marked.js'

# Settings
# posts = path.join __dirname, '~/work/sandbos/carlosrodriguez-me/wordpress/posts/'


# readFiles
exports.readFiles = (cb) ->
	data = []
	console.log config
	files = file.walkSync config.posts, (test, dirPath, files, dirs) ->
		lodash.each files, (file) ->
			ext = path.extname config.posts + file
			if ext == ".md"
				data.push marked.renderMarkdown config.posts + file
		return 

	cb data
	