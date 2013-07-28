# Modules
path = require 'path'
fs = require 'fs'
lodash = require 'lodash'
util = require 'util'
file = require 'file'

# Custom modules
marked = require './marked.js'

# Settings
posts = path.join __dirname, '../../wordpress/posts/'			

# readFiles
exports.readFiles = (cb) ->
	data = []
	files = file.walkSync posts, (test, dirPath, files, dirs) ->
		lodash.each files, (file) ->
			ext = path.extname posts + file
			if ext == ".md"
				data.push marked.renderMarkdown posts + file
		return 

	cb data
	