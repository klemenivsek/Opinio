Template.summary.helpers(
    upvotedComments: () ->
        comments = _.map(App.models.Votes.find({userID: Meteor.userId()}).fetch(), (upvote) ->
            return App.models.Comments.byID(upvote.commentID)
        )
        return _.sortBy(comments, (comment) ->
            return comment._id
        )
)

Template.upvotedComment.helpers(
    noteContent: () ->
        vote = App.models.Votes.findOne(
            userID: Meteor.userId(),
            commentID: this._id
        )
        return vote.note

    userID: () ->
        comment = App.models.Comments.byID(this._id)
        return Meteor.users.findOne(comment.userID)._id

    userName: () ->
        comment = App.models.Comments.byID(this._id)
        return Meteor.users.findOne(comment.userID).profile.name
)

Template.upvotedComment.events(
    'keyup input': (event) ->
        input = $(event.target)
        content = input.val()

        Meteor.call('setAgreeReason', this._id, content)
)
