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
	assertEquals( "(1-7-38-23-27-11)", ln )
end
function test.testNoFortunesDoesNotCrash()
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





test.run()
