Template.debate.helpers(
    columnWidth: () ->
        debate = App.models.Debates.findOne(App.currentDebateID)
        numSides = _.keys(debate.sides).length
        return Math.floor(12 / numSides)

    sides: () ->
        debate = App.models.Debates.findOne(this.debateID)
        sides = _.map(_.keys(debate.sides), (key) ->
            return _.extend(debate.sides[key], {
                key: key
            })
        )
        _.sortBy(sides, (side) ->
            return side.position
        )
        return sides
)

Template.side.helpers(
    title: () ->
        return this.side.name

    hasComments: () ->
        debateID = App.currentDebateID
        commentsCount = App.models.Comments.byDebateAndSide(debateID, this.side.key).count()
        return commentsCount > 0
        
    comments: () ->
        debateID = App.currentDebateID
        comments = App.models.Comments.byDebateAndSide(debateID, this.side.key).fetch()
        comments = _.reject(comments, (comment) ->
            return comment.userID == Meteor.userId()
        )
        comments = _.sortBy(comments, (comment) ->
            return - App.models.Votes.find(commentID: comment._id).count()
        )
        return comments
)
