#!/usr/bin/env lua

dataFile = arg[1]

function FileExists( name )
   local f = io.open( name, "r" )
   if f then io.close( f ) return true else return false end
end
function DoFile( filename )
	local f = assert( loadfile( filename ) )
	return f()
end

if FileExists( dataFile ) then
	DoFile( dataFile )

	strOut = '{"fortunes": [\n'

	fortunes = {}

	for _,fortuneStruct in pairs(RF_fortunes) do
		fortune = string.gsub( fortuneStruct.fortune, '\\', '\\\\')
		fortune = string.gsub( fortuneStruct.fortune, '\"', '\\\"')
		table.insert( fortunes, string.format('\t{ "lastPost": %.0f, "fortune": "%s" }', fortuneStruct.lastPost * 1000, fortune ) )
	end

	strOut = strOut .. table.concat( fortunes, ",\n" )

	strOut = strOut .. "]}"

	print(strOut);
end
