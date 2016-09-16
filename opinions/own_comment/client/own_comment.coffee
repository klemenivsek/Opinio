Template.yourComment.helpers(
    ownComment: () ->
        debateID = App.currentDebateID
        return App.models.Comments.byUserSingle(debateID, Meteor.userId(), this.side.key)
)

Template.postComment.events(
    'click .post, keyup textarea': (event) ->
        enableEnter = false
        if event.type != 'keyup' or (event.keyCode == 13 and enableEnter)
            textarea =  $(event.target).closest('.new-comment').find('textarea')
            content = textarea.val()
            textarea.val('')

            Meteor.call('postComment', App.currentDebateID, content.trim(), this.side.key)
)

Template.comment.events(
    'click .delete': (event) ->
        $('#remove-modal-' + this._id).modal('show')
)

Template.removeModal.events(
    'click .confirm': (event) ->
        commentID =  this._id
        $('#remove-modal-' + this._id).modal('hide')
        Meteor.call('removeComment', commentID)
)

Template.postComment.onRendered(() ->
    $textarea = $('textarea', $(this.firstNode))
    $textarea.autosize()
)
