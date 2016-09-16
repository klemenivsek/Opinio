Template.replies.helpers(
    replies: () ->
        return App.models.Replies.find(
            commentID: this._id
        ).fetch()
)

Template.postReply.events(
    'click .btn, keyup textarea': (event) ->
        enableEnter = false
        if event.type != 'keyup' or (event.keyCode == 13 and enableEnter)
            event.preventDefault()
            event.stopPropagation()

            textarea = $(event.target).closest('.new-reply').find('textarea')
            content = textarea.val()
            textarea.val('')

            Meteor.call('reply', this._id, content.trim())
)

Template.postReply.onRendered(() ->
    $textarea = $('textarea', $(this.firstNode))
    $textarea.autosize()
)

Template.reply.helpers(
    toolboxContent: () ->
        comment = App.models.Comments.byID(this.commentID)
        debate = App.models.Debates.findOne(comment.debateID)
        replyUserComments = App.models.Comments.byUserInDebate(this.userID, debate._id).fetch()

        bySides = _.groupBy(replyUserComments, (comment) ->
            return comment.side
        )

        html = ""
        if replyUserComments.length > 0
            for side,comments of bySides
                color = debate.sides[side].colors.light
                hex = ("000000" + color.toString(16)).slice(-6)
                html += '<div class="user-opinion" style="background-color: #' + hex + ';">' + comments[0].content + "</div>"
        else
            html += "This user did not write any opinion on this debate"

        html += '<div class="view-profile"><a href="/profile/' + this.userID + '">View profile</a></div>'

        return html;

    userName: () ->
        return Meteor.users.findOne(this.userID).profile.name

    didUpvote: () ->
        return !!App.models.ReplyVotes.findOne(
            replyID: this._id
            userID: Meteor.userId()
        )

    numUpvotes: () ->
        return App.models.ReplyVotes.find(replyID: this._id).count()

    isOwn: () ->
        return this.userID == Meteor.userId()

    isSelected: () ->
        return App.currentSelect and App.currentSelect.name == 'reply' and App.currentSelect.id == this._id

    shortContent: () ->
        return s.prune(this.content, 100)

    isShortened: () ->
        return this.content.length > 100

    viewFull: () ->
        return Session.get('viewFullReply-' + this._id)
)

Template.reply.events(
    'click .see-more': (event) ->
        Session.set('viewFullReply-' + this._id, true)
        event.stopPropagation()

    'click .upvote-reply': (event) ->
        Meteor.call('toggleReplyAgree', this._id)

    'click .remove-reply': (event) ->
        Meteor.call('removeReply', this._id)
)
