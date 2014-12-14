--local beautiful = require("beautiful")
local hk = require("actionless.hotkeys")


hk.add_groups({
  vim_motion={name="vim motion",color="#009F00"},
  vim_command={name="vim command",color="#aFaF00"},
  vim_command_insert={name="vim cmd and ins",color="#cF4F40"},
  vim_operator={name="vim operator",color="#aF6F00"},
})

local vim_keys = {
  motion={
    ['`']="goto mark",
    ["#"..0+10+9]='"hard" BOL',
    ['#20']="prev line",
    w="next word",
    e="end word",
    t=". 'till",
    ['[']=". misc",
    [']']=". misc",
    f=". find char",
    [';']="repeat t/T/f/F",
    ["'"]=". goto mk. BOL",
    b="prev word",
    n="next word",
    [',']="reverse t/T/f/F",
    ['/']=". find",
  },
  operator={
    ['#21']="auto format",
    y="yank",
    d="delete",
    c="change",
  },
  command={
    q=". record macro",
    r=". replace char",
    u="undo",
    p="paste after",
    g="gg: top of file, gf: open file here",
    z="zt: cursor to top, zb: bottom, zz: center",
    x="delete char",
    v="visual mode",
    m=". set mark",
    ['.']="repeat command",
  },
  command_insert={
    i="insert mode",
    o="open below",
    a="append",
    s="subst char",
  },
}

for action_type, keys in pairs(vim_keys) do
  for key, description in pairs(keys) do
    hk.on({}, key,
      function() print("TESST") end,
      description,
      "vim_"..action_type
    )
  end
end


local vim_shift_keys = {
  motion={
    ['`']="toggle case",
    ["#"..3+9]='prev indent',  -- #
    ["#"..4+9]='EOL',  -- $
    ["#"..5+9]='goto match bracket',  -- %
    ["#"..6+9]='"soft" BOL',  -- ^
    ["#"..7+9]='next indent',  -- *
    ["#"..9+9]='begin sentence',  -- (
    ["#"..10+9]='end sentence',  -- )
    ["#"..11+9]='"soft" BOL down', -- _
    ["#"..12+9]='next line', -- +
    w='next WORD',
    e='end WORD',
    t=". back 'till",
    ['[']="begin parag.",
    [']']="end parag.",
    f='. "back" find char',
    g='EOF/goto line',
    h='screen top',
    l='screen bottom',
    b='prev WORD',
    n='prev (find)',
    m='screen middle',
    ['/']='. find(rev.)',  -- ?
  },
  operator={
    ["#"..1+9]='external filter',  -- !
    [',']='unindent',  -- <
    ['.']='indent',  -- >
  },
  command={
    ["#"..2+9]='. play macro',  -- @
    ["#"..7+9]='repeat :s',  -- &
    q='ex mode',
    y='yank line',
    u='undo line',
    p='paste before',
    d='delete to EOL',
    j='join lines',
    k='help',
    [':']='ex cmd line',
    ["'"]='. register spec',
    ["\\"]='BOL/goto col',
    z='quit and ZZ:save or ZQ:not',
    x='back-delete',
    v='visual lines',
  },
  command_insert={
    r='replace mode',
    i='insert at BOL',
    o='open above',
    a='append at EOL',
    s='subst line',
    c='change to EOL',
  },
}

for action_type, keys in pairs(vim_shift_keys) do
  for key, description in pairs(keys) do
    hk.on({"Shift"}, key,
      function() print("TESST") end,
      description,
      "vim_"..action_type
    )
  end
end

