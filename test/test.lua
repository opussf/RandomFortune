#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

RFFrame = CreateFrame()

ParseTOC( "../src/RF.toc" )

OriginalSendChatMessage = SendChatMessage
OriginalBNSendWhisper = BNSendWhisper

function test.before()
	RF.OnLoad()
	RF_fortunes = { { ["fortune"] = "Smile!", ["lastPost"] = 0, } }
	RF_options.enabled = true -- default to on
	RF_options.delay = 30
	RF.VARIABLES_LOADED()
	RF.ADDON_LOADED()
end
function test.after()
	SendChatMessage = OriginalSendChatMessage
	BNSendWhisper = OriginalBNSendWhisper
end
function test.testMakeLuckyNumber()
	-- random is not
	local ln = RF.MakeLuckyNumber()
	assertTrue( ln ~= nil )
end
function test.testZeroFortunes_nowDoesNotCrash()
	RF_fortunes = {}
	RF_options["lastPost"] = 0
	RF.Command( "now" )
	assertEquals( 0, RF_options.lastPost, "should be 0 to show not haivng posted" )
end
function test.testCommandWorks_add_noMessage()
	local beforeCount = #RF_fortunes
	RF.Command( "add" )
	assertEquals( beforeCount, #RF_fortunes, "Should not add an empty message" )
end
function test.testCommandWorks_add_message()
	local beforeCount = #RF_fortunes
	local msg = "Added This."
	RF.Command( "add "..msg )
	assertEquals( msg, RF_fortunes[beforeCount+1].fortune )
end
function test.testCommandWorks_delay_floatDelay()
	RF.Command( "delay .1")
	assertEquals( 6, RF_options.delay, "Set to 6 seconds if allowing" )
end
function test.testCommandWorks_delay_invalidDelay()
	-- should quietly do nothing
	local beforeDelay = RF_options.delay
	RF.Command( "delay hello" )
	assertEquals( beforeDelay, RF_options.delay )
end
--[[
function test.testCommandWorks_delay_noDelay()
	-- should quietly do nothing
	local beforeDelay = RF_options.delay
	RF.Command( "delay" )
	assertEquals( beforeDelay, RF_options.delay )
end
function test.testCommandWorks_delay_zeroDelay()
	-- should quietly do nothing
	local beforeDelay = RF_options.delay
	RF.Command( "delay 0" ) -- zero is an invalid value really
	assertEquals( beforeDelay, RF_options.delay )
end
]]
function test.testCommandWorks_delay_validDelay()
	RF.Command( "delay 1") -- one is the smallest allowed value
	assertEquals( 60, RF_options.delay, "Should be set to 60 seconds" )
end
function test.testCommandWorks_disable_disables()
	RF.Command( "disable" )
	assertIsNil( RF_options.enabled )
end
function test.testCommandWorks_enable()
	RF_options.enabled = nil
	RF.Command( "enable" )
	assertTrue( RF_options.enabled )
end
function test.testCommandWorks_now()
	RF_options["lastPost"] = 0
	RF.Command( "now" )
	assertEquals( time(), RF_options.lastPost, "Should be now to show posting" )
end
function test.testGuild_ignoreSingle()
end
function test.testCommandWorks_find()
	RF.Command( "find" )
end
function test.testFind_noSearch()
	-- This should list them all
	local result = RF.Find()
	assertEquals( #RF_fortunes, result )
end
function test.testFind_find()
	local result = RF.Find( "sm" )
	assertEquals( 1, result )
end
function test.testCommandWorks_find_noFind()
	local result = RF.Find( "life" )
	assertIsNil( result )
end
function test.testFind_findTwo()
	RF.Command("add Coffee is black gold.")
	local result = RF.Find( "i" )
	assertEquals( 2, result )
end
function test.testFind_findMany()
	RF.Command("add A")
	RF.Command("add B")
	RF.Command("add C")
	RF.Command("add D")
	RF.Command("add E")
	RF.Command("add F")
	RF.Command("add G")
	RF.Command("add H")
	RF.Command("add I")
	RF.Command("add J")
	RF.Command("add K")
	RF.Command("add L")
	local result = RF.Find( )
	assertEquals( 13, result )
end
function test.testFind_zeroFortunes()
	RF_fortunes = {}
	local result = RF.Find()
	assertIsNil( result )
end
function test.testDelete_deleteOnlyFortune()
	RF.Command( "rm 1" )
	assertEquals( 0, #RF_fortunes )
end
function test.testDelete_deleteIndexOutOfRange_zeroFortunes()
	RF_fortunes = {}
	RF.Command( "rm 1")
end
function test.testDelete_deleteIndexOutOfRange_zeroIndex()
	RF.Command( "rm 0" )
	assertEquals( 1, #RF_fortunes, "This command should not delete a fortune.")
end
function test.testDelete_noIndexGiven()
	-- this should do nothing
	RF.Command( "rm" )
	assertEquals( 1, #RF_fortunes, "This command should not delete a fortune.")
end
--[[
function test.testStatus_noOptions()
	RF.Command( "status" )
end
]]
function test.testStatus_fortuneIndexGiven()
	RF.Command( "status 1" )
end
function test.testStatus_fortuneIndexGiven_outOfRange_Low()
	RF.Command( "status 0" )
end
function test.testStatus_fortuneIndexGiven_outOfRange_High()
	RF.Command( "status 10")
end
function test.testStatus_fortuneIndexGiven_zeroFortunes()
	RF_fortunes = {}
	RF.Command( "status 3")
end
function test.testList_commandWorks()
	RF.Command( "list" )
end
--[[
function test.testNow_withTextParamter()
	RF_options["lastPost"] = 0
	RF.Command( "now Hello" )
	assertEquals( time(), RF_options.lastPost, "Should be now to show posting" )
end
]]
function test.testNow_withNumberParameter()
	RF_options["lastPost"] = 0
	RF.Command( "now 1" )
	assertEquals( time(), RF_options.lastPost, "Should be now to show posting" )
end
function test.testNow_withNumberParameter_tooSmall()
	RF_options["lastPost"] = 0
	RF.Command( "now 0" )
	assertEquals( time(), RF_options.lastPost, "Should be now to show posting" )
end
function test.testNow_withNumberParameter_tooLarge()
	RF_options["lastPost"] = 0
	RF.Command( "now 5" )
	assertEquals( time(), RF_options.lastPost, "Should be now to show posting" )
end
-- 8.2.0 features
function test.last_Setup()
	RF_fortunes = {
		{ ["fortune"] = "A", ["lastPost"] = 0, },
		{ ["fortune"] = "B", ["lastPost"] = 10, },
		{ ["fortune"] = "C", ["lastPost"] = 35, },
		{ ["fortune"] = "D", ["lastPost"] = 20, },
		{ ["fortune"] = "E", ["lastPost"] = 25, },
		{ ["fortune"] = "F", ["lastPost"] = 30, },
		{ ["fortune"] = "G", ["lastPost"] = 15, },
	}
end
function test.testLast_noParameter( )
	test.last_Setup()
	assertTrue( RF.Command( "last" ) )
end
function test.testLast_noParameter_direct()
	test.last_Setup()
	RF.List( "last" )
end
function test.testLast_5()
	test.last_Setup()
	assertTrue( RF.Command( "last 5" ) )
end
function test.testLast_5_direct()
	test.last_Setup()
	RF.List( "last", 5 )
end
function test.testUnposted()
	test.last_Setup()
	assertTrue( RF.Command( "unposted" ) )
end
function test.testUnposted_direct()
	test.last_Setup()
	RF.List( "unposted" )
end
function test.testFirst_noParameter()
	test.last_Setup()
	assertTrue( RF.Command( "first" ) )
end
function test.testFirst_noParameter_direct()
	test.last_Setup()
	RF.List( "first" )
end
function test.testFirst_5()
	test.last_Setup()
	assertTrue( RF.Command( "first 5" ) )
end
-- Options
function test.testTimeOptionTextToSeconds_1Week()
	assertEquals( 604800, RF.TextToSeconds( "1w" ) )
end
function test.testTimeOptionTextToSeconds_1Day()
	assertEquals( 86400, RF.TextToSeconds( "1d" ) )
end
function test.testTimeOptionTextToSeconds_1Hour()
	assertEquals( 3600, RF.TextToSeconds( "1h" ) )
end
function test.testTimeOptionTextToSeconds_1Minute()
	assertEquals( 60, RF.TextToSeconds( "1m" ) )
end
function test.testTimeOptionTextToSeconds_1Second()
	assertEquals( 1, RF.TextToSeconds( "1s" ) )
	assertEquals( 1, RF.TextToSeconds( "1" ) )
	assertEquals( 604800, RF.TextToSeconds( "604800" ) )
end
function test.testTimeOptionTextToSeconds_Mixed_MinuteSecond()
	assertEquals( 90, RF.TextToSeconds( "1m 30s" ) )
	assertEquals( 90, RF.TextToSeconds( "30s 1m" ) )
end
function test.testTimeOptionTextToSeconds_Mixed_HourMinute()
	assertEquals( 5400, RF.TextToSeconds( "1h 30m" ) )
	assertEquals( 5400, RF.TextToSeconds( "30m 1h" ) )
end
function test.testTimeOptionTextToSeconds_Mixed_HourDay()
	assertEquals( 90000, RF.TextToSeconds( "1d 1h" ) )
	assertEquals( 90000, RF.TextToSeconds( "1h 1d" ) )
end
function test.testTimeOptionTextToSeconds_Mixed_HourMinSec()
	assertEquals( 5430, RF.TextToSeconds( "1h30m30" ) )
	assertEquals( 5430, RF.TextToSeconds( "30s 30m 1h" ) )
end
function test.testTimeOptionSecondsToTime_1Week()
	assertEquals( "1w", RF.SecondsToText( 604800 ) )
end
function test.testTimeOptionSecondsToText_1Day()
	assertEquals( "1d", RF.SecondsToText( 86400 ) )
end
function test.testTimeOptionSecondsToText_1Hour()
	assertEquals( "1h", RF.SecondsToText( 3600 ) )
end
function test.testTimeOptionSecondsToText_1Minute()
	assertEquals( "1m", RF.SecondsToText( 60 ) )
end
function test.testTimeOptionSecondsToText_1Second()
	assertEquals( "1s", RF.SecondsToText( 1 ) )
end
function test.testTimeOptionSecondsToText_Mixed_MinuteSecond()
	assertEquals( "1m 30s", RF.SecondsToText( 90 ) )
end
function test.testTimeOptionSecondsToText_Mixed_HMS()
	assertEquals( "1h 30m 30s", RF.SecondsToText( 5430 ) )
end
function test.testTimeOptionSecondsToText_Mixed_DHMS()
	assertEquals( "1d 1h 30m 30s", RF.SecondsToText( 91830 ) )
end
function test.testTimeOptionSecondsToText_Mixed_()
	assertEquals( "1w 3d 13m 20s", RF.SecondsToText( 864800 ) )
end
function test.testTimeOptionTextToSeconds_badChars()
	assertEquals( 4020, RF.TextToSeconds( "1The quick brown fox 7jumps over the lazy dog."))
end
function test.testTimeOptionTextToSecondsToText_01()
	assertEquals( "1h 30m 30s", RF.SecondsToText( RF.TextToSeconds( "30s 90m" ) ) )
end
------------------
-- Chat
------------------
function test.test_SendChatMessage_ReplaceToken()
	-- Normal {RF}
	RF.SendChatMessage( "{rf}" )
	print( chatLog[#chatLog].msg )
	assertEquals( "Smile!", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_noToken()
	-- affirm that it does not replace when it should not
	RF.SendChatMessage( "The animals are lose." )
	assertEquals( "The animals are lose.", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_noToken_02()
	-- affirm that it does not replace when it should not
	RF.SendChatMessage( "The animals are lose. {circle}" )
	assertEquals( "The animals are lose. {circle}", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_noToken_03()
	-- badly formed
	RF.SendChatMessage( "{rf)" )
	assertEquals( "{rf)", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_SpecificFortune()
	RF.Command( "add SAB" )
	RF.SendChatMessage( "{Rf#2}" )
	assertEquals( "SAB", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_SpecificFortune_badIndex()
	RF.SendChatMessage( "{Rf#700}" )
	assertEquals( "Smile!", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_NoHash()
	RF.Command( "add SAB" )
	RF.SendChatMessage( "{Rf2}" )
	assertEquals( "SAB", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_textAndToken()
	RF.SendChatMessage( "Wisdom: {RF}" )
	assertEquals( "Wisdom: Smile!", chatLog[#chatLog].msg )
end
function test.test_BNSendWhiper_ReplaceToken()
	RF.BNSendWhisper( 1, "{rf}" )
	assertEquals( "Smile!", chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_Lotto()
	-- include lotto numbers
	RF.SendChatMessage( "{rf#l}" )
	assertEquals( 6, #chatLog[#chatLog].msg )
end
function test.test_SendChatMessage_Lotto_SpecificFortune()
	RF.Command( "add Legends are born in November" )
	RF.SendChatMessage( "{rf#2#l}")
end
function test.test_SendChatMessage_Lotto_SpecificFortune_upper()
	RF.Command( "add Legends are born in November" )
	RF.SendChatMessage( "{RF#2#L}")
end
function test.test_SendChatMessage_Lotto_outOfOrder()
	RF.Command( "add Legends are born in November" )
	RF.SendChatMessage( "{RF#L#2}")
end
function test.test_SendChatMessage_Lotto_noHash()
	RF.Command( "add Legends are born in November" )
	RF.SendChatMessage( "{RF#2L}")
end

test.run()
