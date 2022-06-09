#!/usr/bin/env lua
-- This is the wrapper for RandomFortunes to allow it to be used on the command line.

-- arg is the array of arguments on the command line.
-- 0 is the command name,  #arg is the number of commands on the command line

-- over-ride or define stubs for functions
strfind = string.find
strsub = string.sub

-- Seed the random generator
math.randomseed( os.time() )

function GetAddOnMetadata( )
	return "@VERSION@"
end

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
function RF.MakeLuckyNumber()
	-- Returns a string of 6 'lucky' numbers'
	local luckyNumbers = {};
	local uniqueNumbers = {};
	local i = 6;  -- choose 6 numbers
	while i > 0 do
		local r = math.random(49);
		if not uniqueNumbers[r] then
			table.insert( luckyNumbers, r );
			uniqueNumbers[r] = true;
			i = i - 1;
		end
	end
	return "("..table.concat( luckyNumbers, "-" )..")";
end
function RF.GetFortune( indexIn )
	indexIn = tonumber( indexIn )
	tableSize = #RF_fortunes
	local fortuneIdx = 1
	local fortuneStr = nil
	if tableSize > 0 then
		RF.oldestPost = os.time() - (RF_options.delay * tableSize)
		if indexIn and indexIn > 0 and indexIn <= tableSize then
			fortuneIdx = indexIn
		else
			local tryLimit = 6
			repeat  -- try to randomly find a fortune that has not been posted recently up to 6 times
				fortuneIdx = math.random(tableSize)
				tryLimit = tryLimit - 1
			until (RF_fortunes[fortuneIdx].lastPost <= RF.oldestPost or tryLimit == 0)
		end
		RF_options.lastPost = os.time()
		RF_fortunes[fortuneIdx].lastPost = RF_options.lastPost
		RF_fortunes[fortuneIdx].count = RF_fortunes[fortuneIdx].count and RF_fortunes[fortuneIdx].count + 1 or 1
		fortuneStr = RF_fortunes[fortuneIdx].fortune
	end
	return fortuneStr, fortuneIdx
end
function RF.PostFortune( indexIn )
	local fortuneStr, fortuneIdx = RF.GetFortune( indexIn )
	if fortuneStr then
		local lottoNumbers = RF_options.lotto and RF.MakeLuckyNumber() or ""
		RF.Print( string.format( "%s %s", fortuneStr, lottoNumbers ) )
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
function RF.List( listType, num )
	-- listType = "first", "last", "unposted"
	num = tonumber( num )
	num = num or 1
	-- print( "RF.List( "..listType..", "..( num or "nil" ).." )" )

	local timeStamps = {}
	for i, fData in pairs( RF_fortunes ) do
		table.insert( timeStamps, { fData.lastPost, i } )
	end
	table.sort( timeStamps, function( a, b ) if a[1] < b[1] then return true; end; end )

	local outFormat = string.format( "%%s [%%%ii] %%s", math.max( math.ceil( math.log10( #RF_fortunes ) ), 1 ) )
	-- count the number not posted
	local numNotPosted = 0
	for i in ipairs( timeStamps ) do
		if timeStamps[i][1] == 0 then
			numNotPosted = numNotPosted + 1
		else
			break
		end
	end
	-- print( "numNotPosted: ".. numNotPosted )
	if listType == "first" then
		for i = numNotPosted + 1, numNotPosted + 1 + num - 1 do
			-- print( "i:"..i.." index:"..timeStamps[i][2] )
			print( string.format( outFormat, os.date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	elseif listType == "last" then
		for i = #timeStamps, #timeStamps - num + 1, -1 do
			print( string.format( outFormat, os.date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	elseif listType == "unposted" then
		for i = 1, numNotPosted do
			print( string.format( outFormat, os.date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	end
end
function RF.AddFortune( fortune )
	if (#fortune > 0) then
		table.insert( RF_fortunes, {["fortune"] = fortune, ["lastPost"]=0} );
		RF.Print("Added: "..fortune);
	end
end
function RF.Delete( index )
	-- Delete RF_fortunes[index]
	-- TODO: design a system that this marks the Fortune for deletion, disabling it, delete on reload, or delete after time period
	-- TODO: enable a way to see fortunes about to be deleted, and recover them.
	index = tonumber(index)
	if index and index>0 and index<=#RF_fortunes then
		local fortune = table.remove( RF_fortunes, index ) -- use the table.remove to remove a value
		RF.Print(COLOR_RED.."REMOVING: "..COLOR_END..fortune.fortune)
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
	},
	["find"] = {
		["func"] = RF.Find,
		["help"] = {"search", "Find a known fortune containing <search>"},
	},
	["now"] = {
		["func"] = RF.PostFortune,
		["help"] = {"[number]", "Print fortune now. [number] optionally posts "},
	},
	["add"] = {
		["func"] = function(param)
				RF.AddFortune(param);
			end,
		["help"] = {"fortune","Adds fortune to the list of fortunes."},
	},
	["rm"] = {
		["func"] = RF.Delete,
		["help"] = {"index", "Delete the fortune at <index>"},
	},
	["list"] = {
		["func"] = function()
				RF.Find();  -- pass no parameters for the list command
			end,
		["help"] = {"", "List all fortunes."},
	},
	["last"] = {
		["func"] = function( num ) RF.List( "last", num ); end,
		["help"] = {"number", "List the last <number> of posted fortunes."},
	},
	["first"] = {
		["func"] = function( num ) RF.List( "first", num ); end,
		["help"] = { "number", "List the first <number> of posted fortunes." },
	},
	["unposted"] = {
		["func"] = function() RF.List( "unposted" ); end,
		["help"] = {"", "List the unposted fortunes." },
	},
}

if #arg > 0 then
	-- Handle Command line
	for n = 1, #arg do
		RF.Command( arg[n] )
	end
else
	print( "Random Fortunes (v"..GetAddOnMetadata()..")" )
	running = true
end

-- run the Command Loop
while running do
	io.write( "> " )
	val = io.read("*line")
	RF.Command( val )
end

-- Save output
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
