-- require controller module
local http = require("socket.http")
local storyboard = require "storyboard"
local dealsScene = storyboard.newScene()
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

-- scene globals
local top = 0
local left = 10
local imageindex = 1
local actualimageindex = 1
local images = {} -- product image filenames
local actualimages = {} -- the actual image object
local buttonAreas = {}
local lotsOfText = "Loading Deals..."
local loadingText = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 0, 0, 0 )
local scrollView
local noInternet = false


-- buttonAreas
local function buttonAreasTouch( event )
	print("buttonAreasTouch")
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
		gproductindex = object.productindex
		productScreen()
	end
end

local function networkListener( event )
	if ( event.isError ) then
		print ( "Network error - download failed" )
	else
		event.target.alpha = 0
		transition.to( event.target, { alpha = 1.0 } )
	end
	actualimageindex = event.target.x -- use the x as index hehehe
	
	--limit image width to max 300
	actualimages[actualimageindex] = event.target
	width = actualimages[actualimageindex].width
	height = actualimages[actualimageindex].height
	actualimages[actualimageindex].width = 300
	actualimages[actualimageindex].height = 300/width*height
	actualimages[actualimageindex].y = top
	actualimages[actualimageindex].x = left
	scrollView:insert( actualimages[actualimageindex] )	
	
	-- button
	buttonAreas[actualimageindex] = widget.newButton
	{
		left = left,
		top = top,
		id = "button"..actualimageindex,
		height = actualimages[actualimageindex].height,
		defaultFile = "images/dealsbutton.png",
		onEvent = buttonAreasTouch
	}
	buttonAreas[actualimageindex].productindex = actualimageindex
	scrollView:insert( buttonAreas[actualimageindex] )
	
	top = top + actualimages[actualimageindex].height + 10
	actualimageindex = actualimageindex + 1
end

local function loadImages()
	print("loadImages")
	local fname = system.getTimer()
	if(images[imageindex]) then
		local image		
		image = display.loadRemoteImage( 
			images[imageindex], 
			"GET", 
			networkListener, 
			fname..".png", 
			system.TemporaryDirectory, 
			imageindex, -- use the x as index hehehe
			360 
		)
		imageindex = imageindex + 1
	end
end

local function networkListenerOffers( event )
	if ( event.isError ) then
		loadingText.text = "No Internet Connection.\nPull down screen to reload."
		noInternet = true
	else
		print ( "RESPONSE: " .. event.response )
		local t = json.decode( event.response )
		offers = t.data.offers
		gproducts = {}
		for i=1, table.getn(offers) do
			table.insert(gproducts, offers[i].Offer)
		end
	
		diff = table.getn(offers) - table.getn(images)
		if diff > 0 then
			i = 0
			n = table.getn(images) + 1
			while i < diff do
				print("image = "..offers[n].Offer.image)
				table.insert(images, offers[n].Offer.image)
				n = n + 1
				i = i + 1
			end
			loadImages()
		end
	end
end

local function getLatestImages()
	print("getLatestImages")
	url = "http://mondano.sg/api/offers"
	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
	local params = {}
	params.headers = headers
	network.request( url, "GET", networkListenerOffers, params )
end 

local function arrangeImages()
	xtop = 0
	ub = table.getn(actualimages)
	while ub >= 1 do
		actualimages[ub].x = left
		actualimages[ub].y = xtop
		xtop = xtop + actualimages[ub].height + 10
		ub = ub - 1
	end
end

local function loadImagesTicker( event )
	-- print( "deals ticker "..imageindex.." "..table.getn(images) )
	if imageindex <= table.getn(images) then
		loadImages()
	end
	timer.performWithDelay( 1000, loadImagesTicker, 1 )
end
timer.performWithDelay( 1000, loadImagesTicker, 1 )


-- Our ScrollView listener
local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction
	
	if "began" == phase then
		--print( "Began" )
	elseif "moved" == phase then
	elseif "ended" == phase then
	end
	
	-- If the scrollView has reached it's scroll limit
	if event.limitReached then
		if "up" == direction then
			loadingText.text = "Loading Deals..."
			if noInternet then
				getLatestImages()
			end 
		elseif "down" == direction then
			loadingText.text = "Loading Deals..."
			if noInternet then
				getLatestImages()
			end 
		elseif "left" == direction then
			print( "Reached Left Limit" )
		elseif "right" == direction then
			print( "Reached Right Limit" )
		end
	end	
	return true
end


-- Called when the scene's view does not exist:
function dealsScene:createScene( event )
	local screenGroup = self.view
	------------------------------------------------------------------------------------------------
	-- start scene
	
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
	scrollView:insert( loadingText )	
	screenGroup:insert( scrollView )
	getLatestImages()
	
	print( "\n1: deals createScene event")
end


-- Called immediately after scene has moved onscreen:
function dealsScene:enterScene( event )
	print( "1: enterScene event" )
end


-- Called when scene is about to move offscreen:
function dealsScene:exitScene( event )
	print( "1: exitScene event" )
end


-- Called prior to the removal of scene's "view" (display group)
function dealsScene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
dealsScene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
dealsScene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
dealsScene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
dealsScene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------
return dealsScene