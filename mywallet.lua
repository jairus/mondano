-- require controller module
local http = require("socket.http")
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
local thememberid = 38

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- scene globals
local top = 10
local left = 10
local imageindex = 1
local actualimageindex = 1
local images = {} -- product image filenames
local actualimages = {} -- the actual image object
local productTitles = {} -- product titles
local productExpiryTexts = {} -- product expiry texts
local checks = {} -- check buttons
local products = {} -- the products
local buttonAreas = {}

local memberproducts = {}
local lotsOfText = "Loading Your Wallet..."
local loadingText = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 0, 0, 0 )
local scrollView

-- http://d.pr/i/XArh -- my wallet screenshot



-- get member products
local function networkListenerMemberProducts( event )
	print("networkListenerMemberProducts")
	if ( event.isError ) then

	else
		local t = json.decode( event.response )
		--[[
		[0] => stdClass Object
			(
				[MembersProduct] => stdClass Object
					(
						[id] => 14
						[members_id] => 3
						[products_id] => 4
						[date_availed] => 2013-12-02 17:58:06
						[reviewed] => 
						[usedAs] => 
						[claim_status] => 1
						[redeemCode] => JTPD1PG1TJ
					)

			)
		top = 10
		left = 10
		imageindex = 1
		images = {} -- product image filenames
		actualimages = {} -- the actual image object
		productTitles = {} -- product titles
		productExpiryTexts = {} -- product expiry texts
		checks = {} -- check buttons
		products = {} -- the products
		buttonAreas = {}
		
		--]]
		
		
		memberproducts = t.data
		str = ""
		--print(t.data[1].MembersProduct.id)
		local imagestemp = {}
		for i=1,table.getn(memberproducts) do
			product = memberproducts[i].Offer
			imgurl = product.thumbnailCircle
			if imgurl then
				table.insert(products, product)
				table.insert(imagestemp, imgurl)
			end
		end
		
		-- update expiry dates
		for i=1,table.getn(productExpiryTexts) do
			productExpiryTexts[i].text = products[i].expiryText
		end
		
		if(table.getn(imagestemp)>0) then
			loadingText.text = ""
			diff = table.getn(imagestemp) - table.getn(images)
			if diff > 0 then
				i = 0
				n = table.getn(images) + 1
				while i < diff do
					print("image = "..imagestemp[n])
					table.insert(images, imagestemp[n])
					n = n + 1
					i = i + 1
				end
			end
		else 
			print("here 2")
			loadingText.text = "Your Mondano Wallet is empty."
		end
		
	end
end
local function getMemberProducts() --1st step is get the offers
	print("getMemberProducts")
	-- loadingText.text = "loaded"
	url = "http://mondano.sg/api/membersProducts/byFacebookId?fbid=100006286952227"
	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
	local params = {}
	params.headers = headers
	network.request( url, "GET", networkListenerMemberProducts, params )
	-- run this function again after 60 secs
	timer.performWithDelay( 60000, getMemberProducts, 1 )
end 

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
		if checks[object.imageindex].isVisible then
			checks[object.imageindex].isVisible = false
		else
			checks[object.imageindex].isVisible = true
		end
	end
end

