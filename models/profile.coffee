if Meteor.isClient
	App.models.UserProfile = new Meteor.Collection 'userProfile'

if Meteor.isServer
	Meteor.publish('userProfile', (userID) ->
		this.added('userProfile', userID, getDocument(userID))
		this.ready()
	)

getDocument = (userID) ->
	prepareComments = (comments) ->
		comments = _.map(comments, (comment) ->
			pointsForCommentDocument = App.models.Points.findOne(type: 'comment', keyID: comment._id)
			pointsForComment = pointsForCommentDocument == null ? 0 : pointsForCommentDocument.amount
			pointsForAgrees = 0
			App.models.Votes.find({commentID: comment._id}).forEach((vote) ->
				pointsForAgreesDocument = App.models.Points.findOne(type: 'agree', keyID: vote._id)
				pointsForAgrees += pointsForAgreesDocument == null ? 0 : pointsForAgreesDocument.amount
			)

			debate = App.models.Debates.findOne(comment.debateID)

			return _.extend(comment, {
				numberOfUpvotes: App.models.Votes.find({commentID: comment._id}).count()
				numberOfReplies: App.models.Replies.find({commentID: comment._id}).count()
				numberOfPoints: pointsForComment + pointsForAgrees
				debateTitle: debate.title
				debateID: debate._id
			})
		)
		comments = _.sortBy(comments, (item) ->
			return -item.datetime.getTime()
		)
		comments = _.sortBy(comments, (item) ->
			return -item.numberOfUpvotes
		)
		return comments

	prepareReplies = (replies) ->
		replies = _.map(replies, (reply) ->
			comment = App.models.Comments.byID(reply.commentID)
			if comment
				debate = App.models.Debates.findOne(comment.debateID)
				pointsDocument = App.models.Points.findOne(type: 'reply', keyID: reply._id)
				_.extend(reply, {
					numberOfCommentUpvotes: App.models.Votes.find({commentID: comment._id}).count()
					numberOfPoints: pointsDocument == null ? 0 : pointsDocument.amount
					debateTitle: debate.title
					debateID: debate._id
				})
		)
		replies = _.filter(replies, (reply) -> reply)
		replies = _.sortBy(replies, (item) ->
			return -item.datetime.getTime()
		)
		replies = _.sortBy(replies, (item) ->
			return -item.numberOfCommentUpvotes
		)
		return replies

	prepareDebates = (debates) ->
		debates = _.map(debates, (debate) ->
			pointsDocument = App.models.Points.findOne(type: 'debate', keyID: debate._id)
			_.extend(debate, {
				numberOfComments: App.models.Comments.byDebate(debate._id).count()
				numberOfPoints: pointsDocument == null ? 0 : pointsDocument.amount
				id: debate._id
			})
		)
		debates = _.sortBy(debates, (item) ->
			return -item.datetime.getTime()
		)
		debates = _.sortBy(debates, (item) ->
			return -item.datetime.getTime()
		)
		return debates

	numberOfComments = App.models.Comments.byUser(userID).count()

	numberOfUpvotes = 0
	_.each(App.models.Comments.byUser(userID).fetch(), (comment) ->
		numberOfUpvotes += App.models.Votes.find({commentID: comment._id}).count()
	)

	numberOfPoints = 0
	_.each(App.models.Points.forUser(userID).fetch(), (points) ->
		numberOfPoints += points.amount
	)

	addToItems = (items, extension) ->
		return _.map(items, (item) ->
			return _.extend(item, extension)
		)
	items = {
		'opinions': addToItems(prepareComments(App.models.Comments.byUser(userID).fetch()), {isReply: true})
		'agreesWith': addToItems(prepareComments(App.models.Comments.whereUserAgrees(userID).fetch()), {isAgreeingComment: true})
		'replies': addToItems(prepareReplies(App.models.Replies.byUser(userID).fetch()), {isReply: true})
		'createdDebates': addToItems(prepareDebates(App.models.Debates.byUser(userID).fetch()), {isDebate: true})
	}

	return {
		numberOfComments: numberOfComments
		numberOfUpvotes: numberOfUpvotes
		numberOfPoints: numberOfPoints
		items: items
	}
