Users = Meteor.users

App.models.Users = Users

Users.allow(
    insert: (userId, post) ->
        return false

    remove: (userId, post) ->
        return false

    update: (userId, post) ->
        return false
)

Meteor.methods(
    createCustomUser: (email, name, password) ->
        if Meteor.isServer
            userID = Accounts.createUser(
                username: email
                email: email
                password: password
                profile: {
                    name: name
                }
            )
            Accounts.sendVerificationEmail(userID)

    updateProfile: (profile) ->
        modifier = {}
        _.each(profile, (value, key) ->
            modifier['profile.' + key] = value
        )

        Meteor.users.update({_id: Meteor.userId()}, {$set: modifier})
)

if Meteor.isServer
	Meteor.publish('users', () ->
		return Meteor.users.find({})
	)
