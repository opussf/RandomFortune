RF_MSG_VERSION = GetAddOnMetadata("RF","Version");
RF_MSG_ADDONNAME = GetAddOnMetadata("RF","Title");
RF_MSG_AUTHOR = GetAddOnMetadata("RF", "Author");

-- Colours
COLOR_RED = "|cffff0000";
COLOR_GREEN = "|cff00ff00";
COLOR_BLUE = "|cff0000ff";
COLOR_PURPLE = "|cff700090";
COLOR_YELLOW = "|cffffff00";
COLOR_ORANGE = "|cffff6d00";
COLOR_GREY = "|cff808080";
COLOR_GOLD = "|cffcfb52b";
COLOR_NEON_BLUE = "|cff4d4dff";
COLOR_END = "|r";

-- options
RF_options = {
	["lastPost"] = 0;
	["enabled"] = true;
	["delay"] = 1200;
	["lotto"] = true;
	["guild"] = true;
}

-- seed data
RF_fortunes = {
	[1] = {
		["fortune"] = "A smile is your passport into the hearts of others.",
		["lastPost"] = 0,
	},
}

RF = {};

-- onload event handler
function RF.OnLoad()
	--register slash commands
	SLASH_RF1 = "/rf";
	SlashCmdList["RF"] = function(msg) RF.Command(msg); end

	RFFrame:RegisterEvent("ADDON_LOADED");
	RFFrame:RegisterEvent("VARIABLES_LOADED");
end
function RF.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..RF_MSG_ADDONNAME.."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end
function RF.GuildPrint( msg )
	if (IsInGuild() and RF_options.guild) then
		SendChatMessage( msg, "GUILD" );
--	else
--		RF.Print( COLOR_RED.."RF.GuildPrint: "..COLOR_END..msg, false );
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
	SendChatMessage( msg, chat );
