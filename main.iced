fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
Stampery = require 'stampery'

class Stamper
  constructor : (params) ->
    @file = params.path
    @proofsDir = params.proofsDir
    await mkdirp path.resolve("#{@proofsDir}#{@file.split('/').slice(0, -1).join('/')}"), defer err

    @stampery = new Stampery params.secret
    @stampery.on 'proof', @proofStore
    @stampery.on 'ready', @stampery.receiveMissedProofs

  receiver : =>
    stream = fs.createReadStream @file
    await @stampery.hash stream, defer digest
    @stampery.stamp digest

  proofStore : (hash, proof) =>
    proofFile = path.resolve "#{@proofsDir}#{@file}.proof"
    line = "#{new Date()}\t#{hash}\t{JSON.stringify proof}"
    try
      fs.appendFile proofFile, line
    catch e
      fs.writeFile proofFile, line, 'utf8'

module.exports = Stamper
