local widgets =
{
	--awesome forks
	tasklist  = require("widgets.tasklist"),
	menu    = require("widgets.menu"),
	common    = require("widgets.common"),
	naughty    = require("widgets.naughty"),
	--lain forks
	markup    = require("widgets.markup"),
	helpers    = require("widgets.helpers"),
	mpd  = require("widgets.mpd"),
	cpu  = require("widgets.cpu"),
	mem  = require("widgets.mem"),
	calendar  = require("widgets.calendar"),
	alsa  = require("widgets.alsa"),
	temp  = require("widgets.temp"),
	bat  = require("widgets.bat"),
	--misc
	settings = require("widgets.settings"),
	random_pic = require("widgets.random_pic"),
	asyncshell    = require("widgets.asyncshell"),
	systray_toggle    = require("widgets.systray_toggle")
}

return widgets
