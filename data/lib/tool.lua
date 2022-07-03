--[[

    tool.lua by pulsar

        Last change: 2022-05-26

        - a lua tool library with useful functions
        - based on: "luadch/core/util.lua" written by blastbeat and pulsar
        - license: unless otherwise stated: GNU General Public License, Version 3

		usage: local tool = require( "tool" )
		e.g.:  tool.TableIndexChange( tbl, old_index, new_index )



    Application programming interface (API):


    true, err = tool.SaveArray( array, path )

        - saves an array to a local file
        - returns: true, nil on success
        - returns: nil, err if array could not be saved
        - example: result, err = tool.SaveArray( array, path ); if result then ... else ... err

    true, err = tool.SaveTable( tbl, name, path )

        - saves a table to a local file
        - returns: true, nil on success
        - returns: nil, err on error
        - example: result, err = tool.SaveTable( tbl, name, path ); if result then ... else ... err

    table, err = tool.LoadTable( path )

        - loads a local table from file
        - returns: table, nil on success
        - returns: nil, err on error
        - example: tbl, err = tool.LoadTable( path ); if tbl then ... else ... err

    number/nil, number/err, number, number, number = tool.FormatSeconds( t )

        - converts time to: years, days, hours, minutes, seconds
        - returns: number, number, number, number, number (y,d,h,m,s) on success
        - returns: nil, err on error
        - example: y, d, h, m, s = tool.FormatSeconds( os.difftime( os.time( ), signal.get( "start" ) ) ) )

    string/nil = tool.FormatBytes( bytes )

        - convert bytes to the right unit, returns converted bytes as a sting e.g. "209.81 GB"
        - returns: string, nil on success
        - returns: nil, err on error
        - example: string, err = tool.FormatBytes( bytes ); if string then ... else ... err

    string = tool.GeneratePass( len [, mode ] )

        - returns a random generated password string with length = len
        - if no len is specified then len = 20 (max. 1000)
        - if len is invalid then len = 20
		- mode can be:
			nil = alphanumerical (default)
			1 = only characters / 2 = only numbers / 3 = only special charcters /
			4 = characters + numbers (equal to nil) / 5 = characters + numbers + special characters
        - example: pass = tool.GeneratePass( 10 ) or pass = tool.GeneratePass( 10, 5 )

    string/nil, nil/err = tool.TrimString( string )

        - trim whitespaces only from both ends of a string
        - returns: string, nil on success
        - returns: nil, err on error
        - example: string, err = tool.TrimString( string ); if string then ... else ... err

    true/nil, nil/err = tool.TableIsEmpty( tbl )

        - check if a table is empty
        - returns: true, nil on success
        - returns nil, err if param is not a table or table is not empty
        - example: result, err = tool.TableIsEmpty( tbl ); if result then ... else ... err

    true/nil, nil/err = tool.TableIndexExists( tbl, index )

        - check if a table index exists
        - returns: true, nil if index exists
        - returns: nil, nil if index not exists
        - returns: nil, err if tbl is not a table
        - example: result, err = tool.TableIndexExists( tbl, index ); if result then ... else ... err

    true/nil, nil/err = tool.TableIndexChange( tbl, old_index, new_index )

        - check if a table index exists
        - returns: true, nil on success
        - returns: nil, err on error
        - example: result, err = tool.TableIndexChange( tbl, old_index, new_index ); if result then .. else .. err

    true/nil, err = tool.FileExists( str )

        - check if a file exists
        - returns: true if file exists
        - returns: nil, err on error
        - example: result, err = tool.FileExists( str ); if result then ... else err

    true/nil, msg/err = tool.MakeFile( file )

        - make an empty file (textfile) if not exists
        - returns: true, msg if new file was created
        - returns: nil, msg if file already exists
        - returns: nil, err if file could not created
        - example: result, err = tool.MakeFile( file ); if result then ... else err

    true/nil, msg/err = tool.ClearFile( file )

        - clears a file (textfile)
        - returns: true, msg if file was cleared
        - returns: nil, err if file could not be cleared or not found
        - example: result, err = tool.ClearFile( file ); if result then ... else err

    true/nil, msg/err = tool.FileWrite( txt, file[, timestamp] )

        - write text in a new line on the bottom of a file optional with timestamp
        - returns: true, msg if text was successfully written
        - returns: nil, err if text could not be written
        - timestamp is optional and has three posible values: "time" or "date" or "both"
        - example: result, err = tool.FileWrite( txt, file[, timestamp] ); if result then .. else err

    tool.spairs( tbl[, func] )

        - sorted by indexes, like ipairs but for alphabetical indices order
        - based on http://www.lua.org/pil/19.3.html written by Roberto Ierusalimschy
        - license: MIT License
        - argument #2 is optional and similar to the second optional argument in table.sort function
        - example: for k, v in tool.spairs( tbl ) do print( k, v )

    string/nil, nil/err = num2hex( num )

        - converts number to hex - HEX representation of num
        - returns: string, nil on success
        - returns: nil, err on error
        - based on a script by ukpyr
        - example: result, err = num2hex( num ); if result then ... else err

    string/nil, nil/err = str2hex( str )

        - converts string to hex - HEX representation of str
        - returns: string, nil on success
        - returns: nil, err on error
        - based on a script by ukpyr
        - example: result, err = str2hex( str ); if result then ... else err

    string/nil, nil/err = str2base64( str )

        - string to base64 - BASE64 representation of str
        - returns: string, nil on success
        - returns: nil, err on error
        - based on a script by ukpyr
        - example: result, err = str2base64( str ); if result then ... else err

	string/nil, nil/err = benchmark( func [, repeats] )

		- simple benchmark - repeats a function n times
		- returns: a string with the elapsed time in seconds
		- returns: nil, err on error
		- default repeats: 1000
		- example: result, err = benchmark( func, 50000 )

]]


