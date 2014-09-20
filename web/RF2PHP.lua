#!/usr/bin/env lua

dofile("RF.lua");

strOut = "<?php\n$RFTable = array(\n";
for _, RFs in pairs(RF_fortunes) do
		strOut = strOut .. string.format("\tarray('fortune'=>\"%s\", 'lastPost'=>\"%s\"),\n",
				RFs.fortune, RFs.lastPost);
end
strOut = strOut .. ");\n?>";
print(strOut);
