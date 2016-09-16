Template.comment.helpers(
    numUpvotes: () ->
        return App.models.Votes.find(commentID: this._id).count()

    numReplies: () ->
        return App.models.Replies.find(commentID: this._id).count()

    userName: () ->
        return Meteor.users.findOne(this.userID).profile.name

    didUpvote: () ->
        return !!App.models.Votes.findOne(
            commentID: this._id
            userID: Meteor.userId()
        )

    isOwn: () ->
        return Meteor.userId() and App.models.Comments.byID(this._id).userID == Meteor.userId()

    toolboxContent: () ->
        upvotes = App.models.Votes.find(userID: this.userID).fetch()

        s = ""
        if upvotes.length > 0
            s += "<b>Agrees with </b>"
            _.each(upvotes, (upvote) ->
                comment = App.models.Comments.byID(upvote.commentID)
                user = Meteor.users.findOne(comment.userID)
                s += '<a href="/profile/' + user._id + '">' + user.profile.name + "</a>, "
            )
            s = s.substring(0, s.length - 2) + '<br>'
        s += '<a href="/profile/' + this.userID + '">View profile</a>'

        return s

    viewReplies: () ->
        return Session.get('viewRepliesOnID') == this._id

    isSelected: () ->
        return App.currentSelect and App.currentSelect.name == 'opinion' and this._id == App.currentSelect.id

    shortContent: () ->
        return s.prune(this.content, 300)

    isShortened: () ->
        return this.content.length > 300

    viewFull: () ->
        return Session.get('viewFull-' + this._id)

    hasRepliesOrCanPost: () ->
        return App.models.Replies.find(commentID: this._id).count() > 0 or Meteor.userId()
)

Template.comment.events(
    'click .upvote': (event) ->
        Meteor.call('toggleAgree', this._id)

    'click .view-replies,.see-more': (event) ->
        if Session.get('viewRepliesOnID') == this._id
            Session.set('viewRepliesOnID', null)
            Session.set('viewFull-' + this._id, null)
        else
            Session.set('viewRepliesOnID', this._id)
            Session.set('viewFull-' + this._id, true)
        event.stopPropagation()
)

Template.comment.onRendered(() ->
    if App.currentSelect
        if App.currentSelect.name == 'opinion' and this.data._id == App.currentSelect.id
            element = this.firstNode
            Meteor.defer(() ->
                element.scrollIntoView()
                $('.debate-title')[0].scrollIntoView()
            )

        else if App.currentSelect.name == 'reply'
            reply = App.models.Replies.findOne(App.currentSelect.id)
            Session.set('viewRepliesOnID', reply.commentID)

            if this.data._id == reply.commentID
                element = this.firstNode
                Meteor.defer(() ->
                    element.scrollIntoView()
                    $('.debate-title')[0].scrollIntoView()
                )
)
