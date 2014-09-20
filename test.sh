#!/bin/sh
targetDir="/Applications/World of Warcraft/Interface/AddOns/RF/"
files="RF.lua RF.toc RF.xml"

echo "----------"
echo "Saved data"
echo "----------"
ls -l RF.saved
diff "$targetDir"RF.saved RF.saved
cp -v "/Applications/World of Warcraft/WTF/Account/OPUSSF/SavedVariables/RF.lua" RF.saved
ls -l RF.saved

echo "----------"
echo "Code Files"
echo "----------"
for f in $files 
do
diff "$targetDir"$f "src/$f"
cp -v "src/$f" "$targetDir"
done

