--[[
   Save Table to File
   Load Table from File
   v 1.0

   Lua 5.2 compatible

   Only Saves Tables, Numbers and Strings
   Insides Table References are saved
   Does not save Userdata, Metatables, Functions and indices of these
   ----------------------------------------------------
   table.save( table , filename )

   on failure: returns an error msg

   ----------------------------------------------------
   table.load( filename or stringtable )

   Loads a table that has been saved via the table.save function

   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------

   Licensed under the same terms as Lua itself.
]]--

-- ported to Gio by Y. Kirylau

local lgi = require("lgi")
local gio = lgi.Gio
local glib = lgi.GLib

local pickle = {}
  -- declare local variables
  --// exportstring( string )
  --// returns a "Lua" portable version of the string
  local function exportstring( s )
     return string.format("%q", s)
  end

  function pickle.marshal( tbl )
    local file = {
      result = '',
      write = function(f, s)
        f.result = f.result .. s
      end
    }
    local charS,charE = "   ","\n"
    -- initiate variables for save procedure
    local tables,lookup = { tbl },{ [tbl] = 1 }
    file:write( "return {"..charE )

    for idx,t in ipairs( tables ) do
       file:write( "-- Table: {"..idx.."}"..charE )
       file:write( "{"..charE )
       local thandled = {}

       for i,v in ipairs( t ) do
          thandled[i] = true
          local stype = type( v )
          -- only handle value
          if stype == "table" then
             if not lookup[v] then
                table.insert( tables, v )
                lookup[v] = #tables
             end
             file:write( charS.."{"..lookup[v].."},"..charE )
          elseif stype == "string" then
             file:write(  charS..exportstring( v )..","..charE )
          elseif stype == "number" or stype == "boolean" then
             file:write(  charS..tostring( v )..","..charE )
          end
       end

       for i,v in pairs( t ) do
          -- escape handled values
          if (not thandled[i]) then

             local str = ""
             local stype = type( i )
             -- handle index
             if stype == "table" then
                if not lookup[i] then
                   table.insert( tables,i )
                   lookup[i] = #tables
                end
                str = charS.."[{"..lookup[i].."}]="
             elseif stype == "string" then
                str = charS.."["..exportstring( i ).."]="
             elseif stype == "number" or stype == "boolean" then
                str = charS.."["..tostring( i ).."]="
             end

             if str ~= "" then
                stype = type( v )
                -- handle value
                if stype == "table" then
                   if not lookup[v] then
                      table.insert( tables,v )
                      lookup[v] = #tables
                   end
                   file:write( str.."{"..lookup[v].."},"..charE )
                elseif stype == "string" then
                   file:write( str..exportstring( v )..","..charE )
                elseif stype == "number" or stype == "boolean" then
                   file:write( str..tostring( v )..","..charE )
                end
             end
          end
       end
       file:write( "},"..charE )
    end
    file:write( "}" )
    return file.result
  end

  --// The Save Function
  function pickle.save(  tbl,filename,callback )
    log("PICKLE: writing to file...")
    local gfile = gio.File.new_for_path(filename)

    gfile:query_info_async(
      "standard::type,access::can-read",
      gio.FileQueryInfoFlags.NONE, glib.PRIORITY_DEFAULT,
      nil,
      function(_, gfileinfo_result)
        local gfileinfo = gfile:query_info_finish(gfileinfo_result)
        if not (
          gfileinfo and gfileinfo:get_file_type() ~= "DIRECTORY" and
          gfileinfo:get_attribute_boolean("access::can-read")
        ) then
          log("PICKLE: creating file...")
          gfile:create_readwrite_async(gio.FileCreateFlags.NONE, glib.PRIORITY_DEFAULT, nil, function(_, create_result)
            log{
              "file created",
              gfile:create_readwrite_finish(create_result)
            }
            pickle.save(tbl, filename, callback)
          end, nil) -- create_readwrite end
        else

          gfile:open_readwrite_async(glib.PRIORITY_DEFAULT, nil, function(_, io_stream_result)
            local io_stream = gfile:open_readwrite_finish(io_stream_result)
            io_stream:seek(0, glib.SeekType.SET, nil)
            local file = io_stream:get_output_stream()
            local data = pickle.marshal(tbl)
            log{"PICKLE: writing data", data}
            file:write_all_async(data, glib.PRIORITY_DEFAULT, nil, function(_, write_result)
              local length_written = file:write_all_finish(write_result)
              log{
                "file written",
                length_written
              }
              file:truncate(length_written, nil)
              file:close_async(glib.PRIORITY_DEFAULT, nil, function(_, file_close_result)
                log{
                  "output stream closed",
                  file:close_finish(file_close_result)
                }
                io_stream:close_async(glib.PRIORITY_DEFAULT, nil, function(_, stream_close_result)
                  log{
                    "stream closed",
                    io_stream:close_finish(stream_close_result)
                  }
                  if callback then
                    callback()
                  end
                end, nil) -- io_stream:close end
              end, nil) -- file:close end
            end, nil) -- file:write end
          end, nil) -- open_readwrite end

        end

    end, nil)  -- query_info_async - end

  end

  --// The Load Function
  function pickle.load( sfile )
    log("PICKLE: reading from file...")
     local ftables,err = loadfile( sfile )
     if err then return nil, err end
     local tables = ftables()
     for idx = 1,#tables do
        local tolinki = {}
        for i,v in pairs( tables[idx] ) do
           if type( v ) == "table" then
              tables[idx][i] = tables[v[1]]
           end
           if type( i ) == "table" and tables[i[1]] then
              table.insert( tolinki,{ i,tables[i[1]] } )
           end
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
           tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
     end
     return tables[1]
  end
-- close do
return pickle

-- ChillCode
