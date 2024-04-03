#!/usr/bin/env lua
-- Version: @VERSION@

accountPath = arg[1]
exportType = arg[2]

pathSeparator = string.sub(package.config, 1, 1) -- first character of this string (http://www.lua.org/manual/5.2/manual.html#pdf-package.config)
-- remove 'extra' separators from the end of the given path
while (string.sub( accountPath, -1, -1 ) == pathSeparator) do
	accountPath = string.sub( accountPath, 1, -2 )
end
-- append the expected location of the datafile
dataFilePath = {
	accountPath,
	"SavedVariables",
	"RF.lua"
}
dataFile = table.concat( dataFilePath, pathSeparator )

function FileExists( name )
	local f = io.open( name, "r" )
	if f then io.close( f ) return true else return false end
end
function DoFile( filename )
	local f = assert( loadfile( filename ) )
	return f()
end
function ExportXML()
	strOut = "<?xml version='1.0' encoding='utf-8' ?>\n";
	strOut = strOut .. "<fortunes>\n";

	for _,fortuneStruct in sorted_pairs(RF_fortunes) do
		strOut = strOut .. string.format('\t<fortune lastPost="%i"><![CDATA[%s]]></fortune>\n',
				fortuneStruct.lastPost, fortuneStruct.fortune)
	end

	strOut = strOut .. "</fortunes>"
	return strOut
end
function ExportJSON()
	strOut = '{"fortunes": [\n'

	fortunes = {}

	for _,fortuneStruct in sorted_pairs(RF_fortunes) do
		fortune = string.gsub( fortuneStruct.fortune, '\\', '\\\\')
		fortune = string.gsub( fortuneStruct.fortune, '\"', '\\\"')
		table.insert( fortunes, string.format('\t{ "lastPost": %.0f, "fortune": "%s" }', fortuneStruct.lastPost * 1000, fortune ) )
	end

	strOut = strOut .. table.concat( fortunes, ",\n" )

	strOut = strOut .. "]}"

	return strOut
end
function ExportPHP()
	strOut = "<?php\n$RFTable = array(\n";
	for _, RFs in sorted_pairs(RF_fortunes) do
		strOut = strOut .. string.format("\tarray('fortune'=>\"%s\", 'lastPost'=>\"%s\"),\n",
				RFs.fortune, RFs.lastPost)
	end
	strOut = strOut .. ");\n?>"

	return strOut
end
function sorted_pairs( tableIn )
	local keys = {}
	for k in pairs( tableIn ) do table.insert( keys, k ) end
	table.sort( keys )
	local lcv = 0
	local iter = function()
		lcv = lcv + 1
		if keys[lcv] == nil then return nil
		else return keys[lcv], tableIn[keys[lcv]]
		end
	end
	return iter
end

functionList = {
	["xml"] = ExportXML,
	["json"] = ExportJSON,
	["php"] = ExportPHP
}

func = functionList[string.lower( exportType )]

if dataFile and FileExists( dataFile ) and exportType and func then
	DoFile( dataFile )
	strOut = func()
	print( strOut )
else
	io.stderr:write( "Something is wrong.  Lets review:\n")
	io.stderr:write( "Data file provided: "..( dataFile and " True" or "False" ).."\n" )
	io.stderr:write( "Data file exists  : "..( FileExists( dataFile ) and " True" or "False" ).."\n" )
	io.stderr:write( "ExportType given  : "..( exportType and " True" or "False" ).."\n" )
	io.stderr:write( "ExportType valid  : "..( func and " True" or "False" ).."\n" )
end


