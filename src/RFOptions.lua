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
	RF.OptionsPanel_Refresh()
end

function RF.OptionsPanel_Refresh()
	--RF.Print( "OptionsPanel_Refresh()" )
	RFOptionsFrame_EnableBox:SetChecked( RF_options.enabled )
	RFOptionsFrame_DelayEditBox:SetValue( math.floor( RF_options.delay/60 ) )
	RFOptionsFrame_NextPostAt:SetText( date( "%x %X", RF_options.lastPost+RF_options.delay ) )

	RFOptionsFrame_LottoEnableBox:SetChecked( RF_options.lotto )

	-- GuildEnableBox
	local guildEnabled, guildTestStr = RF.IsGuildPostable()
	RFOptionsFrame_GuildEnableBoxText:SetText( "Post to this guild ("..( guildTestStr or "N/A" )..")" )
	RFOptionsFrame_GuildEnableBox:SetChecked( guildEnabled )

	RFOptionsFrame_BNEnableBox:SetChecked( RF_options.battleNet )
	RFOptionsFrame_SayEnableBox:SetChecked( RF_options.say )
end
--------
function RF.OptionsPanel_KeepOriginalValue( option )
	if RF.oldValues then
		RF.oldValues[option] = RF.oldValues[option] or RF_options[option];
	else
		RF.oldValues={[option]=RF_options[option]};
	end
end
function RF.OptionsPanel_CheckButton_OnShow( self, option, text )
	--RF.Print( text..": OnShow" )
	getglobal( self:GetName().."Text"):SetText( text )
end
function RF.OptionsPanel_CheckButton_OnClick( self, option )
	RF.OptionsPanel_KeepOriginalValue( option )
	RF_options[option] = self:GetChecked()
end
function RF.OptionsPanel_Guild_OnClick( self )
	if not RF_options.guildAllowList then
		RF_options.guildAllowList = {}
	end

	if( IsInGuild() ) then
		local guildEnabled, guildTestStr = RF.IsGuildPostable()
		if RF_options.guildAllowList[guildTestStr] then
			RF_options.guildAllowList[guildTestStr] = nil
		else
			RF_options.guildAllowList[guildTestStr] = true
		end
	end
end
function RF.OptionsPanel_DelayEditBox_TextChanged( self )
	RF.OptionsPanel_KeepOriginalValue( "delay" )
	RF_options["delay"] = (self:GetNumber() > 1) and self:GetNumber() * 60 or 60
	RFOptionsFrame_NextPostAt:SetText( date( "%x %X", RF_options.lastPost+RF_options.delay ) )
end


