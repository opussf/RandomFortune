#!/usr/bin/env lua

--dofile("/Applications/World of Warcraft/WTF/Account/OPUSSF/SavedVariables/RF.lua");
dofile("RF.saved");

strOut = "<?xml version='1.0' encoding='utf-8' ?>\n";
strOut = strOut .. "<fortunes>\n";

for _,fortuneStruct in pairs(RF_fortunes) do
	strOut = strOut .. string.format('\t<fortune lastPost="%i"><![CDATA[%s]]></fortune>\n',
			fortuneStruct.fortune);
end

strOut = strOut .. "</fortunes>";

print(strOut);
