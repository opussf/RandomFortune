#!/usr/bin/env lua

addonData = {
	["Version"] = "1.0",
	["Title"] = "Random Fortune",
	["Author"] = "Me",
}

require "wowTest"

test.outFileName = "testOut.xml"

RFFrame = CreateFrame()

package.path = "../src/?.lua;'" .. package.path
require "RF"
require "RFOptions"


function test.before()
	RF.OnLoad()
	RF_fortunes = { { ["fortune"] = "Smile!", ["lastPost"] = 0, } }
	RF_options.enabled = true -- default to on
end
function test.after()
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


test.run()
