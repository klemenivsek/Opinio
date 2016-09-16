Template.list.helpers(
    articles: () ->
        debates = App.models.Debates.find().fetch()
        _.each(debates, (debate) ->
            details = App.models.DebateDetails.findOne(debate._id)
            if details
                debate.forCount = details.forCount
                debate.againstCount = details.againstCount
            else
                debate.forCount = 0
                debate.againstCount = 0
            if debate.imageName
                debate.imageUrl = '/cfs/files/images/' + debate.imageName
            else
                debate.imageUrl = '/images/default-article-image.jpg'
        )
        return _.sortBy(debates, (debate) ->
            return - (debate.forCount + debate.againstCount)
        )
)

Template.createDebate.helpers(
    colors: () ->
        return App.models.Debates.DefaultColors

    message: () ->
        return Session.get('createDebateMessage')
)

currentImageName = null
Template.createDebate.events(
    'change .image-input': (event, template) ->
        currentImageName = null
        FS.Utility.eachFile(event, (file) ->
            App.models.Images.insert(file, (err, fileObj) ->
                if not err
                    currentImageName = fileObj._id
            )
        )

    'click .create-debate-done': (event) ->
        event.preventDefault()

        titleInput = $('#title')
        title = titleInput.val()

        descriptionInput = $('#description')
        description = descriptionInput.val() || null

        imageName = currentImageName

        sideAInput = $('#sideAName')
        sideA = sideAInput.val() || null

        sideAOpinionInput = $('#sideAOpinion')
        sideAOpinion = sideAOpinionInput.val() || null

        sideBInput = $('#sideBName')
        sideB = sideBInput.val() || null

        sideBOpinionInput = $('#sideBOpinion')
        sideBOpinion = sideBOpinionInput.val() || null

        if title.length == 0
            message = "Please enter a title for debate"

        if !message
            titleInput.val('')
            descriptionInput.val('')
            sideAInput.val('')
            sideAOpinionInput.val('')
            sideBInput.val('')
            sideBOpinionInput.val('')
            Meteor.call('createDebate', title, description, imageName, sideA, sideAOpinion, sideB, sideBOpinion)
        else
            Session.set('createDebateMessage', message)
)
