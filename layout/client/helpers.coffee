Template.registerHelper('date', (date, format) ->
	return moment(date).format(format)
)

Template.registerHelper('duration', (duration, format) ->
	return moment.utc(duration * 1000).format(format)
)

Template.registerHelper('toHex', (number) ->
	return ("000000" + number.toString(16)).slice(-6)
)

Template.registerHelper('rgb', (color) ->
	r = (color >> 16) & 255
	g = (color >> 8) & 255
	b = color & 255
	return r + ',' + g + ',' + b
)

Template.registerHelper('darker', (color, factor) ->
	r = (color >> 16) & 255
	g = (color >> 8) & 255
	b = color & 255
	return ("000000" + (Math.round((r * factor) << 16) + Math.round((g * factor) << 8) + Math.round(b * factor)).toString(16)).slice(-6)
)

Template.registerHelper('lighter', (color, factor) ->
	r = (color >> 16) & 255
	g = (color >> 8) & 255
	b = color & 255
	return ("000000" + (Math.round((255 * factor + r * (1 - factor)) << 16) + Math.round((255 * factor + g * (1 - factor)) << 8) + Math.round((255 * factor + b * (1 - factor)))).toString(16)).slice(-6)
)
