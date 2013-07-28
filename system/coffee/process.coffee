request = require 'request'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
http = require 'http'
lodash = require 'lodash'
util = require 'util'
wordpress = require 'wordpress'

# Custom modules
render = require './render.js'
config = require './config.js'

client = wordpress.createClient config.config()

# Setup JSON file reader
require.extensions['.json'] = (m) ->
	m.exports = JSON.parse fs.readFileSync m.filename 
	return

flatten = (obj) ->
	return ""  unless obj?
	return obj  if typeof obj is "string"
	return String(obj)  if typeof obj is "number"
	return obj.toGMTString()  if util.isDate(obj)
	if util.isArray(obj)
		return obj.map((item) ->
			flatten item
		).join(",")
	Object.keys(obj).sort().map((prop) ->
		prop + ":" + flatten(obj[prop])
	).join ";"

getCurrentPosts = () ->
	client.call "gw.getPostPaths", "any", (error, postPaths) ->
		if error
			console.log "Error getting posts"
			# return fn(error)
		console.log postPaths
		# fn null, postPaths

createChecksum = (obj) ->
	md5 = crypto.createHash("md5")
	md5.update flatten(obj), "utf8"
	md5.digest "hex"

savePost = (post) ->
	console.log post
	if(post.id)
		# Post exist, check if needs to be modified
		console.log "Post exits - Checksum"
		console.log createChecksum post
	else
		client.newPost post, (error, id) ->
			content = fs.readFileSync post.source, "utf8"
			fs.writeFile post.source, content.replace "<!--", "<!--\nid: " + id + "\nstatus: publish"
			return

render.readFiles (data) -> 
	getCurrentPosts()
	lodash.each data, savePost
	return
