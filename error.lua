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
	myText.text = "Trying again..."
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


local function shareButtonTouch( event )
	print("shareButtonTouch")
	local object = event.target
	if event.phase == "began" then
	end
	if ( event.phase == "moved" ) then
	end
	if event.phase == "ended" then
		print("shareButtonTouch")
		claimOffer()
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
	
	sww = display.newImage( "images/something_went_wrong.png")
	sww.x = g.centerPos(sww)
	sww.y = 100
	g.scaleMe(sww)
	screenGroup:insert(sww)

	local options = 
	{
		--parent = textGroup,
		text =  gerrormessage,     
		x = 100,
		y = sww.y+sww.height,
		width = 250,     --required for multi-line and alignment
		font = native.systemFont,   
		fontSize = 16,
		align = "center"  --new alignment parameter
	}
	myText = display.newText( options )
	myText:setFillColor( 81/255, 115/255, 173/115 )
	myText.x = 320/2 - (myText.width/2)
	screenGroup:insert(myText)
	
	
	local shareButton = widget.newButton
	{
		top = myText.y+myText.height+50,
		left = 15,
		id = "button",
		defaultFile = "images/ok_try_again.png",
		onEvent = shareButtonTouch
	}
	g.scaleMe(shareButton)
	screenGroup:insert( shareButton )
	
	local cancelButton = widget.newButton
	{
		top = myText.y+myText.height+50,
		left =30+(shareButton.width/2),
		id = "button",
		defaultFile = "images/cancel.png",
		onEvent = cancelButtonTouch
	}
	g.scaleMe(cancelButton)
	screenGroup:insert( cancelButton )
	
	
	
	print( "\n1: deals createScene event")
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	print( "1: enterScene event" )
	myText.text = gerrormessage
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