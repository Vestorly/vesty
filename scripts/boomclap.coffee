# Description:
#   Keep track of how many cents are left over from lunch
#
# Dependencies:
#   None
#
# Commands:
#   looking for cents - tells you who has cents
#   <number> available - money available for grabs
#   lunchtime  is over - clears the data for the day
#   taking <number> from <user> - subtract that from user
#
# Author:
#   polycarpou

class BoomClap
  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.boomclap
        @cache = @robot.brain.data.boomclap

  set: (user, amount) ->
    @cache[user] = amount
    @robot.brain.data.boomclap = @cache

  take: (user, amount) ->
    return [false, "#{user} didnt have cents today"] if !@cache[user]
    if @cache[user] - amount >= 0
      @cache[user] -= amount
      @robot.brain.data.boomclap = @cache
      return [true, "#{user} has #{@cache[user].toFixed(2)} left"]
    else
      return [false, "#{user} doesnt have enough cents"]

  clear: ->
    @cache = {}
    @robot.brain.data.boomclap = @cache

  all: ->
    @cache

module.exports = (robot) ->
  boomclap = new BoomClap robot

  robot.hear /(\d?(\.\d{1,2}?)) available*/i, (res) ->
    amount = +res.match[1]
    name = res.message.user.name
    res.send "thanks for the #{amount}, #{name}"
    boomclap.set(name, amount)

  robot.respond /lunchtime is over/i, (res) ->
    boomclap.clear()
    res.send 'clearing boomclap'

  robot.hear /looking for cents/i, (res) ->
    hash = boomclap.all()
    res.send "ok here is the situation"
    for name, amount of hash
      res.send "#{name}: #{amount.toFixed(2)}"

  robot.hear /(\d?(\.\d{1,2}?)) from @?([\w .\-]+)\?*$/i, (res) ->
    amount = +res.match[1]
    nameInput = res.match[3].trim()
    if !nameInput
      res.send "could not find user #{nameInput}"
      return
    [ok, message] = boomclap.take(nameInput, amount)
    res.send message
