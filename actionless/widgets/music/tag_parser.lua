--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

--local N_A = "N/A"
local N_A = nil

local naughty = { notify = function() end }
--local naughty = require("naughty")

local tag_parser = {}

  function tag_parser.predict_missing_tags(player_status)


    if player_status.file then
      player_status.file = player_status.file:match("^.*://(.*)$")
        or player_status.file
    else
      player_status.file = N_A
    end
    if player_status.cover then
      player_status.cover = player_status.cover:match("^file://(.*)$")
        or player_status.file
    else
      player_status.cover = default_art or N_A
    end

    if player_status.file == N_A or player_status.file == ''
    then
      return player_status
    end

-------------------------------------------------------------------------------
  if not player_status.artist or not player_status.title then
  -- @TODO: rewrite this big piece of whatever it is
  --
    --local inspect = require("inspect")
    --naughty.notify({text=inspect(player_status)})

    local a
    --1
    a = player_status.file:match("^.*[/](.*)[/]%d+[-%. ].*[/]")
    if a then naughty.notify({text="*/(Artist Name)/Year - Album/*"}) else
    --2
    a = player_status.file:match("^.*[/]%d+ [-] (.*) [-] .*[.].+")
    if a then naughty.notify({text=2}) else
    --3
    a = player_status.file:match("^(.*)[/]%d+ [-] .*[/]")
    if a then naughty.notify({text=3}) else
    --4
    a = player_status.file:match(".*[/].*[/](.*)[/].*[.].+$")
    if a then naughty.notify({text="/path/to/(Artist or VA)/Song name.ext"}) else
    --5
    a = player_status.file:match("^.*[/]([!/]*)[/][!/]*[.].+$")
    if a then naughty.notify({text=5}) else
    --6
    a = player_status.file:match("^(.*)[/]%d+ [-] .*[/]")
    if a then naughty.notify({text=6}) else
    --7
    a = player_status.file:match("^.*[/](.*) [-] [!/]*[.].+")
    if a then naughty.notify({text=7}) else
    --8
    a = player_status.file:match("^(.*)[/]%d+ [-] .*")
    if a then naughty.notify({text=8}) else
    --9
    a = player_status.file:match("^(.*)[/].*")
    if a then a = ''; naughty.notify({text=9})
    end --9
    end --8
    end --7
    end --6
    end --5
    end --4
    end --3
    end --2
    end --1

    local f = player_status.file:match('.*/(.*)$') or ''
    local t = player_status.title or f
    local new_t = ''
    naughty.notify({text=t})
    if t:match('%.mp3') then
      --1
      new_t = t:match('^%d+[%. %-%_]+(.*)%.mp3')
      if new_t then naughty.notify({text="10. - (Song Title).mp3"}) else
      --2
      new_t = t:match('(.*)%.mp3')
      if new_t then naughty.notify({text="(Song Title).mp3"}) else
      new_t = f; naughty.notify({text="Song Title.mp3"})
      end --1
      end --2
    else
      --1
      new_t = f:match(".*[/].* [-] (.*)[.].+$")
      if t then naughty.notify({text="t1"}) else
      --2
      new_t = f:match(".*[/]%d+[ -]+(.*)[.].+$")
      if t then naughty.notify({text="t2"}) else
      --3
      new_t = f:match(".*[/](.*) [.].*")
      if t then naughty.notify({text="t3"}) else
      --4
      new_t = f:match(".*[/](.*)[.].*")
      if t then naughty.notify({text="t4"}) else
      new_t = f; naughty.notify({text="t5"})
      end --4
      end --3
      end --2
      end --1
    end

    if not t or #t == 0 or t:match('%.mp3') then
      player_status.title = new_t
    end
    if not player_status.artist or #player_status.artist == 0 then
      player_status.artist = a
    end

  end -- </>
------------------------------------------------------------------------------

    -- let's insert placeholders for all the missing fields
    for _, k in ipairs({
      'file', 'locationartist', 'title', 'album', 'date', 'cover', 'artist',
    }) do
      if not player_status[k] then
        player_status[k] = N_A
      end
    end
    return player_status
  end
-------------------------------------------------------------------------------
return tag_parser
