-- require controller module
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local g = require( "mod_globals" )
local json = require "json"

-- configs
-- hide device status bar
display.setStatusBar( display.DefaultStatusBar )
display.setDefault( "background", 255/255, 255/255, 255/255 )
display.setDefault( "anchorX", 0 )
display.setDefault( "anchorY", 0 )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local screenGroup 
local myText


local function successButtonTouch( event )
	print("successButtonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
	end
	if event.phase == "ended" then
		print("successButtonTouch")
		mywalletScreen()
	end
end

local function cancelButtonTouch( event )
	print("cancelButtonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
	end
	if event.phase == "ended" then
		print("cancelButtonTouch")
		dealsScreen()
	end
end


function scene:createScene( event )
	screenGroup = self.view
	
	
	local successButton = widget.newButton
	{
		top = 100,
		id = "button",
		defaultFile = "images/claim_success.png",
		onEvent = successButtonTouch
	}
	successButton.x = g.centerPos(successButton)
	g.scaleMe(successButton)
	screenGroup:insert( successButton )
	
	
	
	print( "\n1: deals createScene event")
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	print( "1: enterScene event" )
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	print( "1: exitScene event" )
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------
return scene