Points = new Meteor.Collection 'points'

App.models.Points = Points

Points.forUser = (userID) ->
    return Points.find(userID: userID)

Points.addPoints = (type, userID, keyID, amount) ->
    Points.insert(
        type: type
        userID: userID
        amount: amount
        datetime: new Date()
        keyID: keyID
    )

Points.removePoints = (type, userID, keyID) ->
    Points.remove(
        type: type
        userID: userID
        keyID: keyID
    )

if Meteor.isServer
    Meteor.publish('forUserPoints', (userID) ->
        return Points.find(userID: userID)
    )

    Meteor.publish('points', () ->
        return Points.find()
    )
