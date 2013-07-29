lodash = require 'lodash'
fs = require 'fs'
path = require 'path'

dir = path.join __dirname, '../../'

_login = JSON.parse fs.readFileSync dir + "_login.js"

exports.config = () ->
	config = 
		author: "Carlos Rodriguez"
		url: "10.0.0.5"
	lodash.extend config, _login