compose = (notifications) ->
    html = ""

    html += """
    <table>
        <tbody>
    """

    _.each(notifications, (notification) ->
        text = App.models.Notifications.getProperty('text', notification)
        date = moment(notification.datetime).format('MM-DD-YYYY')

        html += s.sprintf("""
        <tr>
            <td>
                <span style="float: left;">%s</span>
                <span style="float: right;">%s</span>
            </td>
        </tr>
        """, text, date)
    )

    html += """
        </tbody>
    </table>
    """

    URL = 'http://opinio.meteor.com/'
    html = html.replace(/a href="(.*)"/i, 'a href="' + URL + '$1"')

    return html.split('\n').join('').split('    ').join('')

Meteor.startup(() ->
    sendReminders = () ->
        _.each(Meteor.users.find({}).fetch(), (user) ->
            if user.profile and user.profile.emailNotifications
                email = user.emails and user.emails.length > 0 and user.emails[0].address
                if not email
                    email = user.services and user.services.facebook and user.services.facebook.email
                if email
                    notifications = App.models.Notifications.find({toUserID: user._id, seen: false, sentReminder: false}).fetch()
                    if notifications.length > 0
                        content = compose(notifications)
                        App.models.Notifications.update({toUserID: user._id, seen: false, sentReminder: false}, {$set: {sentReminder: true}}, {multi: true})
                        Email.send(
                            from: 'notifications@opinio.meteor.com'
                            to: email
                            subject: 'You have unseen notifications on Opinio'
                            html: content
                        )
                        console.log('Sending to ' + email)
        )


    SyncedCron.add(
        name: 'Send reminders to people with unread notifications',
        schedule: (scheduler) ->
            #return scheduler.recur().every().minute() # Every minute
            return scheduler.recur().on(16).hour() # Every day at 16:00
        job: sendReminders
    )
    SyncedCron.start()
)