end
function RF.PrintStatus()
	RF.Print(RF_MSG_ADDONNAME.." status");
	RF.Print("There are ".. #RF_fortunes .." fortunes.");
	if RF_options.enabled then
		RF.Print("Enabled, fortunes every "..SecondsToTime(RF_options.delay));
		RF.Print("Next fortune at "..date("%x %X", RF_options.lastPost+RF_options.delay));
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
end
function RF.PrintHelp()
	RF.Print(RF_MSG_ADDONNAME.." by "..RF_MSG_AUTHOR);
	for cmd, info in pairs(RF.CommandList) do
		RF.Print(string.format("%s %s %s -> %s",
			SLASH_RF1, cmd, info.help[1], info.help[2]));
	end
end

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
				print( "param: "..(param or "nil").." ("..#param..") "..type(param) )
				if (param) and (param ~= "") and (param*1 > 0) then
					RF_options.delay = param*60;
					RF.Print("Delay set to "..SecondsToTime(RF_options.delay));
				end
			end,
		["help"] = {"#", "Set the depaly to # minutes"},
	},
	["status"] = {
		["func"] = RF.PrintStatus,
		["help"] = {"", "Show status"},
	},
	["now"] = {
		["func"] = function()
				RF.PostFortune();
			end,
		["help"] = {"", "Print fortune now"},
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
}

function RF.Command(msg)
	local cmd, param = RF.ParseCmd(msg);
	cmd = string.lower(cmd);
	local cmdFunc = RF.CommandList[cmd];
	if cmdFunc then
		cmdFunc.func(param);
	else
		InterfaceOptionsFrame_OpenToCategory("Random Fortune");
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
	RFFrame:UnregisterEvent("ADDON_LOADED");
	--RF_options.lastPost = time()+30 - RF_options.delay;
	RF.Print("Random Fortune every "..SecondsToTime(RF_options.delay)..". Next at "..
			date("%x %X",RF_options.lastPost+RF_options.delay));
	RF.oldestPost = time() - (RF_options.delay * #RF_fortunes);
	RF.Print("I should not post any posted since: "..date("%x %X",RF.oldestPost));
	local count = 0;
	for _,fortune in pairs(RF_fortunes) do
		if fortune.lastPost <= RF.oldestPost then
			count = count + 1;
		end
	end
	RF.Print("There are "..count.." / "..#RF_fortunes.." that can be posted.")
end
function RF.VARIABLES_LOADED()
	RFFrame:UnregisterEvent("VARIABLES_LOADED");
	RF.Print("Variables Loaded");
	RF.OptionsSetOptions();
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
function RF.PostFortune()
	tableSize = #RF_fortunes;
	if tableSize > 0 then
		RF.oldestPost = time() - (RF_options.delay * tableSize);
		tryLimit = 6;
		repeat
			fortuneIdx = random(tableSize);
			--RF.Print(date("%X %x",RF_fortunes[fortuneIdx].lastPost).." <=? "..date("%X %x",RF.oldestPost));
			tryLimit = tryLimit - 1;
		until (RF_fortunes[fortuneIdx].lastPost <= RF.oldestPost or tryLimit == 0)
		--RF.Print(tableSize..":"..fortuneIdx);
		local lottoNumbers = RF.MakeLuckyNumber();
		--RF.Print("Length of message: "..string.len(RF_fortunes[fortuneIdx].fortune).."+"..string.len(lottoNumbers));
		if RF_options.lotto then
			RF.GuildPrint(string.format("%s %s", RF_fortunes[fortuneIdx].fortune, lottoNumbers));
		else
			RF.GuildPrint(RF_fortunes[fortuneIdx].fortune);
		end
		if (RF_options.battleNet and string.len(RF_fortunes[fortuneIdx].fortune) < 127) then
			BNSetCustomMessage(RF_fortunes[fortuneIdx].fortune);
		end
		if RF_options.say then
			if RF_options.lotto then
				RF.SayPartyRaid(string.format("%s %s", RF_fortunes[fortuneIdx].fortune, lottoNumbers));
			else
				RF.SayPartyRaid(RF_fortunes[fortuneIdx].fortune);
			end
		end
		RF_options.lastPost = time();
		RF_fortunes[fortuneIdx].lastPost = RF_options.lastPost;
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
function RF.OptionsOnLoad(frame)
	frame.name = "Random Fortune";
	RFOptionsFrame_Title:SetText("Random Fortune "..RF_MSG_VERSION);
	frame.okay = RF.OptionsOkay;
	frame.cancel = RF.OptionsCancel;

	InterfaceOptions_AddCategory(frame);
end
function RF.OptionsSetOptions()
	RFOptionsFrame_EnableBox:SetChecked(RF_options.enabled);
	RFOptionsFrame_GuildEnableBox:SetChecked(RF_options.guild);
	RFOptionsFrame_BNEnableBox:SetChecked(RF_options.battleNet);
	RFOptionsFrame_LottoEnableBox:SetChecked(RF_options.lotto);
	RFOptionsFrame_SayEnableBox:SetChecked(RF_options.say);
	RFOptionsFrame_PartyEnableBox:SetChecked(RF_options.party);
	RFOptionsFrame_InstanceEnableBox:SetChecked(RF_options.instance);
end
function RF.OptionsOkay()
	RF_options.enabled = RFOptionsFrame_EnableBox:GetChecked();
	RF_options.guild = RFOptionsFrame_GuildEnableBox:GetChecked();
	RF_options.battleNet = RFOptionsFrame_BNEnableBox:GetChecked();
	RF_options.lotto = RFOptionsFrame_LottoEnableBox:GetChecked();
	RF_options.say = RFOptionsFrame_SayEnableBox:GetChecked();
	RF_options.party = RFOptionsFrame_PartyEnableBox:GetChecked();
	RF_options.instance = RFOptionsFrame_IntanceEnableBox:GetChecked();
end
function RF.OptionsCancel()
	RF.OptionsSetOptions();
end


--[[
        Rested_options.maxCutOff = RestedOptionsFrame_NagTimeSlider:GetValue();
        Rested.oldVal = nil;
end
function Rested.OptionsPanel_Cancel()
        Rested_options.maxCutOff = Rested.oldVal or Rested_options.maxCutOff;
        Rested.OptionsPanel_Reset();
        Rested.oldVal = nil;
end
function Rested.OptionsPanel_Default()
        Rested_options.maxCutOff = 7;
        RestedOptionsFrame_NagTimeSlider:SetValue(Rested_options.maxCutOff);
]]--

