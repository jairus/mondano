-- require controller module
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local g = require( "mod_globals" )
local json = require "json"
local facebook = require("facebook")

-- configs
-- hide device status bar
display.setStatusBar( display.DefaultStatusBar )
display.setDefault( "background", 255/255, 255/255, 255/255 )
display.setDefault( "anchorX", 0 )
display.setDefault( "anchorY", 0 )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local appId  = "621488324580194"	-- Add  your App ID here (also go into build.settings and replace XXXXXXXXX with your appId under CFBundleURLSchemes)
local apiKey = "603198f8930bd704862c4c8fb5bd2ddd"	-- Not needed at this time
local myText

local function networkloginOrSignup( event )
	if ( event.isError ) then
		myText.text = "No Internet Connection.\nPull down screen to reload."
		noInternet = true
	else
		print ( "RESPONSE: " .. tostring(event.response) )
		local t = json.decode( event.response )
		if t.data.MSG then -- Already a member
			gloggedin = true
			mywalletScreen()
		else 
			profileScreen()
		end 
		myText.text = tostring(event.response)
	end
	--myText.isVisible = true
end

local function loginOrSignup()
	url = "http://www.mondano.sg/api/MembersFreelahs/isMember?fbid="..gfbid
	myText.text = url
	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["XH-MAG-API-KEY"] = "MONDANO-aUHp-9awx@c1yGX580ZmPAkrsUKlucuFH4h"
	local params = {}
	params.headers = headers
	network.request( url, "GET", networkloginOrSignup, params )
	
	
	--[[
	if 1 then -- if not yet registerd
		profileScreen()
	else
		gloggedin = true
		mywalletScreen()
	end
	]]--
end
local function fblistener( event )
	myText.text = "in listener..."
	txtx = "event.token: "..tostring(event.token).."\n"
	txtx = txtx.."event.name: "..tostring(event.name).."\n"
	txtx = txtx.."event.type: "..tostring(event.type).."\n"
	txtx = txtx.."event.isError: "..tostring(event.isError).."\n"
	txtx = txtx.."event.didComplete: "..tostring(event.didComplete).."\n"
	txtx = txtx.."event.phase: "..tostring(event.phase).."\n"
    txtx = txtx.."event.response: "..tostring(event.response).."\n"
	-- myText.text = txtx
	
	if ( "request" == event.type ) then
		local response = tostring(event.response)
		if response then
			myText.text = "error 1"
			response = json.decode( tostring(event.response) )
			myText.text = "error 2"
			txtx = txtx.."response.id: "..tostring(response.id).."\n"
			txtx = txtx.."response.name: "..tostring(response.name).."\n"
			gfbid = response.id
			myText.text = txtx
			myText.text = "loginOrSignup"
			loginOrSignup()
		end
	elseif( "session" == event.type ) then
		if event.token then 
			gtoken = tostring(event.token) -- set gtoken
			facebook.request( "me" ) -- to get id
		else
			dealsScreen()
		end
	end
	
	-- myText.text = txtx
	
end 

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	local options = 
	{
		--parent = textGroup,
		text =  "Sign up / Sign in",     
		x = 100,
		y = 100,
		width = 250,     --required for multi-line and alignment
		font = native.systemFont,   
		fontSize = 16,
		align = "center"  --new alignment parameter
	}
	myText = display.newText( options )
	myText:setFillColor( 81/255, 115/255, 173/255 )
	myText.x = 320/2 - (myText.width/2)
	screenGroup:insert(myText)
	print( "\n1: deals createScene event")
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	--facebook.login( appId, fblistener )
	facebook.login( appId, fblistener, {"publish_actions", "email", "user_birthday"}  )
	myText.text = "Logging in..."
	myText.isVisible = false
	
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