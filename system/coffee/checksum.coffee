crypto = require 'crypto'
util = require 'util'


class Checksum
	flatten: (obj) ->
		_self = @
		return ""  unless obj?
		return obj  if typeof obj is "string"
		return String(obj)  if typeof obj is "number"
		return obj.toGMTString()  if util.isDate(obj)
		if util.isArray(obj)
			return obj.map((item) ->
				_self.flatten item
			).join(",")
		Object.keys(obj).sort().map((prop) ->
			prop + ":" + _self.flatten(obj[prop])
		).join ";"

	create: (obj) ->
		md5 = crypto.createHash("md5")
		md5.update @flatten(obj), "utf8"
		md5.digest "hex"


module.exports = Checksum