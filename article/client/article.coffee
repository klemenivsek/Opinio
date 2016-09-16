Template.topic.helpers(
    title: () ->
        return App.models.Debates.findOne().title

    imageUrl: () ->
        imageName = App.models.Debates.findOne().imageName
        if imageName
            return '/cfs/files/images/' + imageName
        return null

    description: () ->
        return App.models.Debates.findOne().description

    authorID: () ->
        return App.models.Debates.findOne().authorID

    authorName: () ->
        authorID = App.models.Debates.findOne().authorID
        return Meteor.users.findOne(authorID).profile.name

    canRemove: () ->
        debateID = App.models.Debates.findOne()._id
        noComments = App.models.Comments.find({'debateID': debateID}).count() == 0
        isAuthor = App.models.Debates.findOne().authorID == Meteor.userId()
        return noComments and isAuthor

    inviteVisible: () ->
        return Session.get('inviteVisible')

    inviteUrl: () ->
        return location.href.replace(location.hash, '')
)

selectElementText = (el, win) ->
    win = win || window
    doc = win.document
    if win.getSelection && doc.createRange
        sel = win.getSelection()
        range = doc.createRange()
        range.selectNodeContents(el)
        sel.removeAllRanges()
        sel.addRange(range)
    else if doc.body.createTextRange
        range = doc.body.createTextRange()
        range.moveToElementText(el)
        range.select()

Template.topic.events(
    'click .remove': () ->
        Meteor.call('removeDebate', App.models.Debates.findOne()._id)
        Router.go('home')

    'click .invite': () ->
        Session.set('inviteVisible', true)
        Meteor.defer(() ->
            selectElementText($('.invite-link')[0])
        )
)
