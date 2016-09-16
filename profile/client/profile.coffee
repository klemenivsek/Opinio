Template.profile.helpers(
	isOwn: () ->
		return Meteor.userId() == this.userID

	profile: () ->
		profileData =  Meteor.users.findOne(this.userID).profile

		profile = App.models.UserProfile.findOne(this.userID)
		profileData.numberOfComments = profile.numberOfComments
		profileData.numberOfUpvotes = profile.numberOfUpvotes
		profileData.numberOfPoints = profile.numberOfPoints

		return profileData

	filters: () ->
		filters = [
			{name: 'all', text: 'Timeline'},
			{name: 'opinions', text: 'Opinions'},
			{name: 'replies', text: 'Replies'},
			{name: 'agreesWith', text: 'Agrees with'},
			{name: 'createdDebates', text: 'Created debates'},
		]
		filters = _.map(filters, (filter) ->
			_.extend(filter, {
				current: (Session.get('currentFilter') || 'all') == filter.name
			})
		)
		return filters
)

Template.profile.events(
	'click .filter': () ->
		Session.set('currentFilter', this.name)
)

Template.timeline.helpers(
	items: () ->
		filter = Session.get('currentFilter') || 'all'
		profile = App.models.UserProfile.findOne(this.userID)

		if filter == 'all'
			items = []
			_.each(profile.items, (categoryItems) ->
				items = items.concat(categoryItems)
			)
			return _.sortBy(items, (item) ->
				return -item.datetime.getTime()
			)
		else
			items = profile.items[filter]

		return items
)
