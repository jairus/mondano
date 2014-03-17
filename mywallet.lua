-- require controller module
local http = require("socket.http")
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local g = require( "mod_globals" )
local json = require "json"
local crypto = require "crypto"

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
local mproducts = {} -- the products
local buttonAreas = {}
local bottomlines = {}

local memberproducts = {}
local lotsOfText = "Loading Your Wallet..."
local loadingText = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 81/255, 115/255, 173/255 )
local loadingText2 = display.newText(lotsOfText, left, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText2:setFillColor( 81/255, 115/255, 173/255 )
local scrollView
local scrollView2
local redeemtext = nil
local redeemimage = nil
local redeembutton = nil
local prodindex

-- http://d.pr/i/XArh -- my wallet screenshot


local function hideAll()
	while actualimages[i] do
		actualimages[i].isVisible = false
		productTitles[i].isVisible = false
		productExpiryTexts[i].isVisible = false
		checks[i].isVisible = false
		buttonAreas[i].isVisible = false
		bottomlines[i].isVisible = false
		i = i+1
	end 
	top = 10
	left = 10
	imageindex = 1
	actualimageindex = 1
	images = {} -- product image filenames
	actualimages = {} -- the actual image object
	productTitles = {} -- product titles
	productExpiryTexts = {} -- product expiry texts
	checks = {} -- check buttons
	products = {} -- the products
	mproducts = {}
	buttonAreas = {}
	bottomlines = {}
end

local function networkRedeem( event )
	if ( event.isError ) then
		loadingText.text = "No Internet Connection.\nPull down screen to reload."
		hideAll()
	else
		print ( "RESPONSE: " .. tostring(event.response) )
		mywalletScreen()
	end
	--myText.isVisible = true
end

local function redeembuttonTouch(event)
	print("redeembuttonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		-- If the touch on the button has moved more than 10 pixels,
		-- pass focus back to the scroll view so it can continue scrolling
		if ( dy > 10 ) then
			scrollView2:takeFocus( event )
		end
	end
	if event.phase == "ended" then
		print("button pressed")
		
		if true then
			url = "http://www.mondano.sg/api/membersProducts/redeem?fb_id="..gfbid.."&product_id="..mproducts[prodindex].products_id
			local headers = {}
			headers["Content-Type"] = "application/json"
			headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
			local params = {}
			params.headers = headers
			network.request( url, "GET", networkRedeem, params )
		end
	end
end

local function networkListenerloadRedeemCode( event )
	if ( event.isError ) then
		print ( "Network error - download failed" )
	else
		event.target.alpha = 0
		transition.to( event.target, { alpha = 1.0 } )
	end
	
	-- the image
	redeemimage = event.target
	prodindex = redeemimage.x
	offertype = redeemimage.y
	width = redeemimage.width
	height = redeemimage.height
	g.scaleMe(redeemimage)
	redeemimage.x = 0
	redeemimage.y = 0
	redeemimage.isVisible = true
	scrollView2:insert(redeemimage)
	loadingText2.isVisible = false
	-- the title
	
	
	if offertype == 1 or offertype == 2 then
		redeemimage.y = 47
		--local title = display.newText(ttext, 10, 10, display.contentWidth-20, 0, native.systemFont, 16)
		local ttext = "Your unique redeem code is:\n"..mproducts[prodindex].redeemCode
		if redeemtext == nil then
			local options = 
			{
				--parent = textGroup,
				text = ttext,     
				x = 0,
				y = 10,
				width = 320,     --required for multi-line and alignment
				font = native.systemFontBold,   
				fontSize = 16,
				align = "center"  --new alignment parameter
			}
			redeemtext = display.newText(options)
			redeemtext:setFillColor( 81/255, 115/255, 173/255 )
			scrollView2:insert(redeemtext)
		end
		redeemtext.text = ttext
		redeemtext.isVisible = true
	elseif offertype == 3 then
		if redeembutton == nil then
			redeembutton = widget.newButton
			{
				left = 0,
				top = 229,
				id = "button",
				height = 20,
				defaultFile = "images/product_page_button.png",
				onEvent = redeembuttonTouch
			}
			scrollView2:insert( redeembutton )
		end
		redeembutton.isVisible = true
	end 
	
	scrollView2.isVisible = true
	resetTabs()
	
end

local function loadRedeemCode(url, pindex)
	prodindex = pindex
	print("loadRedeemCode")
	scrollView.isVisible = false
	scrollView2.isVisible = true
	loadingText2.text = "Loading Offer..."
	loadingText2.isVisible = true
	if redeemimage  then
		redeemimage.isVisible = false
	end
	if redeemtext  then
		redeemtext.isVisible = false
	end
	if redeembutton  then
		redeembutton.isVisible = false
	end
	
	-- local fname = system.getTimer()
	local fname = crypto.digest( crypto.md5, url )
	if(url) then
		image = display.loadRemoteImage( 
			url, 
			"GET", 
			networkListenerloadRedeemCode, 
			fname..".png", 
			system.TemporaryDirectory, 
			prodindex, -- x carries the index of the product
			tonumber(products[prodindex].offerType) -- y carries the offertype
		)
	else
		
	end
end

-- get member products
local function networkListenerMemberProducts( event )
	print("networkListenerMemberProducts")
	if ( event.isError ) then
		loadingText.text = "No Internet Connection.\nPull down screen to reload."
		hideAll()
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
		
		products = {}
		mproducts = {}
		memberproducts = t.data
		str = ""
		--print(t.data[1].MembersProduct.id)
		local imagestemp = {}
		for i=1,table.getn(memberproducts) do
			product = memberproducts[i].Offer
			mproduct = memberproducts[i].MembersProduct
			imgurl = product.thumbnailCircle
			print(product.title.."<----------------\n\n")
			print(product.offerType.."<----------------\n\n")
			if imgurl then
				table.insert(products, product)
				table.insert(mproducts, mproduct)
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
			hideAll()
		end
		
	end
end
local function getMemberProducts() --1st step is get the offers
	print("getMemberProducts")
	-- loadingText.text = "loaded"
	if gfbid == "" or gloggedin==false then
		loadingText.text = "Please login to check your wallet."
		hideAll()
	else
		url = "http://mondano.sg/api/membersProducts/byFacebookId?fbid="..gfbid
		local headers = {}
		headers["Content-Type"] = "application/json"
		headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
		local params = {}
		params.headers = headers
		network.request( url, "GET", networkListenerMemberProducts, params )
		-- run this function again after 60 secs
		timer.performWithDelay( 60000, getMemberProducts, 1 )
	end
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
		print(products[object.imageindex].offerType.."<----------------\n\n")
		
		if products[object.imageindex].offerType=="1" or products[object.imageindex].offerType=="2" or products[object.imageindex].offerType=="3" then
			print(mproducts[object.imageindex].redeemCode.."<----------------\n\n")
			print(products[object.imageindex].walletImg.."<----------------\n\n")
			loadRedeemCode(products[object.imageindex].walletImg, object.imageindex)
		else
			if checks[object.imageindex].isVisible then
				checks[object.imageindex].isVisible = false
			else
				checks[object.imageindex].isVisible = true
			end
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
	actualimages[actualimageindex].isVisible = true
	scrollView:insert( actualimages[actualimageindex] )
	print("actualimages "..actualimageindex)
	
	-- product title
	-- productTitle = display.newText(products[actualimageindex].title, 0, 0, display.contentWidth-20, 0, native.systemFont, 14)
	productTitles[actualimageindex] = display.newText(products[actualimageindex].title, 0, 0, display.contentWidth-20, 0, native.systemFont, 14)
	productTitles[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+10
	productTitles[actualimageindex].y = top+4
	productTitles[actualimageindex]:setFillColor( 96/255, 96/255, 96/255 )
	productTitles[actualimageindex].isVisible = true
	scrollView:insert( productTitles[actualimageindex] )
	
	-- productExpiryTexts
	productExpiryTexts[actualimageindex] = display.newText(products[actualimageindex].expiryText, 0, 0, display.contentWidth-20, 0, native.systemFont, 10)
	productExpiryTexts[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+10
	productExpiryTexts[actualimageindex].y = top+4+productTitles[actualimageindex].height
	productExpiryTexts[actualimageindex]:setFillColor( 96/255, 96/255, 96/255 )
	productExpiryTexts[actualimageindex].isVisible = true
	scrollView:insert( productExpiryTexts[actualimageindex] )
	
	-- check button
	checks[actualimageindex] = display.newImage( "images/check.png")
	checks[actualimageindex].x = g.scaleWidth(actualimages[actualimageindex])+left+240
	checks[actualimageindex].y = top + 10
	checks[actualimageindex].isVisible = false
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
	buttonAreas[actualimageindex].isVisible = true
	scrollView:insert( buttonAreas[actualimageindex] )

	
	top = top + g.scaleHeight(actualimages[actualimageindex]) + 10
	
	
	bottomlines[actualimageindex] = display.newImage( "images/line.png")
	bottomlines[actualimageindex].x = 0
	bottomlines[actualimageindex].y = top
	bottomlines[actualimageindex].isVisible = true
	top = top + g.scaleHeight(bottomlines[actualimageindex]) + 10
	g.scaleMe(bottomlines[actualimageindex])
	scrollView:insert( bottomlines[actualimageindex] )	
	
	actualimageindex = actualimageindex + 1
	-- arrange image reverse
	-- actualimages[actualimageindex].y = 0
	-- actualimages[actualimageindex].x = 0
	-- arrangeImages()
end


local function loadImages()
	print("loadImages")
	loadingText.isVisible = true
	-- local fname = system.getTimer()
	local fname = crypto.digest( crypto.md5, images[imageindex] )
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
			loadingText.text = "Loading Your Wallet..."
			getMemberProducts()
		elseif "down" == direction then
			loadingText.text = "Loading Your Wallet..."
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
	-- wallet_title.isVisible = false
				
	scrollView2 = widget.newScrollView
	{
		left = 0,
		top = 43+display.topStatusBarContentHeight,
		topPadding = 0,
		bottomPadding = 0,
		width = display.contentWidth,
		height = display.contentHeight-49.5-43-display.topStatusBarContentHeight,
		id = "onBottom1",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
		backgroundColor = { 1, 1, 1 }
	}
	scrollView2.isVisible = false
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
	scrollView2:insert( loadingText2 )
	screenGroup:insert(scrollView)
	screenGroup:insert(wallet_title)
	screenGroup:insert(scrollView2)
	print( "\n1: mywallet createScene event")
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	print( "1: enterScene event" )
	scrollView.isVisible = true
	scrollView2.isVisible = false
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