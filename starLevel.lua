-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona libraries

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH = display.contentWidth, display.contentHeight
local halfW, halfH = display.contentCenterX, display.contentCenterY

local starTable = {} -- table to hold stars by id
local touchable = false -- boolean to keep track of when the player can touch the stars
local starRadius = 20
local totalStars -- number of stars to find
local collectedStars -- number of correct stars collected so far
local currentLevel -- the current level number

local makeStar -- function to make star
local makeRandomStar -- function to make a star in a random location
local makeStars -- function to make n stars
local makeStarGrid -- function to make stars in a grid formation
local onStarTouch -- event listener for stars
local colorStar -- function to make star shine
local uncolorStar -- function to return star to normal
local showStarPattern -- Lights up stars with ids in given table
local uncolorAllStars
local startRound -- function to start the current round
local endRound -- function to end the current round
local calculateScore -- function to determine score

-- Sounds
local twinkleSound = audio.loadStream("sounds/twnkle.mp3")
local backgroundMusic = audio.loadStream("sounds/loop.mp3")
local hitSound = audio.loadStream("sounds/touch.mp3")
local missSound = audio.loadStream("sounds/wrong.mp3")
local backgroundMusicChannel = 1
local starChannel = 2
local hitSoundLength = 500

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
	math.randomseed(1)-- seed random so same stars each time
	
	-- create stars
	local stars = makeStars(10) --display.newGroup(screenW, screenH)
	--local stars = makeStarGrid()
	stars.anchorX, stars.anchorY = 0.5, 0.5
	stars.x, stars.y = 0, 0 --halfW, halfH

	-- all display objects must be inserted into group
	group:insert( stars )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- start background music
	audio.play( backgroundMusic, { channel=backgroundMusicChannel, loops=-1, fadein=1000 }  )
	print("background music channel:" .. backgroundMusicChannel)
	
	-- Show star pattern after 1.5 second
	currentLevel = event.params.level
	totalStars = currentLevel
	local patternClosure = function() return showStarPattern(totalStars) end
	timer.performWithDelay( 1000, patternClosure, 1 )
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
-- Game functions
-----------------------------------------------------------------------------------------
local colorBlurEffect = require( "kernel_filter_color_blur_gl" )
graphics.defineEffect( colorBlurEffect )

showStarPattern = function(n)
	for i=1, n do
		starTable[i].shine = true
		colorStar(starTable[i], 1, 1, 0) -- color star yellow
	end
	-- play sound effect
	local soundOptions = { 
		channel=starChannel,
		onComplete=startRound
	}
	audio.play( twinkleSound, soundOptions  )
	-- Start round after delay
	--timer.performWithDelay( 3000, startRound, 1 )
end

uncolorAllStars = function()
	for key,star in  ipairs(starTable) do
		uncolorStar(star)
		star.collected = false
	end
end

makeStars = function(n)
	local stars = display.newGroup(screenW, screenH)
	for i=1, n do
		local star = makeRandomStar()
		star.id = i
		starTable[star.id] = star
		star:addEventListener( "touch", onStarTouch )
		stars:insert(star)
	end
	return stars
end

makeStarGrid = function()
	local stars = display.newGroup(screenW, screenH)
	local tileSize = starRadius * 4
	local cols = screenW / tileSize
	local rows = screenH / tileSize
	local offset = 0
	local i = 1
	for r =1, rows do
		for c=1, cols do
			i = i + 1
			--print ("row:"..r.."col:"..c)
			local x = c * tileSize + offset
			local y = r * tileSize + offset
			local star = makeStar(x,y)
			star.id = i
			starTable[star.id] = star
			star:addEventListener( "touch", onStarTouch )
			stars:insert(star)

		end
	end
	return stars
end

makeRandomStar = function()
	local buffer = starRadius
	local currentX = math.random(buffer, screenW - buffer)
	local currentY = math.random(buffer, screenH - buffer)
	local star = makeStar(currentX, currentY)
	return star
end

makeStar = function(x, y)
	local star = display.newSnapshot( starRadius*2.5, starRadius*2.5 )
	local starGroup = star.group
	local starCircle = display.newCircle( 0, 0,  starRadius)
	starCircle:setFillColor(1,1,1,0.8 )
	starGroup:insert(starCircle)
	star.fill.effect = "filter.colorBlurGaussian"
--[[local star = display.newImageRect( "images/star.png", starRadius*2, starRadius*2)]]
	star.anchorX, star.anchorY = 0.5, 0.5
	star.x, star.y = x, y
	star.shine = false
	star.collected = false
	star.fill.effect.horizontal.blurSize = starRadius*0.5
	star.fill.effect.vertical.blurSize = starRadius*0.5
	uncolorStar(star) -- uncolor star (color white)
	return star
end

onStarTouch = function( event )
	star = event.target
	if not touchable then
		return -- exit early if stars not touchable
	end
    if event.phase == "began" then	
		--audio.stop(starChannel)
        --print( "Touched star " .. star.id )
		if star.collected then
			return -- exit early if star has already been collected
		end
		if star.shine then
			colorStar(star, 1, 1, 0) -- color star yellow
			collectedStars = collectedStars + 1
			star.collected = true
			audio.play( hitSound, { channel=starChannel, duration=hitSoundLength }  )
		else
			colorStar(star, 1, 0, 0) -- color star red
			star.collected = true
			audio.play( missSound, { channel=starChannel, duration=hitSoundLength }  )
		end
    end
    if event.phase == "ended" then
		if collectedStars >= totalStars then
			endRound()
		else
			print (collectedStars .. "/" .. totalStars)
		end
	end
    return true
end

colorStar = function(star, r, g, b)
	--print( "Color star " .. star.id )
	-- colorize with filter
	--star.fill.effect = "filter.monotone"
	star.fill.effect.monotone.r = r
	star.fill.effect.monotone.g = g
	star.fill.effect.monotone.b = b
	star.fill.effect.monotone.a = 0.8
end

uncolorStar = function(star)
	--star.shine = false
	--star.fill.effect = nil -- remove fill effect
	w = 0.8 --whiteness
	colorStar(star,w,w,w)
end

startRound = function()
	uncolorAllStars()
	collectedStars = 0
	touchable = true
end

endRound = function()
	touchable = false
	-- go to end level menu scene
	local endLevelOptions =
	{
	    effect = "fade",
	    time = 500,
	    params = { 
			level = currentLevel,
			score = calculateScore()
		}
	}
	local sceneClosure = function() 
		uncolorAllStars()
		storyboard.gotoScene( "endofLevelMenu", endLevelOptions ) 
	end
	-- play sound effect to indicate round completed
	audio.play( twinkleSound, {onComplete=sceneClosure} )
end

calculateScore = function()
	local correctGuesses = 0
	local wrongGuesses = 0
	local totalGuesses = 0
	local pointsForCorrect = 2
	local pointsForWrong = -1
	local score = 0
	for key,star in ipairs(starTable) do
		if star.collected then
			if star.shine then
				score = score + pointsForCorrect
				correctGuesses = correctGuesses + 1
			else
				wrongGuesses = wrongGuesses + 1
				score = score + pointsForWrong
			end
			totalGuesses = totalGuesses + 1	
		end
	end
	if not correctGuesses == totalStars then
		print ("Did not collect all stars")
	end
	print ("Right guesses: " .. correctGuesses)
	print ("Wrong guesses: " .. wrongGuesses)
	print ("score :" .. score)
	if score < 0 then
		score = 0 -- no negative scores
	end
	return score
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