------------------------------
-- DEFINITION / DECLARATION --
------------------------------

--// functions
local SortSerialize
local SaveArray
local SaveTable
local LoadTable
local FormatSeconds
local FormatBytes
local GeneratePass
local TrimString
local TableIsEmpty
local TableIndexExists
local TableIndexChange
local FileExists
local MakeFile
local ClearFile
local FileWrite
local spairs
local num2hex
local str2hex
local str2base64
local benchmark

--// table lookups
local os_time = os.time
local os_date = os.date
local os_clock = os.clock
local io_open = io.open
local math_floor = math.floor
local math_random = math.random
local math_randomseed = math.randomseed
local math_fmod = math.fmod
local string_format = string.format
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local string_byte = string.byte
local table_insert = table.insert
local table_sort = table.sort


----------
-- CODE --
----------

--// Helper function for data serialization by blastbeat
SortSerialize = function( tbl, name, file, tab, r )
    tab = tab or ""
    local temp = { }
    for key, k in pairs( tbl ) do
        --if type( key ) == "string" or "number" then
            table_insert( temp, key )
        --end
    end
    table_sort( temp )
    local str = tab .. name
    if r then
        file:write( str .. " {\n\n" )
    else
        file:write( str .. " = {\n\n" )
    end
    for k, key in ipairs( temp ) do
        if ( type( tbl[ key ] ) ~= "function" ) then
            local skey = ( type( key ) == "string" ) and string_format( "[ %q ]", key ) or string_format( "[ %d ]", key )
            if type( tbl[ key ] ) == "table" then
                SortSerialize( tbl[ key ], skey, file, tab .. "    " )
                file:write( ",\n" )
            else
                local svalue = ( type( tbl[ key ] ) == "string" ) and string_format( "%q", tbl[ key ] ) or tostring( tbl[ key ] )
                file:write( tab .. "    " .. skey .. " = " .. svalue )
                file:write( ",\n" )
            end
        end
    end
    file:write( "\n" )
    file:write( tab .. "}" )
end

