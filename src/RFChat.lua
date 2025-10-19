-- RFChat.lua

-- function RF.InitChat()
-- 	RF.OriginalSendChatMessage = SendChatMessage
-- 	SendChatMessage = RF.SendChatMessage
-- 	RF.OriginalBNSendWhisper = BNSendWhisper
-- 	BNSendWhisper = RF.BNSendWhisper
-- end
function RF.ReplaceMessage( msgIn )
	if msgIn then
		-- search for and replace {RF} or {RF#nnnn} with a Random Fortune
		--print( "msgIn: "..msgIn )
		msgNew = nil
		local tokenStart, tokenEnd, fortuneIdx, useLotto = strfind( msgIn, "{[rR][fF][#]?(%d*)[#]?([lL]?)}" )
		if tokenStart then
			useLotto = string.upper(useLotto) == "L"
			local fortuneStr, fortuneIdx = RF.GetFortune( fortuneIdx )
			local lottoStr = RF.MakeLuckyNumber()
-- 			--print( "useLotto: "..( useLotto and "yes" or "no" ) )
-- 			--print( "tokenStart: "..tokenStart )
-- 			--print( "tokenEnd: "..tokenEnd )
-- 			--print( "index: "..index )
			msgNew = string.sub( msgIn, 1, tokenStart-1 )..
					fortuneStr..(useLotto and " "..RF.MakeLuckyNumber() or "")..
					string.sub( msgIn, tokenEnd+1 )
		end
		return( ( msgNew or msgIn ) )
	end
end
-- function RF.SendChatMessage( msgIn, system, language, channel )
-- 	RF.OriginalSendChatMessage( RF.ReplaceMessage( msgIn ), system, language, channel )
-- end
-- function RF.BNSendWhisper( id, msgIn )
-- 	RF.OriginalBNSendWhisper( id, RF.ReplaceMessage( msgIn ) )
-- end

-- RF.CommandList[""] = {
-- 		["help"] = {"{RF<nnn><L>}","Send to any chat. <nnn> fortune to post. <L> append lotto numbers"},
-- 	}
function RF.ChatParseMessage( msg )
	if msg and string.len( msg ) > 0 then
		msg = RF.ReplaceMessage( msg )
	else
		msg = RF.GetFortune( )
	end
	return msg
end
function RF.SendMessage( channel, msg )
	-- print( "\t>>>>", channel, msg )
	msg = RF.ChatParseMessage( msg )
	SendChatMessage( msg, channel )
end

RF.CommandList["say"] = {
	["func"] = function(msg) RF.SendMessage( "say", msg ) end,
	["help"] = {"[chatMessage]", "Say \"[chatMessage]\" with {} replace.  "},
}
RF.CommandList["party"] = {
	["func"] = function(msg) RF.SendMessage( "party", msg ) end,
	["help"] = {"[chatMessage]", "Say \"[chatMessage]\" with {} replace.  "},
}
RF.CommandList["instance"] = {
	["func"] = function(msg) RF.SendMessage( "instance", msg ) end,
	["help"] = {"[chatMessage]", "Say \"[chatMessage]\" with {} replace.  "},
}
RF.CommandList["raid"] = {
	["func"] = function(msg) RF.SendMessage( "raid", msg ) end,
	["help"] = {"[chatMessage]", "Say \"[chatMessage]\" with {} replace.  "},
}
RF.CommandList["guild"] = {
	["func"] = function(msg) RF.SendMessage( "guild", msg ) end,
	["help"] = {"[chatMessage]", "Say \"[chatMessage]\" with {} replace.  "},
}