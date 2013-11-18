-----------------------------------------------------------------------------------------
--
-- levelMenu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona libraries

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH = display.contentWidth, display.contentHeight
local halfW, halfH = display.contentCenterX, display.contentCenterY

local currentLevel -- the level number of the level just completed
local score -- the score from the level just completed
local levelMessage -- display level completed
local scoreMessage -- display score

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	-- show instructions
	local messageBox = display.newGroup()
	messageBox.anchorX, messageBox.anchorY = 0.5, 0.5
	messageBox.x, messageBox.y = halfW, halfH
	local messageBoxBackground = display.newRect(0,0,screenW*0.75, screenH*0.75)
	messageBoxBackground.fill = {0.2,0.1,0.2}
	messageBox:insert(messageBoxBackground)
	levelMessage = display.newText("",0,0,native.systemFont,18)
	messageBox:insert(levelMessage)
	levelMessage.y = -screenH*0.25
	scoreMessage = display.newText("",0,0,native.systemFont,18)
	messageBox:insert(scoreMessage)
	
	group:insert(messageBox)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	currentLevel = event.params.level
	score = event.params.score
	
	levelMessage.text = "Level " .. currentLevel
	scoreMessage.text = "Score: " .. score
	
	nextLevel = currentLevel + 1
	local options =
	{
	    effect = "fade",
	    time = 800,
	    params = { 
	    	level = nextLevel,
	    	score = score
	    }
	}
	local sceneClosure = function() storyboard.gotoScene( "starLevel", options ) end
	timer.performWithDelay( 1000, sceneClosure, 1 )
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene