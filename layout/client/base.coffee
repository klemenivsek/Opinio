Template.base.helpers(
    userName: () ->
        return Meteor.user() and Meteor.user().profile.name

    notificationsContent: () ->
        return Blaze.toHTML(Template.notifications)

    notificationsCount: () ->
        return App.models.Notifications.find({toUserID: Meteor.userId()}).count()

    unseenNotificationsCount: () ->
        return App.models.Notifications.find({toUserID: Meteor.userId(), seen: false}).count()
)

Template.base.events(
    'click .view-notifications': () ->
        Meteor.setTimeout(() ->
            Meteor.call('seenNotifications')
        , 5000)

    'click .logout': () ->
        Router.go('home')
        Meteor.logout()
)
