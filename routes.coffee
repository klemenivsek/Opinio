Router.configure(
	loadingTemplate: 'loading'
)

Router.route('login',
	path: '/login'
	action: () ->
		this.render()
)

Router.route('home',
	template: 'list'
	path: '/'
	layoutTemplate: 'base'
	waitOn: () ->
		Meteor.subscribe('images')
		Meteor.subscribe('users')
		Meteor.subscribe('userNotifications', Meteor.userId())
		Meteor.subscribe('debatesWithoutContent')
		Meteor.subscribe('debateDetails')
	action: () ->
		this.render()
	fastRender: true
)

Router.route('topic',
	path: '/topic/:_id'
	layoutTemplate: 'base'
	waitOn: () ->
		debateID = this.params._id
		Meteor.subscribe('users')
		if Meteor.userId()
			Meteor.subscribe('userNotifications', Meteor.userId())
		Meteor.subscribe('debate', debateID)
		Meteor.subscribe('debateComments', debateID)
		Meteor.subscribe('debateReplies', debateID)
		Meteor.subscribe('debateVotes', debateID)
		Meteor.subscribe('debateReplyVotes', debateID)
	data: () ->
		App.currentDebateID = this.params._id
		selector = window.location.hash.substring(1)
		if selector
			parts = selector.split(':')
			App.currentSelect = {
				name: parts[0]
				id: parts[1]
			}
		else
			App.currentSelect = null
		return {debateID: this.params._id}
	action: () ->
		this.render()
	fastRender: true
)

Router.route('embed',
	path: '/embed/:_id'
	waitOn: () ->
		debateID = this.params._id
		Meteor.subscribe('users')
		if Meteor.userId()
			Meteor.subscribe('userNotifications', Meteor.userId())
		Meteor.subscribe('debate', debateID)
		Meteor.subscribe('debateComments', debateID)
		Meteor.subscribe('debateReplies', debateID)
		Meteor.subscribe('debateVotes', debateID)
		Meteor.subscribe('debateReplyVotes', debateID)
	data: () ->
		App.currentDebateID = this.params._id
		return {debateID: this.params._id}
	action: () ->
		this.render()
	fastRender: true
)

Router.route('preferences',
	path: '/preferences'
	layoutTemplate: 'base'
	waitOn: () ->
		Meteor.subscribe('users')
		if Meteor.userId()
			Meteor.subscribe('userNotifications', Meteor.userId())
	data: () ->
		return {}
	action: () ->
		this.render()
	fastRender: true
)

Router.route('profile',
	path: '/profile/:_id?'
	layoutTemplate: 'base'
	waitOn: () ->
		userID = this.params._id || Meteor.userId()
		Meteor.subscribe('users')
		Meteor.subscribe('userProfile', userID)
		if Meteor.userId()
			Meteor.subscribe('userNotifications', Meteor.userId())
	data: () ->
		userID = this.params._id || Meteor.userId()
		return {userID: userID}
	action: () ->
		this.render()
	fastRender: true
)

Router.route('demo',
	path: '/demo'
	waitOn: () ->
		Meteor.subscribe('debates')
	action: () ->
		this.render()
	fastRender: true
)
