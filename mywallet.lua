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
	
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	print("topStatusBarContentHeight = "..display.topStatusBarContentHeight)
	
	-- scene globals
	local top = 10
	local left = 10
	local imageindex = 1
	local images = {} -- product image filenames
	local actualimages = {} -- the actual image object
	local products = {}
	local goffers = {}
	local gfbid = ""
	local gmemberid = ""
	local gmemberproducts = {}
	local lotsOfText = "Loading Your Wallet..."
	local loadingText = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
	loadingText:setFillColor( 0, 0, 0 )
	local scrollView
	
	
	
	-- get member products
	local function networkListenerMemberProducts( event )
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
			--]]
			gmemberproducts = t.data
			str = ""
			--print(t.data[1].MembersProduct.id)
			local imagestemp = {}
			for i=1,table.getn(gmemberproducts) do
				product = gmemberproducts[i].Offer
				imgurl = product.thumbnailCircle
				if imgurl then
					table.insert(products, product)
					table.insert(imagestemp, imgurl)
				end
			end
			print("here 1 "..table.getn(imagestemp))
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
	end 
	
	
	local function networkListenerloadImages( event )
		if ( event.isError ) then
			print ( "Network error - download failed" )
		else
			event.target.alpha = 0
			transition.to( event.target, { alpha = 1.0 } )
		end
		-- print ( "RESPONSE: "..imageindex, event.response.filename )
		--limit image width to max 300
		
		-- circle image
		actualimages[imageindex] = event.target
		width = actualimages[imageindex].width
		height = actualimages[imageindex].height
		-- actualimages[imageindex].width = 300
		-- actualimages[imageindex].height = 300/width*height
		g.scaleMe(actualimages[imageindex])
		actualimages[imageindex].y = top
		actualimages[imageindex].x = left
		
		-- product title
		local productTitle = display.newText(products[imageindex].title, g.scaleWidth(actualimages[imageindex])+left+10, top+3, display.contentWidth-20, 0, native.systemFont, 14)
		productTitle:setFillColor( 96/255, 96/255, 96/255 )
		
		-- check button
		local check = display.newImage( "images/check.png")
		check.x = g.scaleWidth(actualimages[imageindex])+left+240
		check.y = top + 10
		g.scaleMe(check)
		
		scrollView:insert( productTitle )
		scrollView:insert( actualimages[imageindex] )
		scrollView:insert( check )
		
		top = top + g.scaleHeight(actualimages[imageindex]) + 10
		
		
		local bottomline = display.newImage( "images/line.png")
		bottomline.x = 0
		bottomline.y = top
		top = top + g.scaleHeight(bottomline) + 10
		g.scaleMe(bottomline)
		scrollView:insert( bottomline )	
		
		imageindex = imageindex + 1
	
		-- arrange image reverse
		-- actualimages[imageindex].y = 0
		-- actualimages[imageindex].x = 0
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
				centerX, 360 
			)
			
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