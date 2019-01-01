-- options

RF.defaultOptions = {
	["lastPost"] = 0,
	["enabled"] = true,
	["delay"] = 1800,
	["lotto"] = true,
	["guild"] = true,
}
RF_options = {}
function RF.UpdateOptions()
	for k,v in pairs( RF.defaultOptions ) do
		RF_options[k] = RF_options[k] or v
	end
end
function RF.OptionsPanel_OnLoad( frame )
	frame.name = "Random Fortune"
	RFOptionsFrame_Title:SetText( "Random Fortune "..RF_MSG_VERSION )

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
	if RF.oldValues then
		for k,v in pairs( RF.oldValues ) do
			RF_options[k] = val
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
function RF.OptionsPanel_Reset()
	-- Called from Addon_loaded
	RF.Print( "Reset" )
	RF.OptionsPanel_Refresh()
end
function RF.OptionsPanel_Refresh()
	RF.Print( "OptionsPanel_Refresh" )
	RFOptionsFrame_EnableBox:SetChecked( RF_options.enabled )
	RFOptionsFrame_DelaySlider:SetValue( RF_options.delay/60 )
	RFOptionsFrame_LottoEnableBox:SetChecked( RF_options.lotto )
	RFOptionsFrame_GuildEnableBox:SetChecked( RF_options.guild )
	RFOptionsFrame_BNEnableBox:SetChecked( RF_options.battleNet )
	RFOptionsFrame_SayEnableBox:SetChecked( RF_options.say )
end
--------
function RF.OptionsPanel_CheckButton_OnShow( self, option, text )
	RF.Print( text..": OnShow" )
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
RF.sliderControl = {
	["minute(s)"] = { ["min"]=1, ["max"]=60, ["mul"]=60 },
	["hour(s)"]   = { ["min"]=1, ["max"]=24, ["mul"]=3600 },
	["days(s)"]   = { ["min"]=1, ["max"]=7,  ["mul"]=86400 },
	["week(s)"]   = { ["min"]=1, ["max"]=52, ["mul"]=86400*7 }
}


1 - 60     (60 -  3600)     minutes
1 - 1440   (60 - 86400)	   hours
1 -



1 - 120 minutes


function RF.OptionsPanel_Slider_OnValueChanged( self, option )
	if RF.oldValues then
		RF.oldValues[option] = RF.oldValues[option] or RF_options[option]
	else
		RF.oldValues = { [option] = RF_options[option] }
	end
	local min, max = self:GetMinMaxValues()
	local v = self:GetValue()
	RF.Print( min.."<"..math.floor( self:GetValue() ).."<"..max )

	--[[
						if not Rested.oldVal then Rested.oldVal = Rested_options.maxCutOff; end
						v = (self:GetValue()==10 and "Off") or self:GetValue();
						getglobal(self:GetName().."Text"):SetText("DelaysTime ("..v..")");
						Rested_options.maxCutOff = self:GetValue();
	]]
end

--[[

function MeToo.OptionsPanel_Refresh()
	-- set the drop down values here...  Maybe more?
	--MeToo.Print( "OptionsPanel_Refresh" )
	MeTooOptionsFrame_MountSuccessDoEmote:SetChecked( MeToo_options["mountSuccess_doEmote"] )
	MeTooOptionsFrame_MountSuccessEmoteEditBox:SetText( MeToo_options["mountSuccess_emote"] )
	MeTooOptionsFrame_MountSuccessEmoteEditBox:SetCursorPosition(0)
	MeTooOptionsFrame_MountSuccessEmoteToTarget:SetChecked( MeToo_options["mountSuccess_useTarget"] )

	MeTooOptionsFrame_MountFailureDoEmote:SetChecked( MeToo_options["mountFailure_doEmote"] )
	MeTooOptionsFrame_MountFailureEmoteEditBox:SetText( MeToo_options["mountFailure_emote"] )
	MeTooOptionsFrame_MountFailureEmoteEditBox:SetCursorPosition(0)
	MeTooOptionsFrame_MountFailureEmoteToTarget:SetChecked( MeToo_options["mountFailure_useTarget"] )

	MeTooOptionsFrame_CompanionSuccessDoEmote:SetChecked( MeToo_options["companionSuccess_doEmote"] )
	MeTooOptionsFrame_CompanionSuccessEmoteEditBox:SetText( MeToo_options["companionSuccess_emote"] )
	MeTooOptionsFrame_CompanionSuccessEmoteEditBox:SetCursorPosition(0)
	MeTooOptionsFrame_CompanionSuccessEmoteToTarget:SetChecked( MeToo_options["companionSuccess_useTarget"] )

	MeTooOptionsFrame_CompanionFailureDoEmote:SetChecked( MeToo_options["companionFailure_doEmote"] )
	MeTooOptionsFrame_CompanionFailureEmoteEditBox:SetText( MeToo_options["companionFailure_emote"] )
	MeTooOptionsFrame_CompanionFailureEmoteEditBox:SetCursorPosition(0)
	MeTooOptionsFrame_CompanionFailureEmoteToTarget:SetChecked( MeToo_options["companionFailure_useTarget"] )
end



]]