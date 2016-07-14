fs = require 'fs'
Stampery = require 'stampery'

class Stamper
  constructor : (params) ->
    @file = params.path

    @stampery = new Stampery params.secret
    @stampery.on 'proof', @proofStore

  receiver : =>
    stream = fs.createReadStream @file
    await @stampery.hash stream, defer digest
    @stampery.stamp digest

  proofStore : (hash, proof) =>
    proofFile = path.resolve "#{@file}.proof"
    line = "#{new Date()}\t#{hash}\t{JSON.stringify proof}"
    try
      fs.appendFile proofFile, line
    catch e
      fs.writeFile proofFile, line, 'utf8'

module.exports = Stamper