--// saves an array to a local file - by blastbeat
SaveArray = function( array, path )
    array = array or { }
    local file, err = io_open( path, "w+" )
    if not file then
        return nil, "tool.lua: " .. err
    end
    local iterate, savetbl
    iterate = function( tbl )
        local tmp = { }
        for key, value in pairs( tbl ) do
            tmp[ #tmp + 1 ] = tostring( key )
        end
        table_sort( tmp )
        for i, key in ipairs( tmp ) do
            key = tonumber( key ) or key
            if type( tbl[ key ] ) == "table" then
                file:write( ( ( type( key ) ~= "number" ) and tostring( key ) .. " = " ) or " " )
                savetbl( tbl[ key ] )
            else
                file:write( ( ( type( key ) ~= "number" and tostring( key ) .. " = " ) or "" ) .. ( ( type( tbl[ key ] ) == "string" ) and string_format( "%q", tbl[ key ] ) or tostring( tbl[ key ] ) ) .. ", " )
            end
        end
    end
    savetbl = function( tbl )
        local tmp = { }
        for key, value in pairs( tbl ) do
            tmp[ #tmp + 1 ] = tostring( key )
        end
        table_sort( tmp )
        file:write( "{ " )
        iterate( tbl )
        file:write( "}, " )
    end
    file:write( "return {\n\n" )
    for i, tbl in ipairs( array ) do
        if type( tbl ) == "table" then
            file:write( "    { " )
            iterate( tbl )
            file:write( "},\n" )
        else
            file:write( "    " .. string_format( "%q", tostring( tbl ) ) .. ",\n" )
        end
    end
    file:write( "\n}" )
    file:close( )
    return true
end

--// saves a table to a local file - by blastbeat
SaveTable = function( tbl, name, path )
    local file, err = io_open( path, "w+" )
    if file then
        file:write( "local " .. name .. "\n\n" )
        SortSerialize( tbl, name, file, "" )
        file:write( "\n\nreturn " .. name )
        file:close( )
        return true
    else
        return nil, "tool.lua: " .. err
    end
end

--// loads a local table from file - by blastbeat
LoadTable = function( path )
    local file, err = io_open( path, "r" )
    if not file then
        return nil, "tool.lua: " .. err
    end
    local content = file:read "*a"
    file:close( )
    local chunk, err = loadstring( content )
    if chunk then
        local ret = chunk( )
        if ret and type( ret ) == "table" then
            return ret
        else
            return nil, "tool.lua: error in LoadTable(), invalid table"
        end
    end
    return nil, "tool.lua: " .. err
end

--// converts seconds to: years, days, hours, minutes, seconds
FormatSeconds = function( t )
    local t = tonumber( t )
    if not t then
        return nil, "tool.lua: error: number expected, got nil"
    end
    if not type( t ) == "number" then
        return nil, "tool.lua: error: number expected, got " .. type( t )
    end
    if ( t < 0 ) or ( t == 1 / 0 ) then
        return nil, "tool.lua: error: parameter not valid"
    end
    return
        math.floor( t / ( 60 * 60 * 24 ) / 365 ), -- years
        math.floor( t / ( 60 * 60 * 24 ) ) % 365, -- days
        math.floor( t / ( 60 * 60 ) ) % 24, -- hours
        math.floor( t / 60 ) % 60, -- minutes
        t % 60 -- seconds
end

--// convert bytes to the right unit - based on a function by Night
FormatBytes = function( bytes )
    local bytes = tonumber( bytes )
    if ( not bytes ) or ( not type( bytes ) == "number" ) or ( bytes < 0 ) or ( bytes == 1 / 0 ) then
        return nil, "tool.lua: error in FormatBytes(), invalid parameter"
    end
    if bytes == 0 then return "0 B" end
    local i, units = 1, { "B", "KB", "MB", "GB", "TB", "PB", "EB", "YB" }
    while bytes >= 1024 do
        bytes = bytes / 1024
        i = i + 1
    end
    if units[ i ] == "B" then
        return string_format( "%.0f", bytes ) .. " " .. ( units[ i ] or "?" )
    else
        return string_format( "%.2f", bytes ) .. " " .. ( units[ i ] or "?" )
    end
end

--// returns a random generated password - based on a function by blastbeat
GeneratePass = function( len, mode )
    local len = tonumber( len )
	if not ( type( len ) == "number" ) or ( len < 0 ) or ( len > 1000 ) then len = 20 end
	if not ( type( mode ) == "number" ) then mode = nil end
    local lower = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
    local upper = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
	local special = { "!", "?", "@", "(", ")", "{", "}", "[", "]", "\\", "/", "=", "~", "$", "%", "&", "#", "*", "-", "+", ".", ",", "_" }
    math_randomseed( os_time() )
    local pwd = ""
	--// mode "1"
	if ( mode == 1 ) then
		for i = 1, len do
			local X = math_random( 0, 9 )
			if ( X < 6 ) then
				pwd = pwd .. upper[ math_random( 1, 25 ) ]
			else
				pwd = pwd .. lower[ math_random( 1, 25 ) ]
			end
		end
	end
	--// mode "2"
	if ( mode == 2 ) then
		for i = 1, len do
			pwd = pwd .. math_random( 0, 9 )
		end
	end

	--// mode "3"
	if ( mode == 3 ) then
		for i = 1, len do
			pwd = pwd .. special[ math_random( 1, 23 ) ]
		end
	end
	--// mode "4" and nil
	if ( mode == nil ) or ( mode == 4 ) then
		for i = 1, len do
			local X = math_random( 0, 9 )
			if X < 4 then
				pwd = pwd .. math_random( 0, 9 )
			elseif ( X >= 4 ) and ( X < 6 ) then
				pwd = pwd .. upper[ math_random( 1, 25 ) ]
			else
				pwd = pwd .. lower[ math_random( 1, 25 ) ]
			end
		end
	end
	--// mode "5"
	if ( mode == 5 ) then
		for i = 1, len do
			local X = math_random( 0, 16 )
			if X <= 4 then
				pwd = pwd .. math_random( 0, 9 )
			elseif ( X >= 5 ) and ( X < 9 ) then
				pwd = pwd .. upper[ math_random( 1, 25 ) ]
			elseif ( X >= 9 ) and ( X < 13 ) then
				pwd = pwd .. lower[ math_random( 1, 25 ) ]
			else
				pwd = pwd .. special[ math_random( 1, 23 ) ]
			end
		end
	end
    return pwd
end

--// trim whitespaces from both ends of a string - by pulsar
TrimString = function( str )
    local str = tostring( str )
    if type( str ) ~= "string" then
        return nil, "tool.lua: error in TrimString(), string expected, got " .. type( str )
    end
    return string_find( str, "^%s*$" ) and "" or string_match( str, "^%s*(.*%S)" )
end

--// check if a table is empty - by pulsar
TableIsEmpty = function( tbl )
    if type( tbl ) ~= "table" then
        return nil, "tool.lua: error in TableIsEmpty(), table expected, got " .. type( tbl )
    end
    if next( tbl ) == nil then
        return true
    end
    return nil, "tool.lua: table in not empty"
end

--// check if a table index exists - by pulsar
TableIndexExists = function( tbl, index )
    if type( tbl ) ~= "table" then
        return nil, "tool.lua: error in TableIndexExists(), table expected for #1, got " .. type( tbl )
    end
    if tbl[ index ] ~= nil then
        return true
    else
        return nil
    end
end

--// change index in a table, new index has to be a string or a number
TableIndexChange = function( tbl, old_index, new_index )
    if type( tbl ) ~= "table" then
        return nil, "tool.lua: error in TableIndexChange(), table expected for #1, got " .. type( tbl )
    end
    if ( type( old_index ) ~= "string" ) and ( type( old_index ) ~= "number" ) then
        return nil, "tool.lua: error in TableIndexChange(), string or number expected for #2, got " .. type( old_index )
    end
    if ( type( new_index ) ~= "string" ) and ( type( new_index ) ~= "number" ) then
        return nil, "tool.lua: error in TableIndexChange(), string or number expected for #3, got " .. type( new_index )
    end
    local exists, err = TableIndexExists( tbl, old_index )
    if exists then
        local old_value = tbl[ old_index ]
        tbl[ new_index ] = old_value
        tbl[ old_index ] = nil
        return true, "tool.lua: table index successfully changed"
    else
        return nil, "tool.lua: table index not found"
    end
end

--// check if a file exists - by pulsar
FileExists = function( file )
    if type( file ) ~= "string" then
        return nil, "tool.lua: error in FileExists(), string expected, got " .. type( file )
    end
    local f, err = io_open( file, "r" )
    if f then
        f:close()
        return true
    else
        return nil, "tool.lua: error in FileExists(), could not check file because: " .. err
    end
end

--// make an empty file (textfile) if not exists - by pulsar
MakeFile = function( file )
    if not FileExists( file ) then
        local f, err = io_open( file, "w" )
        if f then
            f:close()
            return true, "tool.lua: file successfully created"
        else
            return nil, "tool.lua: error in MakeFile(), could not create file, reason: " .. err
        end
    else
        return nil, "tool.lua: error in MakeFile(), file already exists"
    end
end

--// clears a file (textfile) - by pulsar
ClearFile = function( file )
    if type( file ) ~= "string" then
        return nil, "tool.lua: error in ClearFile(), string expected, got " .. type( file )
    end
    if FileExists( file ) then
        local f, err = io_open( file, "w" )
        if f then
            f:close()
            return true, "tool.lua: file successfully cleared"
        else
            return nil, "tool.lua: error in ClearFile(), file could not be cleared because: " .. err
        end
    else
        return nil, "tool.lua: error in ClearFile(), file not found"
    end
end

--// write text in a new line on the bottom of a file optional with timestamp - by pulsar
FileWrite = function( txt, file, timestamp )
    if type( txt ) ~= "string" then
        return nil, "tool.lua: error in FileWrite(), string expected for #1, got " .. type( txt )
    end
    if type( file ) ~= "string" then
        return nil, "tool.lua: error in FileWrite(), string expected for #2, got " .. type( file )
    end
    if ( not timestamp ) or ( type( timestamp ) ~= "string" ) then timestamp = "" end
    if timestamp == "time" then timestamp = "[" .. os_date( "%H:%M:%S" ) .. "] " end
    if timestamp == "date" then timestamp = "[" .. os_date( "%Y-%m-%d" ) .. "] " end
    if timestamp == "both" then timestamp = "[" .. os_date( "%Y-%m-%d %H:%M:%S" ) .. "] " end
    local result, err = FileExists( file )
    if result then
        local f, err = io_open( file, "a+" )
        if f then
            f:write( timestamp .. txt .. "\n" )
            f:close()
            return true, "tool.lua: successfully write text to file"
        else
            return nil, "tool.lua: error in FileWrite(), could not write text to file because: " .. err
        end
    else
        return nil, "tool.lua: " .. err
    end
end

--// like ipairs for alphabetical indices -- based on http://www.lua.org/pil/19.3.html
spairs = function( tbl, func )
    local arr = {}
    for n in pairs( tbl ) do
        table_insert( arr, n )
    end
    table_sort( arr, func )
    local i = 0
    local iter = function()
        i = i + 1
        if arr[ i ] == nil then
            return nil
        else
            return arr[ i ], tbl[ arr[ i ] ]
        end
    end
    return iter
end

--// number to hex - returns HEX representation of num - based on a script by ukpyr
num2hex = function( num )
    if type( num ) ~= "number" then
        return nil, "tool.lua: error in num2hex(), number expected, got " .. type( num )
    end
    local hexstr = "0123456789abcdef"
    local s = ""
    while num > 0 do
        local mod = math_fmod( num, 16 )
        s = string_sub( hexstr, mod + 1, mod + 1 ) .. s
        num = math_floor( num / 16 )
    end
    if s == "" then s = "0" end
    return s
end

--// string to hex - returns HEX representation of str - based on a script by ukpyr
str2hex = function( str )
    if type( str ) ~= "string" then
        return nil, "tool.lua: error in str2hex(), string expected, got " .. type( str )
    end
    local hex = ""
    while #str > 0 do
        local hb = num2hex( string_byte( str, 1, 1 ) )
        if #hb < 2 then hb = "0" .. hb end
        hex = hex .. hb
        str = string_sub( str, 2 )
    end
    return hex
end

--// string to base64 - returns BASE64 representation of str - based on a script by ukpyr
str2base64 = function( str )
    if type( str ) ~= "string" then
        return nil, "tool.lua: error in str2base64(), string expected, got " .. type( str )
    end
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local s64 = ""
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
        for byte_cnt = 1, 3 do
            buf = ( buf * 256 )
            if #str > 0 then
                buf = buf + string_byte( str, 1, 1 )
                str = string_sub( str, 2 )
                bytes_num = bytes_num + 1
            end
        end
        for group_cnt = 1,( bytes_num + 1 ) do
            b64char = math_fmod( math_floor( buf / 262144 ), 64 ) + 1
            s64 = s64 .. string_sub( b64chars, b64char, b64char )
            buf = buf * 64
        end
        for fill_cnt = 1,( 3 - bytes_num ) do
            s64 = s64 .. "="
        end
    end
    return s64
end

--// repeats a function n times and returns a string with the elapsed time in seconds - by pulsar
benchmark = function( func, repeats ) -- default repeats: 10.000.000
    if type( func ) ~= "function" then
        return nil, "tool.lua: error in benchmark(), function expected for #1, got " .. type( func )
    end
    if ( not repeats ) or type( repeats ) ~= "number" then repeats = 1000 end
    local start = os_clock()
    for i = 1, repeats do func() end
    return string_format( "elapsed time: %s seconds, loops: " .. repeats, os_clock() - start )
end

return {

    SaveTable = SaveTable,
    LoadTable = LoadTable,
    SaveArray = SaveArray,
    FormatSeconds = FormatSeconds,
    FormatBytes = FormatBytes,
    GeneratePass = GeneratePass,
    TrimString = TrimString,
    TableIsEmpty = TableIsEmpty,
    TableIndexExists = TableIndexExists,
    TableIndexChange = TableIndexChange,
    FileExists = FileExists,
    MakeFile = MakeFile,
    ClearFile = ClearFile,
    FileWrite = FileWrite,
    spairs = spairs,
    num2hex = num2hex,
    str2hex = str2hex,
    str2base64 = str2base64,
	benchmark = benchmark,

}