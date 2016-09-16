Notifications = new Meteor.Collection 'notifications'

App.models.Notifications = Notifications

Notifications.addNotification = (type, toUserID, keyID, data) ->
	Notifications.insert(
		type: type
		toUserID: toUserID
		data: data
		seen: false
		keyID: keyID
		datetime: new Date()
		sentReminder: false
	)

Notifications.removeNotification = (type, toUserID, keyID) ->
	Notifications.remove(
		type: type
		toUserID: toUserID
		keyID: keyID
	)

Notifications._handlers = {}

Notifications.addType = (type, properties) ->
	Notifications._handlers[type] = properties

Notifications.getProperty = (property, notification) ->
    return Notifications._handlers[notification.type][property](notification.data)

Meteor.methods(
	seenNotifications: () ->
		Notifications.update({toUserID: Meteor.userId(), seen: false}, {$set: {seen: true}}, {multi: true})

	addNotification: (type, toUserID, data) ->
		Notifications.add(type, toUserID, data)
)

if Meteor.isServer
	Meteor.publish('userNotifications', (toUserID) ->
		return Notifications.find(
			toUserID: toUserID
		)
	)
