Images = new FS.Collection('images', {
    stores: [new FS.Store.GridFS('images')]
})

App.models.Images = Images

Images.deny(
    insert: () ->
        return false
    update: () ->
        return false
    remove: () ->
        return false
    download: () ->
        return false
)

Images.allow(
    insert: () ->
        return true
    update: () ->
        return true
    remove: () ->
        return true
    download: () ->
        return true
)

if Meteor.isServer
    Meteor.publish('images', () ->
        return Images.find()
    )
