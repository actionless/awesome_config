local widgets = {
	-- widgets
	common			= require("actionless.widgets.common"),
	layoutbox		= require("actionless.widgets.layoutbox"),
	music			= require("actionless.widgets.music"),
	netctl			= require("actionless.widgets.netctl"),
	bat			= require("actionless.widgets.bat"),
	manage_client		= require("actionless.widgets.manage_client"),
	systray_toggle		= require("actionless.widgets.systray_toggle"),
	sneaky_toggle		= require("actionless.widgets.sneaky_toggle"),
	sneaky_tray		= require("actionless.widgets.sneaky_tray"),
	random_pic		= require("actionless.widgets.random_pic"),
	alsa			= require("actionless.widgets.alsa"),
	temp			= require("actionless.widgets.temp"),
	-- lain forks
	cpu			= require("actionless.widgets.cpu"),
	mem			= require("actionless.widgets.mem"),
	calendar		= require("actionless.widgets.calendar"),
        -- other forks
        kbd                     = require("actionless.widgets.kbd"),
}

return widgets
