fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
Stampery = require 'stampery'

class Stamper
  constructor : (params) ->
    @file = params.path
    @proofsDir = params.proofsDir
    @fileName = @file.split('/').pop()
    @path = path.resolve "#{@proofsDir}/#{@file.split('/').slice(0, -1).join('/')}"
    console.log "Proof path will be #{@path}"
    await mkdirp @path, defer err

    @stampery = new Stampery params.secret
    @stampery.on 'proof', @proofStore
    @stampery.on 'ready', @stampery.receiveMissedProofs

  receiver : ({cur}) =>
    await @stampery.hash cur.content, defer digest
    @stampery.stamp digest

  proofStore : (hash, proof) =>
    proofFile = path.resolve "#{@path}/#{@fileName}.csv"
    console.log "Storing proof as #{proofFile}"
    line = "#{new Date()};t#{hash};t#{JSON.stringify proof}\n"
    try
      fs.appendFile proofFile, line
    catch e
      fs.writeFile proofFile, line, 'utf8'

module.exports = Stamper
