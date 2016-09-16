ReplyVotes = new Meteor.Collection 'reply_votes'

App.models.ReplyVotes = ReplyVotes

Meteor.startup(() ->
	App.models.Notifications.addType('agreeReply', {
		text: (data) ->
			return s.sprintf('<b><a href="/profile/%s">%s</a></b> agrees with <b><a href="/topic/%s#reply:%s">your reply</a></b> in debate <b><a href="/topic/%s">%s</a></b>', data.fromUserID, data.fromUserName, data.debateID, data.replyID, data.debateID, data.debateTitle)

		title: (data) ->
			return 'Agreeing with reply'
	})
)

ReplyVotes.byUser = (userID) ->
	return ReplyVotes.find(userID: userID)

Meteor.methods(
	toggleReplyAgree: (replyID) ->
		user = Meteor.user()
		reply = App.models.Replies.byID(replyID)
		replyComment = App.models.Comments.byID(reply.commentID)
		if user and reply.userID != user._id
			currentVote =  ReplyVotes.findOne(
				replyID: replyID
				userID: user._id
			)
			if !currentVote
				voteID = ReplyVotes.insert(
					replyID: replyID
					userID: user._id
					datetime: new Date()
				)

				debate = App.models.Debates.findOne(replyComment.debateID)
				App.models.Notifications.addNotification('agreeReply', reply.userID, voteID, {
					fromUserID: user._id
					fromUserName: user.profile.name,
					debateTitle: debate.title
					debateID: debate._id
					replyID: replyID
				})
				App.models.Points.addPoints('agreeReply', reply.userID, voteID, 3)
			else
				ReplyVotes.remove(currentVote._id)
				App.models.Notifications.removeNotification('agreeReply', reply.userID, currentVote._id)
				App.models.Points.removePoints('agreeReply', reply.userID, currentVote._id)

)

if Meteor.isServer
	Meteor.publish('debateReplyVotes', (debateID) ->
		commentIDs = _.pluck(App.models.Comments.byDebate(debateID).fetch(), '_id')
		replyIDs = _.pluck(App.models.Replies.find(commentID: {$in: commentIDs}).fetch(), '_id')
		return ReplyVotes.find(replyID: {$in: replyIDs})
	)
