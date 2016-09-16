Meteor.startup ->
    isDevelopment = process.env.NODE_ENV == "development"

    process.env.MAIL_URL = App.config.mail.url

    Accounts.validateLoginAttempt((attempt) ->
        if not isDevelopment and attempt.user and attempt.user.emails and !attempt.user.emails[0].verified
            return false
        return true
    )

    Accounts.emailTemplates.siteName = "Opinio"
    Accounts.emailTemplates.from = "Opinio <accounts@opinio.meteor.com>"

    Accounts.emailTemplates.verifyEmail.subject = (user) ->
        return user.profile.name + ", please verify your email"

    Accounts.emailTemplates.verifyEmail.html = (user, url) ->
        return s.sprintf("""
        Hi,<br>
        <br>
        You are being asked to verify the email address %s for Opinio.<br>
        <br>
        Click here to confirm it:<br>
        %s
        """, user.emails[0].address, url)

    if not isDevelopment
        ServiceConfiguration.configurations.upsert({service: "facebook"}, {$set: {
            appId: App.config.facebook.production.appID,
            secret: App.config.facebook.production.secret,
        }})
    else
        ServiceConfiguration.configurations.upsert({service: "facebook"}, {$set: {
            appId: App.config.facebook.development.appID,
            secret: App.config.facebook.development.secret,
        }})
