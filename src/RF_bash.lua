#!/usr/bin/env lua
-- This is the wrapper for RandomFortunes to allow it to be used on the command line.

-- arg is the array of arguments on the command line.
-- 0 is the command name,  #arg is the number of commands on the command line

-- over-ride or define stubs for functions
strfind = string.find
strsub = string.sub

function GetAddOnMetadata( )
	return "@VERSION@"
end

-- import the addon file
--package.path = "/usr/local/bin/?.lua;'" .. package.path
--require "c"

-- find ~/.RF
pathSeparator = string.sub( package.config, 1, 1 ) -- first character of this string (http://www.lua.org/manual/5.2/manual.html#pdf-package.config)
settingsFilePath = {
	os.getenv( "HOME" ),
	".RF"
}
settingsFile = table.concat( settingsFilePath, pathSeparator )
-- load ~/.RF
function DoFile( filename )
	local f, err = loadfile( filename )
	if f then
		return f()
	else
		dataFile = nil
	end
end
DoFile( settingsFile )

print( "Random Fortunes (v"..GetAddOnMetadata()..")" )

-- if the dataFile is known, load it.   Else, prompt the user until it is found.
if dataFile then
	DoFile( dataFile )
else
	while (not dataFile) do
		print( "Please locate the data file." )
		print( "What is the path to the dataFile?" )
		io.write( ":" )
		path = io.read( "*line" )
		path = string.gsub( path, "\\", "" )
		path = string.gsub( path, "^%s*(.-)%s*$", "%1" )
		DoFile( path )
		if RF_fortunes then
			dataFile = path
			print( "Found it!   Thank you.")
		end
	end
end

RF = {}  -- do not confuse this with the addon

function RF.Print(msg)
	print(msg)
end

function RF.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)");  --contiguous string of non-space characters
		if a then
			return c, strsub(msg, b+2);
		else
			return "";
		end
	end
end
function RF.PrintHelp()
	for cmd, info in pairs(RF.CommandList) do
		print(string.format("\t%s %s -> %s",
			cmd, info.help[1], info.help[2]));
	end
end
function RF.Command(msg)
	local cmd, param = RF.ParseCmd(msg);
	cmd = string.lower(cmd);
	local cmdFunc = RF.CommandList[cmd];
	if cmdFunc then
		cmdFunc.func(param)
		return 1
	end
end

function RF.Find( search )
	-- Looks for fortunes that contain 'search'
	-- Returns numberOfFortunesFound
	search = search and string.upper(search) or ""
	-- create format string with correct size to list all fortunes if all are returned.  %% is resolved to %
	local outFormat = string.format("[%%%ii] %%s", math.max(math.ceil(math.log10(#RF_fortunes)), 1))

	local numFound = 0
	for i, fData in pairs(RF_fortunes) do
		if strfind( string.upper(fData.fortune), search ) then
			RF.Print(string.format(outFormat, i, fData.fortune ))
			numFound = numFound + 1
		end
	end
	if numFound and numFound>0 then
		return numFound
	end
end

RF.CommandList = {
	["help"] = {
		["func"] = RF.PrintHelp,
		["help"] = {"","Print this help."},
	},
	["quit"] = {
		["func"] = function() running = false; end,
		["help"] = {"","Quit the application." },
	},
	["exit"] = {
		["func"] = function() running = false; end,
		["help"] = {"","Quit the application." },
	},
	["q"] = {
		["func"] = function() running = false; end,
		["help"] = {"","Quit the application." },
	},
	["list"] = {
		["func"] = function()
				RF.Find();  -- pass no parameters for the list command
			end,
		["help"] = {"", "List all fortunes."},
	}
}

-- Start the program
running = true

-- run the calc
while running do
	io.write( "> " )
	val = io.read("*line")
	RF.Command( val )
end

function EscapeStr( strIn )
	-- This escapes a str
	strIn = string.gsub( strIn, "\\", "\\\\" )
	strIn = string.gsub( strIn, "\"", "\\\"" )
	return strIn
end

function WriteTable( file, tableIn, depth )
	if not depth then depth = 1; end
	for k, v in pairs( tableIn ) do
		file:write( ("%s[\"%s\"] = "):format( string.rep("\t", depth), k ) )
		if ( type( v ) == "boolean" ) then
			file:write( v and "true" or "false" )
		elseif ( type( v ) == "table" ) then
			file:write( "{\n" )
			WriteTable( file, v, depth+1 )
			file:write( ("%s}"):format( string.rep("\t", depth) ) )
		elseif ( type( v ) == "string" ) then
			file:write( EscapeStr( v ) )
		else
			file:write( v )
		end
		file:write( ",\n" )
	end
end

-- save ~/.RF
file, err = io.open( settingsFile, "w" )
if err then
	print( err )
else
	file:write( "dataFile = \""..dataFile.."\"\n" )
	io.close( file )
end
-- save RF.lua datafile
file, err = io.open( dataFile, "w" )
if err then
	print( err )
else
	file:write( "RF_fortunes = {\n" )
    for i, fData in ipairs( RF_fortunes ) do
    	file:write( "\t{\t[\"fortune\"] = \""..EscapeStr(fData["fortune"]).."\",\n" )
    	file:write( "\t\t[\"lastPost\"] = "..fData["lastPost"].." }, -- ["..i.."]\n" )
    end
    file:write( "}\n" )
    file:write( "RF_options = {\n" )
    WriteTable( file, RF_options )
    file:write( "}\n" )
end




