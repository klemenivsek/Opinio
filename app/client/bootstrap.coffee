Meteor.startup(() ->
    # Initialize tooltips and popovers
    Meteor.setInterval(() ->
        $(() ->
            $('[data-toggle="tooltip"]').tooltip()
            $('[data-toggle="popover"]').popover(
                 trigger: 'click'
                 html: true
            )
        )
    , 100)

    # Close popovers on click outside
    $('body').on('click', (e) ->
        $('[data-toggle="popover"]').each(() ->
            if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
                $(this).popover('hide')
        )
    )
)
