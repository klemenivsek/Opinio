Comments = new Meteor.Collection 'comments'

App.models.Comments = Comments

Meteor.startup(() ->
	App.models.Notifications.addType('comment', {
		text: (data) ->
			return s.sprintf('<b><a href="/profile/%s">%s</a></b> wrote an <b><a href="/topic/%s#opinion:%s">opinion</a></b> in debate <b><a href="/topic/%s">%s</a></b>', data.fromUserID, data.fromUserName, data.debateID, data.commentID, data.debateID, data.debateTitle)

		title: (data) ->
			return 'New opinion in your debate'
	})
)

Comments.byID = (id) ->
	return Comments.findOne(
		_id: id
		hidden: false
	)

Comments.byDebate = (debateID) ->
	return Comments.find(
		debateID: debateID
		hidden: false
	)

Comments.byDebateAndSide = (debateID, side) ->
	return Comments.find(
		debateID: debateID
		side: side
		hidden: false
	)

Comments.byUser = (userID) ->
	return Comments.find(
		userID: userID
		hidden: false
	)

Comments.byUserInDebate = (userID, debateID) ->
	return Comments.find(
		userID: userID
		debateID: debateID
		hidden: false
	)

Comments.byUserSingle = (debateID, userID, side) ->
	return Comments.findOne(
		debateID: debateID
		userID: Meteor.userId()
		side: side
		hidden: false
	)

Comments.whereUserAgrees = (userID) ->
	commentIDs = _.pluck(App.models.Votes.byUser(userID).fetch(), 'commentID')
	return Comments.find(
		_id: {$in: commentIDs}
		hidden: false
	)

Meteor.methods(
	postComment: (debateID, content, side) ->
		if Meteor.userId() and content.length > 0
			debate = App.models.Debates.findOne(debateID)
			user = Meteor.user()

			commentID = App.models.Comments.insert(
				userID: Meteor.userId()
				content: content
				side: side
				debateID: debateID
				hidden: false
				datetime: new Date()
			)

			if user._id != debate.authorID
				App.models.Notifications.addNotification('comment', debate.authorID, commentID, {
					fromUserID: user._id
					fromUserName: user.profile.name,
					debateID: debate._id
					debateTitle: debate.title,
					commentID: commentID
				})

			App.models.Points.addPoints('comment', Meteor.userId(), commentID, 10)

	removeComment: (commentID) ->
		App.models.Comments.update({_id: commentID}, {$set: {hidden: true}})
		App.models.Points.removePoints('comment', Meteor.userId(), commentID)

		comment = App.models.Comments.findOne(commentID)
		App.models.Votes.find({'commentID': commentID}).forEach((upvote) ->
			App.models.Notifications.removeNotification('agree', comment.userID, upvote._id)
		)
)

if Meteor.isServer
	Meteor.publish('debateComments', (debateID) ->
		return Comments.find(debateID: debateID)
	)

	Meteor.publish('userComments', (userID) ->
		return Comments.find(userID: userID)
	)

	Meteor.publish('agreeingComments', (userID) ->
		return Comments.whereUserAgrees(userID)
	)
