-- RFChat.lua

function RF.InitChat()
	RF.OriginalSendChatMessage = SendChatMessage
	SendChatMessage = RF.SendChatMessage
	RF.OriginalBNSendWhisper = BNSendWhisper
	BNSendWhisper = RF.BNSendWhisper
end
function RF.ReplaceMessage( msgIn )
	-- search for and replace {RF} or {RF#nnnn} with a Random Fortune
	print( "msgIn: "..msgIn )
	msgNew = nil
	local tokenStart, tokenEnd, fortuneIdx, useLotto = strfind( msgIn, "{[rR][fF][#]?(%d*)[#]?([lL]?)}" )
	if tokenStart then
		local fortuneStr, fortuneIdx = RF.GetFortune( fortuneIdx )

		print( "useLotto: "..( useLotto and "yes" or "no" ).."->"..useLotto )
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
	RF.OriginalBNSendWhisper( id, RF.ReplaceMessage( msgIn ) )
end
