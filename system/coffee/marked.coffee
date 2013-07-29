# Modules
lodash = require 'lodash'
marked = require 'marked'
fs = require 'fs'
path = require 'path'

config = require './config.js'

setOptions = (opts) ->
	options =
		gfm: true
		tables: true
		breaks: false
		pedantic: false
		sanitize: true
		smartLists: true
		langPrefix: 'language-',
		highlight: (code, lang) ->
			if (lang == 'js') then highlighter.javascript code else code

	lodash.extend options, opts

# Get Mata Data
getMeta = (source) ->
	meta = require './meta.js'

	meta.metadata source, (md) ->
		retObj = {}
		md.split("\n").forEach (line) ->
			data = line.split(":")
			retObj[data[0].trim().toLowerCase()] = data[1].trim()

		retObj

# Render
exports.renderMarkdown = (source, opts) ->
	fileContents = fs.readFileSync source, "utf8"
	matchers =
		truncate: /\#{2}\!{2}truncate\s*[\n]?/,
		linkdef: /^ *\[([^\]]+)\]: *([^\s]+)(?: +["(]([^\n]+)[")])? *(?:\n+|$)/

	setOptions opts
	# Extract Meta information
	meta = lodash.extend config.config(), getMeta(fileContents)
	sourceContent = fileContents.replace /---(\n(.*))*---/g, ""
	tokens = marked.lexer sourceContent
	content = marked.parser tokens
	status = if (meta.status) then meta.status else "publish"
	post = 
		id: meta.id
		content: content
		author: meta.author
		title: meta.title
		status: status
		source: source
		date: new Date(meta.date)  if "date" of meta

	if "modified" of meta
		post.modified = new Date(meta.modified)

	post
	