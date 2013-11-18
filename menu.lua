-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH = display.contentWidth, display.contentHeight
local halfW, halfH = display.contentCenterX, display.contentCenterY
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	local options =
	{
	    effect = "fade",
	    time = 800,
	    params = { level = 1, score = 0 }
	}
	storyboard.gotoScene( "starLevel", options )
	
	return true	-- indicates successful touch
end

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
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Play",
		labelColor = { default={255}, over={128} },
		defaultFile="images/button.png",
		overFile="images/button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.anchorX, playBtn.anchorY = 0.5, 0.5
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight*0.75
	
	-- show instructions
	local tutorial = display.newGroup()
	tutorial.anchorX, tutorial.anchorY = 0.5, 0.5
	tutorial.x, tutorial.y = halfW, halfH
	local tutorialBox = display.newRect(0,0,screenW*0.75, screenH*0.75)
	tutorialBox.fill = { type="gradient", color1={ 0.2,0.1,0.2,1 }, color2={ 0,0,0,0 } }
	tutorial:insert(tutorialBox)
	local tutorialText1 = display.newText("Tap the dots that light up and move",0,0,native.systemFont,18)
	tutorial:insert(tutorialText1)
	--tutorialText1.y = -screenH*0.1
	
	-- all display objects must be inserted into group
	group:insert( tutorial )
	group:insert( playBtn )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
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