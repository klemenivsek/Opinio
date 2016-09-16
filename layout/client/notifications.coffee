Template.notifications.helpers(
    notifications: () ->
        return _.map(App.models.Notifications.find({toUserID: Meteor.userId()}, {sort: {datetime: -1}}).fetch(), (notification) ->
            return _.extend(notification,
                text: App.models.Notifications.getProperty('text', notification)
            )
        )
)
