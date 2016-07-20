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

	strOut = "<?xml version='1.0' encoding='utf-8' ?>\n";
	strOut = strOut .. "<fortunes>\n";

	for _,fortuneStruct in pairs(RF_fortunes) do
		strOut = strOut .. string.format('\t<fortune lastPost="%i"><![CDATA[%s]]></fortune>\n',
				fortuneStruct.lastPost, fortuneStruct.fortune);
	end

	strOut = strOut .. "</fortunes>";

	print(strOut);
end