Replies = new Meteor.Collection 'replies'

App.models.Replies = Replies

Meteor.startup(() ->
	App.models.Notifications.addType('reply', {
		text: (data) ->
			return s.sprintf('<b><a href="/profile/%s">%s</a></b> replied to your opinion in debate <b><a href="/topic/%s#reply:%s">%s</a></b>', data.fromUserID, data.fromUserName, data.debateID, data.replyID, data.debateTitle)

		title: (data) ->
			return 'New reply to your comment'
	})
)

Replies.byID = (id) ->
	return Replies.findOne(id)

Replies.byUser = (userID) ->
	return Replies.find(userID: userID)

Meteor.methods(
	reply: (commentID, content) ->
		user = Meteor.user()
		comment = App.models.Comments.byID(commentID)
		if user and content.length > 0
			replyID = App.models.Replies.insert(
				userID: user._id,
				commentID: commentID,
				content: content
				datetime: new Date()
			)

			debate = App.models.Debates.findOne(comment.debateID)
			if user._id != comment.userID
				App.models.Notifications.addNotification('reply', comment.userID, replyID, {
					fromUserID: user._id
					fromUserName: user.profile.name,
					debateID: debate._id
					debateTitle: debate.title,
					replyID: replyID
					replyContent: content
				})

			App.models.Points.addPoints('reply', user._id, replyID, 1)

	removeReply: (replyID) ->
		reply = Replies.findOne(replyID)
		if reply.userID == Meteor.userId()
			Replies.remove(replyID)

)
if Meteor.isServer
	Meteor.publish('debateReplies', (debateID) ->
		commentIDs = _.pluck(App.models.Comments.byDebate(debateID).fetch(), '_id')
		return Replies.find(commentID: {$in: commentIDs})
	)

	Meteor.publish('forUserReplies', (userID) ->
		commentIDs = _.pluck(App.models.Comments.byUser(userID).fetch(), '_id')
		return Replies.find(
			commentID: {$in: commentIDs}
		)
	)

	Meteor.publish('byUserReplies', (userID) ->
		return Replies.find(userID: userID)
	)
