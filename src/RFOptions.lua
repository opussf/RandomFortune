-- options
RF.defaultOptions = {
	["lastPost"] = 0,
	["enabled"] = true,
	["delay"] = 1800,
	["lotto"] = true,
}
RF_options = {}
function RF.UpdateOptions()
	--RF.Print( "UpdateOptions()" )
	for k,v in pairs( RF.defaultOptions ) do
		--[[
		RF.Print( "k: "..k.." options: "..
				( type(RF_options[k])=="boolean" and (
					RF_options[k] and "true" or "false") or (RF_options[k] or "nil")).." default: "..
				( type(v)=="boolean" and (v and "true" or "false") or (v or "nil") ) )
		]]
		RF_options[k] = ( RF_options[k] == nil and v or RF_options[k] )
	end
	RF.OptionsPanel_Refresh()
end
function RF.OptionsPanel_Reset()
	-- Called from Addon_loaded
	-- RF.Print( "OptionsPanel_Reset()" )
	RF.OptionsPanel_Refresh()
end
function RF.OptionsPanel_OnLoad( frame )
	-- RF.Print( "RF.OptionsPanel_OnLoad()" )
	frame.name = "Random Fortune"
	RFOptionsFrame_Title:SetText( RF_MSG_ADDONNAME.." "..RF_MSG_VERSION )

	frame.okay = RF.OptionsPanel_Okay
	frame.cancel = RF.OptionsPanel_Cancel
	frame.default = RF.OptionsPanel_Default
	frame.refresh = RF.OptionsPanel_Refresh

	InterfaceOptions_AddCategory( frame )
	InterfaceAddOnsList_Update()
	RF.UpdateOptions()
end
function RF.OptionsPanel_Okay()
	-- Data was recorded, clear the temp
	RF.oldValues = nil
end
function RF.OptionsPanel_Cancel()
	-- reset to temp and update the UI
	-- RF.Print( "OptionsPanel_Cancel" )
	if RF.oldValues then
		for k,v in pairs( RF.oldValues ) do
			RF_options[k] = v
		end
	end
	RF.oldValues = nil
end
function RF.OptionsPanel_Default()
	-- set options to defaults
	for k,v in pairs( RF.defaultOptions ) do
		RF_options[k] = v
	end
end

function RF.OptionsPanel_Refresh()
	--RF.Print( "OptionsPanel_Refresh()" )
	RFOptionsFrame_EnableBox:SetChecked( RF_options.enabled )
	--RFOptionsFrame_DelaySlider:SetValue( tonumber(RF_options.delay)/60 )
	RFOptionsFrame_LottoEnableBox:SetChecked( RF_options.lotto )

	-- GuildEnableBox
	local guildEnabled, guildTestStr = RF.IsGuildPostable()
	RFOptionsFrame_GuildEnableBoxText:SetText( "Post to this guild ("..( guildTestStr or "N/A" )..")" )
	RFOptionsFrame_GuildEnableBox:SetChecked( guildEnabled )

	RFOptionsFrame_BNEnableBox:SetChecked( RF_options.battleNet )
	RFOptionsFrame_SayEnableBox:SetChecked( RF_options.say )
end
--------
function RF.OptionsPanel_CheckButton_OnShow( self, option, text )
	--RF.Print( text..": OnShow" )
	getglobal( self:GetName().."Text"):SetText( text )
end
function RF.OptionsPanel_CheckButton_PostClick( self, option )
	if RF.oldValues then
		RF.oldValues[option] = RF.oldValues[option] or RF_options[option]
	else
		RF.oldValues = { [option] = RF_options[option] }
	end
	RF_options[option] = self:GetChecked()
end
function RF.OptionsPanel_Guild_PostClick( self )
	if not RF_options.guildBlackList then
		RF_options.guildBlackList = {}
	end

	if( IsInGuild() ) then
		local guildEnabled, guildTestStr = RF.IsGuildPostable()
		if RF_options.guildBlackList[guildTestStr] then
			RF_options.guildBlackList[guildTestStr] = nil
		else
			RF_options.guildBlackList[guildTestStr] = true
		end
	end
end
function RF.OptionsPanel_Slider_OnValueChanged( self, option )
	if RF.oldValues then
		RF.oldValues[option] = RF.oldValues[option] or RF_options[option]
	else
		RF.oldValues = { [option] = RF_options[option] }
	end
	local min, max = self:GetMinMaxValues()
	local v = math.floor( self:GetValue() * 60 )
	RF.Print( min.."<"..math.floor( self:GetValue() ).."<"..max )
	RF_options[option] = v
end

RF.timeMultipliers = { [" "] = 1, ["s"] = 1, ["m"] = 60, ["h"] = 3600, ["d"] = 86400, ["w"] = 604800 }
RF.timeMultiplierOrder = { "w", "d", "h", "m", "s" }
function RF.TextToSeconds( textIn )
	-- convert a string to seconds
	-- the string is in the format of <number><unit>.....
	-- returns seconds
	local seconds, current = 0, 0
	for i = 1, string.len( textIn ) do
		local char = string.lower( strsub( textIn, i, i ) )
		local multiplier = RF.timeMultipliers[char]
		if multiplier then
			current = current * multiplier
			seconds = seconds + current
			current = 0
		elseif char == tostring( tonumber( char ) ) then
			current = current * 10
			current = current + tonumber( char )
		end
		--print( char..": "..seconds.." + ("..current.." * "..(multiplier or "")..")" )
	end
	seconds = seconds + current
	return seconds
end
function RF.SecondsToText( secIn )
	-- convert seconds to a string
	secIn = tonumber( secIn )
	outStr = ""
	for _,m in pairs( RF.timeMultiplierOrder ) do
		local multiplier = RF.timeMultipliers[m]
		if multiplier <= secIn then
			--print( multiplier.." <=? "..secIn )
			v = math.floor( secIn / multiplier )
			secIn = secIn - ( v * multiplier )
			outStr = string.format( "%s%s%i%s",
					outStr, (string.len(outStr) > 1 and " " or ""), v, m )
			--print( "-->"..outStr.."<--" )
		end
	end
	return outStr
end




