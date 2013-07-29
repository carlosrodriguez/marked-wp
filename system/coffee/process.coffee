request = require 'request'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
http = require 'http'
_ = require 'lodash'
util = require 'util'
wordpress = require 'wordpress'

# Custom modules
Assets = require './assets.js'
Checksum = require './checksum.js'
render = require './render.js'
config = require './config.js'

checksum = new Checksum

client = wordpress.createClient config.config()

# Setup JSON file reader
require.extensions['.json'] = (m) ->
	m.exports = JSON.parse fs.readFileSync m.filename 
	return

saveAssets = () ->
	assets = new Assets
	assets.publishAssets()
	# client.authenticatedCall "gw.addResource", assets, content, (error, checksum) ->
	# 	if error
	# 		console.log error
	# 		return false
		
	# 	console.log "Published " + assets + "."
	# 	fn null, checksum


getCurrentPosts = (cb) ->
	client.call "gw.getPostPaths", "any", (error, postPaths) ->
		if error
			console.log "Error getting posts"
			return cb error
		console.log postPaths
		cb()

savePost = (post) ->
	console.log post

	if(post.id)
		# Post exist, check if needs to be modified
		console.log "Post exits - Checksum"
		console.log checksum.create post
		console.log "Need to set the update method here. Use checksum to check differences"
	else
		console.log 'set it'
		client.newPost post, (error, id) ->
			content = fs.readFileSync post.source, "utf8"
			fs.writeFile post.source, content.replace "---", "---\nid: " + id + "\nstatus: publish"
			return

render.readFiles (data) -> 
	getCurrentPosts (error) ->
		if error
			return console.log 'There was an error getting the current posts from Wordpress.'
		saveAssets()
		_.each data, savePost
	return
