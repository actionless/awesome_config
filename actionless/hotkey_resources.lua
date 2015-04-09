local export = {}

export.KEYBOARD = {
  { 'Escape', '#67', '#68', '#69', '#70', '#71', '#72', '#73', '#74', '#75', '#76', '#95', '#96', 'Home', 'End'},
  { '`', '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18', '#19', '#20', '#21', 'Insert', 'Delete' },
  { 'Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 'Backspace' },
  { 'Caps', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Return' },
  { 'Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Next', 'Up' , 'Prior' },
  { 'Fn', 'Control', 'Mod4', 'Mod1', '', 'space', '', '', '#108', 'Print', 'Control', 'Left', 'Down', 'Right'},
}

export.LABELS = {
  Mod4="Super",
  Mod1="Alt",
  Escape="Esc",
  Insert="Ins",
  Delete="Del",
  Backspace="BackSpc",
  Return="Enter",
  Next="PgDn",
  Prior="PgUp",
  ['#108']="Alt Gr",
  Left='←',
  Up='↑',
  Right='→',
  Down='↓',
  ['#67']="F1",
  ['#68']="F2",
  ['#69']="F3",
  ['#70']="F4",
  ['#71']="F5",
  ['#72']="F6",
  ['#73']="F7",
  ['#74']="F8",
  ['#75']="F9",
  ['#76']="F10",
  ['#95']="F11",
  ['#96']="F12",
  ['#10']="1",
  ['#11']="2",
  ['#12']="3",
  ['#13']="4",
  ['#14']="5",
  ['#15']="6",
  ['#16']="7",
  ['#17']="8",
  ['#18']="9",
  ['#19']="0",
  ['#20']="-",
  ['#21']="=",
  Control="Ctrl"
}

export.SPECIAL_KEYBUTTONS = {
  'Esc',
  'Tab',
  'Caps',
  'Shift',
  'Ctrl',
  'Super',
  'Alt',
  'Alt G',
  'Alt Gr',
  'PrScr',
  'PgUp',
  'PgDn',
  'BackSpc',
  'Enter',
  'Ins',
  'Del',
  'Home',
  'End',
  'F1',
  'F2',
  'F3',
  'F4',
  'F5',
  'F6',
  'F7',
  'F8',
  'F9',
  'F10',
  'F11',
  'F12',
  --'←',
  --'↑',
  --'→',
  --'↓',
}

local ALPHABET = "abcdefghijklmnopqrstuvwxyz"
export.SHIFTED = {
  ['`']='~',
  ['1']='!',
  ['2']='@',
  ['3']='#',
  ['4']='$',
  ['5']='%',
  ['6']='^',
  ['7']='&amp;',
  ['8']='*',
  ['9']='(',
  ['0']=')',
  ['-']='_',
  ['=']='+',
  ['[']='{',
  [']']='}',
  ['\\']='|',
  [';']=':',
  ["'"]='"',
  [","]='&lt;',
  ["."]='&gt;',
  ["/"]='?',
}
for i = 1, #ALPHABET do
  local c = ALPHABET:sub(i, i)
  export.SHIFTED[c] = c:upper()
end

export.MODIFIERS = {
  Control = '#37'
}
return export
