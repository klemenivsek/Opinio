DEFAULT_COLORS = {
	'agree': { "dark" : 6076508, "light" : 11128918 }
	'disagree': { "dark" : 14242639, "light" : 15820066 }
}

DEFAULT_SIDES = {
	"agree" : {
		"position" : 1
		"name" : "Agree",
		"colors" : DEFAULT_COLORS['agree'],
	},
	"disagree" : {
		"position" : 2,
		"name" : "Disagree",
		"colors" : DEFAULT_COLORS['disagree']
	}
}

Debates = new Meteor.Collection 'debates'

App.models.Debates = Debates
App.models.Debates.DefaultColors = DEFAULT_COLORS

if Meteor.isClient
	App.models.DebateDetails = new Meteor.Collection 'debateDetails'

Debates.byUser = (userID) ->
	return Debates.find(authorID: userID)

if Meteor.isServer
	Meteor.publish('debate', (id) ->
		return Debates.find({_id: id})
	)

	Meteor.publish('debatesWithoutContent', () ->
		return Debates.find({}, {content: 0})
	)

	Meteor.publish('debates', () ->
		return Debates.find()
	)

	Meteor.publish('userDebates', (userID) ->
		return Debates.find(authorID: userID)
	)

	Meteor.publish('debateDetails', () ->
		self = this

		App.models.Debates.find().forEach((debate) ->
			debateID = debate._id
			self.added('debateDetails', debateID, {
				forCount: App.models.Comments.byDebateAndSide(debateID, 'agree').count()
				againstCount: App.models.Comments.byDebateAndSide(debateID, 'disagree').count()
			})
		)

		self.ready()
	)

Meteor.methods(
	createDebate: (title, description, imageName, sideA, sideAOpinion, sideB, sideBOpinion) ->
		sides = DEFAULT_SIDES
		sides['agree'].name = sideA || "Agree"
		sides['disagree'].name = sideB || "Disagree"

		user = Meteor.user()
		if user._id and title
			debateID = Debates.insert(
				title: title
				titleLowercase: title.toLowerCase()
				description: description
				imageName: imageName
				authorID: user._id
				sides: sides
				datetime: new Date()
			)
			App.models.Points.addPoints('debate', user._id, debateID, 5)

			if sideAOpinion
				Meteor.call('postComment', debateID, sideAOpinion, 'agree')

			if sideBOpinion
				Meteor.call('postComment', debateID, sideBOpinion, 'disagree')

	removeDebate: (debateID) ->
		if App.models.Comments.find({'debateID': debateID}).count() == 0 and Debates.findOne(debateID).authorID == Meteor.userId()
			Debates.remove(debateID)
)
