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
local top = 10
local left = 10
local screenGroup
local scrollView
local myText
local loadingText = display.newText("Loading...", 10, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 81/255, 115/255, 173/255 )
local actualimage
local instructions
local shareButton
local cancelButton

local function networkListenerClaimOffer(event)
	if ( event.isError ) then
		loadingText.text = "No Internet Connection.\nPull down screen to reload."
	else
		print("-------------------------------------\n\n\n")
		print(event.response)
		local t = json.decode( event.response )
		local status = tostring(t.Status)
		local errormessage = tostring(t.error.ERR_MSG)
		print(status.."<->"..errormessage)
		if status == "false" then
			gerrormessage = errormessage
			errorScreen()
		else 
			claimSuccessScreen()
		end
	end

end
local function claimOffer() --1st step is get the offers
	print("claimOffer")
	-- loadingText.text = "loaded"
	url = "http://mondano.sg/api/membersProducts/claim/?".."fb_id="..gfbid.."&product_id="..gproducts[gproductindex].product_id.."&access_token="..gtoken
	print(url)
	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
	local params = {}
	params.headers = headers
	-- local body = { fb_id = "112123", product_id = "1" }
	-- local body = "fb_id="..gfbid.."&product_id="..gproducts[gproductindex].product_id
	-- local body = "fb_id=100006286952227&product_id=1"
	-- local body = "language=en&apikey=yourapikeynoquotes"
	-- params.body = body
	-- print(params.body)
	network.request( url, "GET", networkListenerClaimOffer, params )
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
	
	-- text
	local options = 
	{
		--parent = textGroup,
		text = "When you claim this offer, you will share it on your Facebook Timeline so that your friends can learn about it as well. Click the button below to get the offer.",     
		x = 10,
		y = top,
		width = display.contentWidth-20,     --required for multi-line and alignment
		font = native.systemFont,   
		fontSize = 16,
		align = "left"  --new alignment parameter
	}
	instructions = display.newText( options )
	instructions:setFillColor( 81/255, 115/255, 173/255 )
	scrollView:insert( instructions )
	
	
	screenGroup:insert(scrollView)
	print( "\n1: deals createScene event")
end

local function shareButtonTouch( event )
	print("shareButtonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	end
	if event.phase == "ended" then
		print("shareButtonTouch")
		claimOffer()
	end
end

local function cancelButtonTouch( event )
	print("shareButtonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	end
	if event.phase == "ended" then
		print("cancelButton")
		productScreen()
	end
end

local function loadActualImage()
	
	-- the image
	width = actualimage.width
	height = actualimage.height
	actualimage.width = 300
	actualimage.height = 300/width*height
	-- g.scaleMe(actualimage)
	actualimage.y = (top + instructions.height + 40)
	actualimage.x = left
	scrollView:insert( actualimage )	
	actualimage.isVisible = true
	scrollView:insert( actualimage )
	
	-- share button
	shareButton = widget.newButton
	{
		left = left+5,
		top = (top + actualimage.height + 30 + instructions.height + 40),
		id = "button",
		defaultFile = "images/share_button.png",
		onEvent = shareButtonTouch
	}
	g.scaleMe(shareButton)
	scrollView:insert( shareButton )
	
	-- cancel button
	cancelButton = widget.newButton
	{
		left = left + ( shareButton.width / 2) + 15 ,
		top = (top + actualimage.height + 30 + instructions.height + 40),
		id = "button",
		defaultFile = "images/cancel.png",
		onEvent = cancelButtonTouch
	}
	g.scaleMe(cancelButton)
	scrollView:insert( cancelButton )
	
end

local function networkListener( event )
	if ( event.isError ) then
		print ( "Network error - download failed" )
		dealsScreen()
	else
		event.target.alpha = 0
		transition.to( event.target, { alpha = 1.0 } )
	end
	loadingText.text = ""
	print ( "RESPONSE: ", event.response.filename )
	actualimage = event.target
	loadActualImage()
	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	top = 0
	if actualimage then
		actualimage.isVisible = false
	end
	loadingText.text = "Loading Image..."
	loadingText.y = 175
	-- myText.text = gproducts[gproductindex].prodDetail
	-- print(gproductindex.."  -- "..gproducts[gproductindex].prodDetail)
	fname = crypto.digest( crypto.md5, gproducts[gproductindex].image )
	local imagepath = system.pathForFile( fname..".png", system.TemporaryDirectory )
	imagepath = string.gsub(imagepath, "\\", "/")
	actualimage = display.newImage( imagepath )
	if actualimage then
		loadActualImage()
	else
		err = pcall(
			function()
				image = display.loadRemoteImage( 
					gproducts[gproductindex].image, 
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