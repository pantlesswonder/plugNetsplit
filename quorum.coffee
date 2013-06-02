EventEmitter = require('events').EventEmitter

#configuration
Q_CHAT = ":quorum" #text to send and look for in the chat
Q_CHAT_TIME = 10*60*1000 #how often to chat (in ms)
Q_CHECK_TIME = 11*60*1000 #how often to check for splits (in ms, must be greater than Q_CHAT_TIME)
Q_NODES = 3 #the number of nodes to use to check for quorum

class Quorum extends EventEmitter
	constructor: (@bot)->
		@state = {}
		@chatInterval = null
		@checkInterval = null

		_this = @
		@bot.on('roomChanged', ()->_this.reset())
		@bot.on('chat', (data)->_this.chatted(data))

	reset: ()->
		#clear intervals 
		clearInterval(@chatInterval)
		clearInterval(@checkInterval)

		#start our check and chat intervals, and 
		@chatInterval = setInterval(@chat, Q_CHAT_TIME)
		@checkInterval = setInterval(@check, Q_CHECK_TIME)
		@chat()

	chatted: (data)->
		if (Q_CHAT == data.message)
			if (!@state[data.from])
				@state[data.from] = {last: 0, count: 0}
			@state[data.from].last = new Date().getTime()
			@state[data.from].count++;

	chat: ()->
		@bot.chat(Q_CHAT)

	check: ()->
		#change the @state to a sorted list
		list = []
		list.push(value) for key, value of @state
		list.sort((a,b)->a.count-b.count)

		#go over the most reliable nodes and count how many have responded recently
		if list.length < Q_NODES/2
			@emit('split')
		else
			len = Math.min(Q_NODES, list.length)
			count = 0
			now = new Date().getTime()

			#check the top len elements to see if they've responded recently
			count++ for i in [0..len-1] when (now - Q_CHECK_TIME) < list[i].last

			#if we don't have at least half of the nodes reporting, we're split
			if count < (Q_NODES/2)
				@emit('split')

module.exports = Quorum;