local function networkListenerloadImages( event )
	if ( event.isError ) then
		print ( "Network error - download failed" )
	else
		event.target.alpha = 0
		transition.to( event.target, { alpha = 1.0 } )
	end
	actualimageindex = event.target.x -- use the x as index hehehe
	-- print ( "RESPONSE: "..actualimageindex, event.response.filename )
	--limit image width to max 300
	
	-- circle image
	actualimages[actualimageindex] = event.target
	width = actualimages[actualimageindex].width
	height = actualimages[actualimageindex].height
	-- actualimages[actualimageindex].width = 300
	-- actualimages[actualimageindex].height = 300/width*height
	g.scaleMe(actualimages[actualimageindex])
	actualimages[actualimageindex].y = top
	actualimages[actualimageindex].x = left
	scrollView:insert( actualimages[actualimageindex] )
	
	-- product title
	-- productTitle = display.newText(products[actualimageindex].title, 0, 0, display.contentWidth-20, 0, native.systemFont, 14)
	productTitles[actualimageindex] = display.newText(products[actualimageindex].title, 0, 0, display.contentWidth-20, 0, native.systemFont, 14)
	productTitles[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+10
	productTitles[actualimageindex].y = top+4
	productTitles[actualimageindex]:setFillColor( 96/255, 96/255, 96/255 )
	scrollView:insert( productTitles[actualimageindex] )
	
	-- productExpiryTexts
	productExpiryTexts[actualimageindex] = display.newText(products[actualimageindex].expiryText, 0, 0, display.contentWidth-20, 0, native.systemFont, 10)
	productExpiryTexts[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+10
	productExpiryTexts[actualimageindex].y = top+4+productTitles[actualimageindex].height
	productExpiryTexts[actualimageindex]:setFillColor( 96/255, 96/255, 96/255 )
	scrollView:insert( productExpiryTexts[actualimageindex] )
	
	-- check button
	checks[actualimageindex] = display.newImage( "images/check.png")
	checks[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+240
	checks[actualimageindex].y = top + 10
	g.scaleMe(checks[actualimageindex])
	scrollView:insert( checks[actualimageindex] )
	
	-- button
	buttonAreas[actualimageindex] = widget.newButton
	{
		left = left,
		top = top - 10,
		id = "button"..actualimageindex,

		defaultFile = "images/buttonarea.png",
		onEvent = buttonAreasTouch
	}
	buttonAreas[actualimageindex].imageindex = actualimageindex
	scrollView:insert( buttonAreas[actualimageindex] )

	
	top = top + g.scaleHeight(actualimages[actualimageindex]) + 10
	
	
	local bottomline = display.newImage( "images/line.png")
	bottomline.x = 0
	bottomline.y = top
	top = top + g.scaleHeight(bottomline) + 10
	g.scaleMe(bottomline)
	scrollView:insert( bottomline )	
	
	actualimageindex = actualimageindex + 1
	-- arrange image reverse
	-- actualimages[actualimageindex].y = 0
	-- actualimages[actualimageindex].x = 0
	-- arrangeImages()
end


local function loadImages()
	print("loadImages")
	local fname = system.getTimer()
	if(images[imageindex]) then
		if imageindex == 1 then
			print("------------------------------------------------------")
			local topline = display.newImage( "images/line.png")
			topline.x = 0
			topline.y = 0
			g.scaleMe(topline)
			scrollView:insert( topline )	
		end
		image = display.loadRemoteImage( 
			images[imageindex], 
			"GET", 
			networkListenerloadImages, 
			fname..".png", 
			system.TemporaryDirectory, 
			imageindex,
			360 
		)
		imageindex = imageindex + 1
	else
		loadingText.text = "You don't have any offers in your wallet"
	end
	
end

local function loadImagesTicker( event )
	-- print( "mywallet ticker "..imageindex.." "..table.getn(images) )
	if imageindex <= table.getn(images) then
		loadImages()
	end
	timer.performWithDelay( 1000, loadImagesTicker, 1 )
end

local function scrollListener( event )
	-- print("scrollListener")
	local phase = event.phase
	local direction = event.direction
	if "began" == phase then
	elseif "moved" == phase then
	elseif "ended" == phase then
	end
	if event.limitReached then
		if "up" == direction then
			-- loadingText.text = "Loading Your Wallet..."
			getMemberProducts()
		elseif "down" == direction then
			-- loadingText.text = "Loading Your Wallet..."
			getMemberProducts()
		elseif "left" == direction then
		elseif "right" == direction then
		end
	end
			
	return true
end
	

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	print("topStatusBarContentHeight = "..display.topStatusBarContentHeight)

	------------------------------------------------------------------------------------------------
	-- start scene
	
	local wallet_title = display.newImage( "images/wallet_title.png")
	wallet_title.x = 0
	wallet_title.y = 43+display.topStatusBarContentHeight
	g.scaleMe(wallet_title)
	wallet_title.isVisible = true
				
	scrollView = widget.newScrollView
	{
		left = 0,
		top = 43+display.topStatusBarContentHeight+g.scaleHeight(wallet_title),
		topPadding = 0,
		bottomPadding = 0,
		width = display.contentWidth,
		height = display.contentHeight-49.5-43-display.topStatusBarContentHeight-g.scaleHeight(wallet_title),
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
		backgroundColor = { 1, 1, 1 }
	}
	
	getMemberProducts()
	timer.performWithDelay( 1000, loadImagesTicker, 1 )
	
	scrollView:insert( loadingText )
	screenGroup:insert(scrollView)
	screenGroup:insert(wallet_title)
	print( "\n1: mywallet createScene event")
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	print( "1: enterScene event" )
	getMemberProducts()
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