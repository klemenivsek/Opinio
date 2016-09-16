Accounts.onEmailVerificationLink((token, done) ->
	Accounts.verifyEmail(token, () ->
		done()
	)
)

Template.login.helpers(
	isViewSignIn: () ->
		return !Session.get('view') || Session.get('view') == 'signIn'

	isViewSignUp: () ->
		return Session.get('view') == 'signUp'

	isViewWaitingConfirmation: () ->
		return Session.get('view') == 'waitingConfirmation'
)

Template.login.events(
	'click a.sign-up': (event) ->
		Session.set('view', 'signUp')

	'click a.sign-in': () ->
		Session.set('view', 'signIn')

	'click button.sign-in': () ->
		email = $('#email').val()
		password = $('#password').val()
		Meteor.loginWithPassword(email, password, (err) ->
			if(err)
				Session.set('loginError', err.reason)
			else
				Session.set('loginError', null)
				Router.go('home')
		)

	'submit .sign-in-form': (event) ->
		event.preventDefault()
		email = $('#email').val()
		password = $('#password').val()
		Meteor.loginWithPassword(email, password, (err) ->
			if(err)
				Session.set('loginError', err.reason)
			else
				Session.set('loginError', null)
				Router.go('home')
		)

	'click button.sign-up': () ->
		email = $('#email').val()
		name = $('#name').val()
		password = $('#password').val()

		Session.set('createError', null)
		if email.length == 0
			Session.set('createError', 'Please enter your email')
		else if name.length == 0
			Session.set('createError', 'Please enter your full name')
		else if password.length == 0
			Session.set('createError', 'Please enter your password')
		else if password.length < 6
			Session.set('createError', 'Password must be at least 6 characters long')

		if !Session.get('createError')
			Meteor.call('createCustomUser', email, name, password, (error, result) ->
				if !error
					Session.set('confirmationEmail', email)
					Session.set('view', 'waitingConfirmation')
				else
					Session.set('createError', error.reason)
			)

	'click .facebook': (event) ->
		Meteor.loginWithFacebook({
			requestPermissions: ['email']
		}, (err) ->
			if not err
				Router.go('home')
		)
)

Template.signIn.helpers(
	loginError: () ->
		return Session.get('loginError')
)

Template.signUp.helpers(
	createError: () ->
		return Session.get('createError')

)
Template.waitingConfirmation.helpers(
	email: () ->
		return Session.get('confirmationEmail')
)
