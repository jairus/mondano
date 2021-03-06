-- require controller module
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local g = require( "mod_globals" )
local crypto = require "crypto"
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
local top = 0
local left = 0
local screenGroup
local scrollView
local myText
local loadingText = display.newText("Loading Product Details...", 10, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 81/255, 115/255, 173/255 )
local actualimage


local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction
	if "began" == phase then
	elseif "moved" == phase then
	elseif "ended" == phase then
	end
	if event.limitReached then
		if "up" == direction then
		elseif "down" == direction then
		elseif "left" == direction then
		elseif "right" == direction then
		end
	end	
	return true
end
	

-- Called when the scene's view does not exist:
function scene:createScene( event )
	screenGroup = self.view
	scrollView = widget.newScrollView
	{
		left = 0,
		top = 43+display.topStatusBarContentHeight,
		topPadding = 20,
		bottomPadding = 0,
		width = display.contentWidth,
		height = display.contentHeight-49.5-43-display.topStatusBarContentHeight,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
		backgroundColor = { 1, 1, 1 }
	}
	-- scrollView:insert(myText)
	scrollView:insert( loadingText )
	screenGroup:insert(scrollView)
	print( "\n1: deals createScene event")
end

-- buttonArea
local function buttonAreaTouch( event )
	print("buttonAreaTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		-- If the touch on the button has moved more than 10 pixels,
		-- pass focus back to the scroll view so it can continue scrolling
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	end
	if event.phase == "ended" then
		print("button pressed")
		productShare()
	end
end

local function loadActualImage()
	width = actualimage.width
	height = actualimage.height
	actualimage.width = 320
	actualimage.height = 320/width*height
	-- g.scaleMe(actualimage)
	
	actualimage.y = top
	actualimage.x = left
	scrollView:insert( actualimage )	
	actualimage.isVisible = true
	-- button

	buttonArea = widget.newButton
	{
		left = left,
		top = top+228,
		id = "button",
		height = 20,
		defaultFile = "images/product_page_button.png",
		onEvent = buttonAreaTouch
	}
	scrollView:insert( actualimage )
	scrollView:insert( buttonArea )
end

local function networkListener( event )
	if ( event.isError ) then
		dealsScreen()
	else
		event.target.alpha = 0
		transition.to( event.target, { alpha = 1.0 } )
		loadingText.text = ""
		print ( "RESPONSE: ", event.response.filename )
		actualimage = event.target
		loadActualImage()
	end
	
	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	if actualimage then
		actualimage.isVisible = false
	end
	loadingText.text = "Loading Product Details..."
	-- myText.text = gproducts[gproductindex].prodDetail
	-- print(gproductindex.."  -- "..gproducts[gproductindex].prodDetail)
	
	print(gproducts[gproductindex].product_id.."<--- product_id")
	fname = crypto.digest( crypto.md5, gproducts[gproductindex].prodDetail )
	local imagepath = system.pathForFile( fname..".png", system.TemporaryDirectory )
	imagepath = string.gsub(imagepath, "\\", "/")
	actualimage = display.newImage( imagepath )
	if actualimage then
		loadActualImage()
	else
		err = pcall(
			function()
				image = display.loadRemoteImage( 
					gproducts[gproductindex].prodDetail, 
					"GET", 
					networkListener, 
					fname..".png", 
					system.TemporaryDirectory, 
					centerX, 360 
				)
				error()
			end
		)
	end
	print("error ?"..tostring(err))

	
		
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