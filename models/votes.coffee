Votes = new Meteor.Collection 'votes'

App.models.Votes = Votes

Meteor.startup(() ->
	App.models.Notifications.addType('agree', {
		text: (data) ->
			return s.sprintf('<b><a href="/profile/%s">%s</a></b> agrees with <b><a href="/topic/%s#opinion:%s">your opinion</a></b> in debate <b><a href="/topic/%s">%s</a></b>', data.fromUserID, data.fromUserName, data.debateID, data.commentID, data.debateID, data.debateTitle)

		title: (data) ->
			return 'Agreeing with opinion'
	})
)

Votes.byUser = (userID) ->
	return Votes.find(userID: userID)

Meteor.methods(
	toggleAgree: (commentID) ->
		user = Meteor.user()
		comment = App.models.Comments.byID(commentID)
		if user and comment.userID != user._id
			currentVote =  App.models.Votes.findOne(
				commentID: commentID
				userID: user._id
			)
			if !currentVote
				voteID = App.models.Votes.insert(
					commentID: commentID
					userID: Meteor.userId()
					datetime: new Date()
				)

				debate = App.models.Debates.findOne(comment.debateID)
				App.models.Notifications.addNotification('agree', comment.userID, voteID, {
					fromUserID: user._id
					fromUserName: user.profile.name,
					debateTitle: debate.title
					debateID: debate._id
					commentID: commentID
				})
				App.models.Points.addPoints('agree', comment.userID, voteID, 5)
			else
				App.models.Votes.remove(currentVote._id)
				App.models.Notifications.removeNotification('agree', comment.userID, currentVote._id)
				App.models.Points.removePoints('agree', comment.userID, currentVote._id)

	setAgreeReason: (commentID, reason) ->
		if Meteor.userId()
			vote = App.models.Votes.findOne(
				userID: Meteor.userId(),
				commentID: commentID
			)

			App.models.Votes.update(vote._id, {$set: {note: reason}})
)

if Meteor.isServer
	Meteor.publish('debateVotes', (debateID) ->
		commentIDs = _.pluck(App.models.Comments.byDebate(debateID).fetch(), '_id')
		return Votes.find(commentID: {$in: commentIDs})
	)

	Meteor.publish('forUserVotes', (userID) ->
		commentIDs = _.pluck(App.models.Comments.byUser(userID).fetch(), '_id')
		return Votes.find(
			commentID: {$in: commentIDs}
		)
	)

	Meteor.publish('byUserVotes', (userID) ->
		return Votes.find(userID: userID)
	)

	Meteor.publish('agreeingCommentsVotes', (userID) ->
		commentIDs = _.pluck(App.models.Comments.whereUserAgrees(userID).fetch(), '_id')
		return Votes.find(
			commentID: {$in: commentIDs}
		)
	)
