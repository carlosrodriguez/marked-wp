fetchMetadata = (content) ->
	pos1 = content.indexOf(MD_TOKEN_START) + MD_TOKEN_START.length
	pos2 = content.indexOf(MD_TOKEN_END, pos1)
	metaData = content.substring(pos1, pos2)
	metaData

marked = require 'marked'
_ = require 'lodash'

MD_TOKEN_START = "---"
MD_TOKEN_END = "---"

module.exports.metadata = (content, parser) ->
	md = fetchMetadata(content).trim()
	if parser
		parser md
	else
		md

module.exports.content = (content) ->
	metaData = fetchMetadata(content)
	content.replace(MD_TOKEN_START + metaData + MD_TOKEN_END, '').trimLeft()

module.exports.heading = (content) ->
	content = module.exports.content(content)
	items = marked.lexer(content)
	i = 0

	while i < items.length
		return items[i].text  if items[i].type is "heading" and items[i].depth is 1
		++i
	null

module.exports.title = module.exports.heading