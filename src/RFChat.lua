-- RFChat.lua

function RF.InitChat()
	RF.OriginalSendChatMessage = SendChatMessage
	SendChatMessage = RF.SendChatMessage
	RF.OriginalBNSendWhisper = BNSendWhisper
	BNSendWhisper = RF.BNSendWhisper
end
function RF.ReplaceMessage( msgIn )
	-- search for and replace {RF} or {RF#nnnn} with a Random Fortune
	--print( "msgIn: "..msgIn )
	msgNew = nil
	local tokenStart, tokenEnd, index = strfind( msgIn, "{[rR][fF][#]?(%d*)}" )
	if tokenStart then
		local fortuneStr, fortuneIdx = RF.GetFortune( index )
		--print( "tokenStart: "..tokenStart )
		--print( "tokenEnd: "..tokenEnd )
		--print( "index: "..index )
		msgNew = string.sub( msgIn, 1, tokenStart-1 )..fortuneStr..string.sub( msgIn, tokenEnd+1 )
	end
	return( ( msgNew or msgIn ) )
end
function RF.SendChatMessage( msgIn, system, language, channel )
	RF.OriginalSendChatMessage( RF.ReplaceMessage( msgIn ), system, language, channel )
end
function RF.BNSendWhisper( id, msgIn )
	RF.OriginalBNSendWhisper( id. RF.ReplaceMessage( msgIn ) )
end

--[[

function calc.ReplaceMessage( msgIn )
	msgNew = nil
	local hasEquals = strfind( msgIn, "==" )
	if( hasEquals ) then
		msg = string.lower( msgIn )
		local stackCount = #calc.stack
		calc.ProcessLine( msg )

		-- add an expected extra value on the stack - means a stand alone calc
		stackCount = stackCount + 1
		-- use the stack size if it is smaller than the expected stack size
		stackCount = #calc.stack<stackCount and #calc.stack or stackCount
		-- set to nil if the stackCount is 0
		stackCount = stackCount>0 and stackCount or nil

		-- table.concat seems to have a 'bug?' where giving a starting index larger than the size of the array, or if the array is empty
		-- causes an error:  "invalid value (nil) at index 0 in table for 'concat'"
		local result = table.concat( calc.stack, " ", stackCount )
		msgNew = string.gsub( msgIn, "==", "= "..result )
	end
	return( ( msgNew or msgIn ) )
end
]]