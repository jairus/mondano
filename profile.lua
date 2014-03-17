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
local loadingText = display.newText("Loading ...", 10, top, display.contentWidth-20, 0, native.systemFont, 16)
loadingText:setFillColor( 81/255, 115/255, 173/255 )
local actualimage

local isAndroid = "Android" == system.getInfo( "platformName" )
local inputFontSize = 18
local tHeight = 30

if ( isAndroid or 1 ) then
    inputFontSize = inputFontSize - 4
    tHeight = tHeight + 10
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

local function popuplistener( event )
    local shouldLoad = true
    local url = event.url
	loadingText.text = url
    if nil ~= string.find( url, "successclosecorona" ) then
        -- Close the web popup
		gloggedin = true
		shouldLoad = false
		timer.performWithDelay( 500, mywalletScreen, 1 )
    end
	
	if nil ~= string.find( url, "closecorona" ) then
        -- Close the web popup
		shouldLoad = false
    end

    if event.errorCode then
        -- Error loading page
        print( "Error: " .. tostring( event.errorMessage ) )
        shouldLoad = false
    end
	
    return shouldLoad
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	screenGroup = self.view
	--[[
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
	
	
	
	
	
	profile = display.newImage( "images/profile_form.png")
	profile.x = 0
	profile.y = 0
	g.scaleMe(profile)
	scrollView:insert( profile )
	
	-- first name
	firstname = native.newTextField( 148, 80, 130, tHeight )
	firstname.font = native.newFont( native.systemFontBold, inputFontSize )	
	firstname.hasBackground = false
	firstname.text = "Please enter"
	firstname:addEventListener( "userInput", textListener )
	scrollView:insert( firstname )
	-- last name
	lastname = native.newTextField( 148, 80+30, 130, tHeight )
	lastname.font = native.newFont( native.systemFontBold, inputFontSize )	
	lastname.hasBackground = false
	lastname.text = "Please enter"
	lastname:addEventListener( "userInput", textListener )
	scrollView:insert( lastname )
	
	local webView = native.newWebView( display.contentCenterX, display.contentCenterY, 320, 480 )
	webView:request( "http://www.coronalabs.com/" )
	scrollView:insert( webView )
	
	scrollView:insert( loadingText )
	screenGroup:insert(scrollView)
	print( "\n1: deals createScene event")
	
	popup = native.showWebPopup( 0, 
	43+display.topStatusBarContentHeight, 
	display.contentWidth, 
	display.contentHeight-49.5-43-display.topStatusBarContentHeight, 
	"http://e27.co" )
	
	]]--
	
	
	screenGroup:insert( loadingText )
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	local options =
	{
		hasBackground=false,
		urlRequest=popuplistener
	}
	local popurl = "";
	if gloggedin == false then
		popurl = "http://www.mondano.sg/signup_form.php?_"..tostring(system.getTimer()).."&gtoken="..gtoken
	else
		popurl = "http://www.mondano.sg/signup_form.php?_"..tostring(system.getTimer()).."&gtoken="..gtoken.."&gfbid="..gfbid
	end
	native.showWebPopup( 0, 
		50+display.topStatusBarContentHeight, -- 43+display.topStatusBarContentHeight, 
		display.contentWidth, 
		display.contentHeight-53.5-43-display.topStatusBarContentHeight, --display.contentHeight-49.5-43-display.topStatusBarContentHeight, 
		popurl,
		options
	)
	loadingText.y = 320 + 20
	loadingText.isVisible = false
		
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