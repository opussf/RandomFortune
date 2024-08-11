RF_SLUG, RF = ...
RF_MSG_VERSION = GetAddOnMetadata( RF_SLUG, "Version" )
RF_MSG_ADDONNAME = GetAddOnMetadata( RF_SLUG, "Title" )
RF_MSG_AUTHOR = GetAddOnMetadata( RF_SLUG, "Author" )

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

-- seed data
RF_fortunes = {
	[1] = {
		["fortune"] = "A smile is your passport into the hearts of others.",
		["lastPost"] = 0,
	},
}

-- onload event handler
function RF.OnLoad()
	--register slash commands
	SLASH_RF1 = "/rf"
	SlashCmdList["RF"] = function(msg) RF.Command(msg); end

	RFFrame:RegisterEvent("ADDON_LOADED")
end
function RF.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..RF_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function RF.IsGuildPostable()
	-- return true if posting to this guild chat is allowed
	if( IsInGuild() ) then
		local guildTestStr = ( GetRealmName() or "none" ).."-"..( GetGuildInfo( "player" ) or "none" )
		--print( guildTestStr )
		if RF_options.guildAllowList and RF_options.guildAllowList[guildTestStr] then
			return true, guildTestStr
		end
		return false, guildTestStr
	end
end
function RF.GuildPrint( msg )
	if RF.IsGuildPostable() then
		SendChatMessage( msg, "GUILD" )
	end
end
function RF.SayPartyRaid( msg )
	local chat = "SAY";
	if RF_options.party then
		if IsInGroup() then
			chat = "PARTY";
		end
		if IsInRaid() then
			chat = "RAID";
		end
	end
	--if RF_options.
	SendChatMessage( msg, chat )
