
local variables = {}


function variables.init(status)

local terminal = "st" or "urxvt -lsp 1 -geometry 120x30" or "xterm"
local editor = "vim" or os.getenv("EDITOR") or "nano" or "vi"

status.vars = {
  terminal = terminal,
  editor = editor,
}

status.cmds = {
  terminal = terminal,
  editor_cmd = terminal .. " -e " .. editor,
  --browser= "dwb",
  chromium   = "GTK2_RC_FILES=~/.gtkrc-2.0.browsers chromium --enable-user-stylesheet",
  chrome   = "GTK2_RC_FILES=~/.gtkrc-2.0.browsers google-chrome --enable-user-stylesheet",
  firefox= "firefox -P actionless ",
  gui_editor = "/opt/sublime_text/sublime_text",
  compositor = "compton",
  graphics   = "pinta",
  file_manager = "pcmanfm",
  --tmux   = terminal .. [[ -e "sh -c 'TERM=xterm-256color tmux'" ]],
  tmux = terminal .. " -e tmux",
  --musicplr   = terminal .. " --geometry=850x466 -e ncmpcpp",
  musicplr   = terminal .. " -e ncmpcpp",
  tmux_run   = terminal .. " -e tmux new-session",
  dmenu = "~/.config/dmenu/dmenu-recent.sh",
  scrot_preview_cmd = [['mv $f ~/images/ &amp; viewnior ~/images/$f']],
}

end
return variables
