file = require 'file'
fs = require 'fs'
wordpress = require 'wordpress'
_ = require 'lodash'

# Custom modules
config = require('./config.js').config()
Checksum = require './checksum.js'

checksum = new Checksum

client = wordpress.createClient config

class Assets

	getAssets: (cb) ->
		client.call 'gw.getResources', (error, resources) ->
			if error
				return cb(error)
			cb null, resources

	getFiles: (cb) ->
		data = []
		files = file.walkSync config.assets, (test, dirPath, files, dirs) ->
			_.each files, (file) ->
				data.push  config.assets + file
			return 

		cb data

	publishAssets: (cb) ->
		console.log 'Processing assets.'
		_self = @

		@getAssets (error, assets) ->
			_self.getFiles (files) ->
				_.each files, (file) ->
					content = fs.readFileSync file, 'base64'
					checkSum = checksum.create content
					
					if file of assets and checkSum is assets[file]
						console.log 'Skiping ' + file + ' already up-to-date.'
						delete assets[file]
					else
						console.log 'New file. Publish it'
						_self.publishAsset file, content
	
	publishAsset: (filepath, content, cb) ->
		console.log filepath
		file = _.last filepath.split '/'
		console.log 'Publishing: ',file
		client.authenticatedCall 'gw.addResource', '/images/' + file, content, (error, checksum) ->
			if error
				console.log 'Error publishing /images/' + file
				# return cb(error)
			console.log 'Published /images/' + file
		# fn null, checksum


module.exports = Assets