end
function RF.PrintStatus( index )
	index = index and tonumber(index) or nil
	if (index) then -- index given, only show staus for specific fortune
		if (index>0 and index<=#RF_fortunes) then -- fortune index in valid range
			RF.Print(RF_fortunes[index].fortune)
			if RF_fortunes[index].lastPost > 0 then  -- it has been posted
				RF.Print("Last posted: "..date("%x %X", RF_fortunes[index].lastPost))
			else
				RF.Print("Has not been posted yet.")
			end
		else
			RF.Print("Fortune index '"..index.."' is invalid.")
			if #RF_fortunes > 0 then
				RF.Print("Valid range is 1 to "..#RF_fortunes)
			else
				RF.Print("There are no known fortunes.")
			end
		end
	else
		RF.Print(RF_MSG_ADDONNAME.." status");
		RF.Print(#RF_fortunes .." fortune"..(#RF_fortunes == 1 and " is " or "s are ").."known.");
		if RF_options.enabled then
			RF.Print("Enabled, fortunes every "..SecondsToTime(RF_options.delay));
			RF.Print("Next fortune at "..date("%x %X", RF_options.lastPost+RF_options.delay))
		else
			RF.Print(RF_MSG_ADDONNAME.." is disabled.");
		end
		if RF_options.lotto then
			RF.Print("Lotto numbers are appended");
		else
			RF.Print("No Lotto numbers");
		end
		if RF_options.battleNet then
			RF.Print("Fortunes to BattleNet status");
		else
			RF.Print("No BattleNet status updates");
		end
		if RF_options.say then
			RF.Print("Say fortunes");
		else
			RF.Print("Do not say fortunes");
		end
		if RF_options.party and RF_options.say then
			RF.Print("Prefer to say in party");
		end
		if RF.IsGuildPostable() then
			RF.Print( "Print to this guild." )
		else
			RF.Print( "No not post to this guild." )
		end
	end
end
function RF.PrintHelp()
	RF.Print(RF_MSG_ADDONNAME.." by "..RF_MSG_AUTHOR);
	for cmd, info in pairs(RF.CommandList) do
		RF.Print(string.format("%s %s %s -> %s",
			SLASH_RF1, cmd, info.help[1], info.help[2]));
	end
end

function RF.Command(msg)
	local cmd, param = RF.ParseCmd(msg)
	cmd = string.lower(cmd)
	local cmdFunc = RF.CommandList[cmd]
	if cmdFunc and cmdFunc.func then
		cmdFunc.func(param)
		return 1
	else
		Settings.OpenToCategory( RFOptionsFrame.category:GetID() )
		--RF.Print("Use '/rf help' for a list of commands.");
	end
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
function RF.ADDON_LOADED()
	RFFrame:UnregisterEvent("ADDON_LOADED")
	RF.UpdateOptions()
	RF.InitChat()
	--RF.Print("Random Fortune every "..SecondsToTime(RF_options.delay)..". Next at "..
	--		date("%x %X",RF_options.lastPost+RF_options.delay));
	RF.oldestPost = time() - (RF_options.delay * #RF_fortunes);
	--RF.Print("I should not post any posted since: "..date("%x %X",RF.oldestPost));
	local count = 0;
	for _,fortune in pairs(RF_fortunes) do
		if fortune.lastPost <= RF.oldestPost then
			count = count + 1;
		end
	end
	--RF.Print("There are "..count.." / "..#RF_fortunes.." that can be posted.")
	RF.Print(count.." / "..#RF_fortunes.." postable fortunes. Posting every "..SecondsToTime(RF_options.delay)..". ")
end
function RF.OnUpdate(arg1)
	if (RF_options.enabled and RF.ShouldPostNow()) then
		RF.PostFortune();
	end
end
function RF.ShouldPostNow()
	if (time() >= RF_options.lastPost + RF_options.delay) then
		return true;
	end
end
function RF.GetFortune( indexIn )
	indexIn = tonumber( indexIn )
	tableSize = #RF_fortunes
	local fortuneIdx = 1
	local fortuneStr = nil
	if tableSize > 0 then
		RF.oldestPost = time() - (RF_options.delay * tableSize)
		if indexIn and indexIn > 0 and indexIn <= tableSize then
			fortuneIdx = indexIn
		else
			local tryLimit = 6
			repeat  -- try to randomly find a fortune that has not been posted recently up to 6 times
				fortuneIdx = random(tableSize)
				tryLimit = tryLimit - 1
			until (RF_fortunes[fortuneIdx].lastPost <= RF.oldestPost or tryLimit == 0)
		end
		RF_options.lastPost = time()
		RF_fortunes[fortuneIdx].lastPost = RF_options.lastPost
		fortuneStr = RF_fortunes[fortuneIdx].fortune
	end
	return fortuneStr, fortuneIdx
end
function RF.PostFortune( indexIn )
	local fortuneStr, fortuneIdx = RF.GetFortune( indexIn )
	if fortuneStr then
		local lottoNumbers = RF.MakeLuckyNumber()
		if RF_options.lotto then
			RF.GuildPrint(string.format("%s %s", RF_fortunes[fortuneIdx].fortune, lottoNumbers))
		else
			RF.GuildPrint(RF_fortunes[fortuneIdx].fortune)
		end
		if (RF_options.battleNet and string.len(RF_fortunes[fortuneIdx].fortune) < 127) then
			BNSetCustomMessage(RF_fortunes[fortuneIdx].fortune)
		end
		if RF_options.say then
			if RF_options.lotto then
				RF.SayPartyRaid(string.format("%s %s", RF_fortunes[fortuneIdx].fortune, lottoNumbers))
			else
				RF.SayPartyRaid(RF_fortunes[fortuneIdx].fortune)
			end
		end
	end
end
function RF.AddFortune( fortune )
	if (#fortune > 0) then
		table.insert( RF_fortunes, {["fortune"] = fortune, ["lastPost"]=0} );
		RF.Print("Added: "..fortune);
	end
end
function RF.MakeLuckyNumber()
	-- Returns a string of 6 'lucky' numbers'

	local luckyNumbers = {};
	local uniqueNumbers = {};
	local i = 6;  -- choose 6 numbers
	while i > 0 do
		local r = random(49);
		if not uniqueNumbers[r] then
			table.insert( luckyNumbers, r );
			uniqueNumbers[r] = true;
			i = i - 1;
		end
	end
	return "("..table.concat( luckyNumbers, "-" )..")";
end
function RF.Find( search )
	-- Looks for fortunes that contain 'search'
	-- Returns numberOfFortunesFound
	search = search and string.upper(search) or ""
	-- create format string with correct size to list all fortunes if all are returned.  %% is resolved to %
	local outFormat = string.format("[%%%ii] %%s", max(math.ceil(math.log10(#RF_fortunes)), 1))

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

	local outFormat = string.format( "%%s [%%%ii] %%s", max( math.ceil( math.log10( #RF_fortunes ) ), 1 ) )
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
			print( string.format( outFormat, date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	elseif listType == "last" then
		for i = #timeStamps, #timeStamps - num + 1, -1 do
			print( string.format( outFormat, date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	elseif listType == "unposted" then
		for i = 1, numNotPosted do
			print( string.format( outFormat, date( "%x %X", timeStamps[i][1] ), timeStamps[i][2], RF_fortunes[timeStamps[i][2]].fortune ) )
		end
	end
end

-- CommandList needs to be defined at the end since there are references to functions that need to have been defined.
RF.CommandList = {
	["help"] = {
		["func"] = RF.PrintHelp,
		["help"] = {"","Print this help."},
	},
	["add"] = {
		["func"] = function(param)
				RF.AddFortune(param);
			end,
		["help"] = {"fortune","Adds fortune to the list of fortunes."},
	},
	["disable"] = {
		["func"] = function()
				RF_options.enabled = nil;
				RF.Print("Disabled");
			end,
		["help"] = {"", "Disable output"},
	},
	["enable"] = {
		["func"] = function()
				RF_options.enabled = true;
				RF.PrintStatus();
			end,
		["help"] = {"", "Enable periodic publishing"},
	},
	["delay"] = {
		["func"] = function(param)
				param = tonumber(param)
				--print( "param: "..(param or "nil").." ("..#param..") "..type(param) )
				if param and param>0 then
					RF_options.delay = param * 60;
					RF.Print("Delay set to "..SecondsToTime(RF_options.delay));
				end
			end,
		["help"] = {"#", "Set the delay to # minutes"},
	},
	["status"] = {
		["func"] = RF.PrintStatus,
		["help"] = {"<index>", "Show general status. Or info on <index> fortune."},
	},
	["now"] = {
		["func"] = RF.PostFortune,
		["help"] = {"[number]", "Print fortune now. [number] optionally posts "},
	},
	["lotto"] = {
		["func"] = function()
				RF_options.lotto = not RF_options.lotto;
				RF.PrintStatus();
			end,
		["help"] = {"", "Toggle showing lotto numbers"},
	},
	["bn"] = {
		["func"] = function()
				RF_options.battleNet = not RF_options.battleNet;
				RF.PrintStatus();
			end,
		["help"] = {"", "Toggle setting BattleNet status"},
	},
	["say"] = {
		["func"] = function()
				RF_options.say = not RF_options.say;
				RF.PrintStatus();
			end,
		["help"] = {"", "Toggle posting to say channel"},
	},
	["party"] = {
		["func"] = function()
				RF_options.party = not RF_options.party;
				RF.PrintStatus();
			end,
		["help"] = {"", "Toggle posting to party if in party"},
	},
	["find"] = {
		["func"] = RF.Find,
		["help"] = {"search", "Find a known fortune containing <search>"},
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

