-- require controller module
local http = require("socket.http")
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local g = require( "mod_globals" )
local json = require "json"

-- configs
-- hide device status bar
display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 255/255, 255/255, 255/255 )
display.setDefault( "anchorX", 0 )
display.setDefault( "anchorY", 0 )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
	
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	print(display.pixelHeight)
	
	top = 0
	left = 10
	imageindex = 1
	-- images 
	images = {}
	actualimages = {}
	
	
	function print_r(arr, indentLevel)
		local str = ""
		local indentStr = "#"

		if(indentLevel == nil) then
			print(print_r(arr, 0))
			return
		end

		for i = 0, indentLevel do
			indentStr = indentStr.."\t"
		end

		for index,value in pairs(arr) do
			if type(value) == "table" then
				str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
			else 
				str = str..indentStr..index..": "..value.."\n"
			end
		end
		return str
	end
	
	local function networkListenerOffers( event )
		if ( event.isError ) then
		else
			-- print ( "RESPONSE: " .. event.response )
			local t = json.decode( event.response )
			offers = t.data.offers
			
			
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
			end
			-- print(t.data.offers[0].Offer.image)
			-- print_r(t)
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
		-- table.insert(images, "http://www.mondano.sg/img/california-fitness-main.jpg")
		print("Image upperbound "..table.getn(images)) 
		
		-- images[1] = "http://www.mondano.sg/img/california-fitness-main.jpg"
		-- images[2] = "http://www.mondano.sg/img/california-fitness-main.jpg"
		-- images[3] = "http://www.mondano.sg/img/california-fitness-main.jpg"
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
	
	local function networkListener( event )
		if ( event.isError ) then
			print ( "Network error - download failed" )
		else
			event.target.alpha = 0
			transition.to( event.target, { alpha = 1.0 } )
		end
		
		print ( "RESPONSE: "..imageindex, event.response.filename )
		
		--limit image width to max 300
		actualimages[imageindex] = event.target
		width = actualimages[imageindex].width
		height = actualimages[imageindex].height
		actualimages[imageindex].width = 300
		actualimages[imageindex].height = 300/width*height
		
		actualimages[imageindex].y = top
		actualimages[imageindex].x = left
		top = top + actualimages[imageindex].height + 10
		
		scrollView:insert( actualimages[imageindex] )	
		
		
		-- arrange image reverse
		-- actualimages[imageindex].y = 0
		-- actualimages[imageindex].x = 0
		-- arrangeImages()
		
	end
	
	
	local function loadImages()
		print("loadImages")
		local fname = system.getTimer()
		if(images[imageindex]) then
			image = display.loadRemoteImage( 
				images[imageindex], 
				"GET", 
				networkListener, 
				fname..".png", 
				system.TemporaryDirectory, 
				centerX, 360 
			)
			imageindex = imageindex + 1
		end
		
	end
	
	local function loadImagesTicker( event )
		-- print( "ticker "..imageindex.." "..table.getn(images) )
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
			--print( "Moved" )
		elseif "ended" == phase then
			--print( "Ended" )
		end
		
		-- If the scrollView has reached it's scroll limit
		if event.limitReached then
			if "up" == direction then
				getLatestImages()
				-- print( "Reached Top Limit" )
			elseif "down" == direction then
				getLatestImages()
				-- print( "Reached Bottom Limit" )
			elseif "left" == direction then
				print( "Reached Left Limit" )
			elseif "right" == direction then
				print( "Reached Right Limit" )
			end
		end
				
		return true
	end
	
	getLatestImages()

	-- Create a ScrollView
	scrollView = widget.newScrollView
	{
		left = 0,
		top = 43,
		topPadding = 20,
		bottomPadding = 0,
		width = display.contentWidth,
		height = display.contentHeight-49.5-43,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
		backgroundColor = { 1, 1, 1 }
	}

	
	
	--Create a text object for the scrollViews title
	-- lotsOfText = system.getInfo( "maxTextureSize" ).." "..display.pixelWidth.." "..display.pixelHeight.." "..display.contentWidth.." "..display.contentHeight.." Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod.  "
	-- text = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
	-- text:setFillColor( 0, 0, 0 )
	-- insert the text object into the created display group
	-- scrollView:insert( text )
	-- top = top + text.height + 10
	

	
	--local lotsOfText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris. "
	--local lotsOfTextObject = display.newText( lotsOfText, display.contentCenterX, 0, 300, 0, "Helvetica", 14)
	--lotsOfTextObject:setFillColor( 0 ) 
	--lotsOfTextObject.anchorY = 0.0		-- Top
	--lotsOfTextObject.y = titleText.y + titleText.contentHeight + 10
	-- scrollView:insert( lotsOfTextObject )


	--Create a text object for the scrollViews title
	lotsOfText = "Loading Deals..."
	text = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
	text:setFillColor( 0, 0, 0 )
	-- insert the text object into the created display group
	scrollView:insert( text )
	
	screenGroup:insert(scrollView)
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