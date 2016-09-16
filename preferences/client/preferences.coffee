Template.preferences.helpers(
	profile: () ->
		return Meteor.user().profile
)

cleanURL = (url) ->
	base = '://'
	if url.indexOf(base) >= 0
		baseIndex = url.indexOf(base) + base.length
		url = url.substring(baseIndex)
	if url.charAt(url.length - 1) == '/'
		url = url.substring(0, url.length - 1)
	return url

Template.preferences.events(
	'click .update-profile': (event) ->
		event.preventDefault()

		website = $('input[name=website]').val()
		if website.indexOf('://') < 0
			website = 'http://' + website
		websiteText = cleanURL(website)

		profile = {
			name: $('input[name=name]').val()
			aboutMe: $('input[name=aboutMe]').val()
			place: $('input[name=place]').val()
			website: website
			websiteText: websiteText
			emailNotifications: $('input[name=emailNotifications]')[0].checked
		}

		Meteor.call('updateProfile', profile, (err, result) ->
			Router.go('profile')
		)
)
