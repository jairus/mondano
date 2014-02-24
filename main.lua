-- require controller module
local storyboard = require "storyboard"
local widget = require "widget"
local g = require( "mod_globals" )

-- configs
-- hide device status bar
display.setStatusBar( display.DefaultStatusBar )
display.setDefault( "background", 255/255, 255/255, 255/255 )
display.setDefault( "anchorX", 0 )
display.setDefault( "anchorY", 0 )

-- globals
local gscreen = ""

-----------------------------------------------------------------------------------
function resetTabs()
	mywallet.isVisible = true
	mywallet_b.isVisible = false
	deals.isVisible = true
	deals_b.isVisible = false
	signup.isVisible = true
	signup_b.isVisible = false
	-- profile.isVisible = true
	-- profile_b.isVisible = false
end


-- scene functions
local function dealsScreen(back)
	resetTabs()
	deals_b.isVisible = true;
	if not back then
		table.insert(g.lastScene, "deals") -- push
		print("pushed deals")
	end
	storyboard.gotoScene( "deals" )
end 
local function signupScreen(back)
	resetTabs()
	signup_b.isVisible = true;
	if not back then
		table.insert(g.lastScene, "signup") -- push
		print("pushed signup")
	end
	storyboard.gotoScene( "signup" )
	
end
local function mywalletScreen(back)
	resetTabs()
	mywallet_b.isVisible = true;
	if not back then
		table.insert(g.lastScene, "mywallet") -- push
		print("pushed mywallet")
	end
	storyboard.gotoScene( "mywallet" )
	
end
local function goBack()
	if table.getn(g.lastScene) > 0 then
		lastscene = g.lastScene[table.getn(g.lastScene)]
		table.remove(g.lastScene) -- pop
		print("popped "..lastscene)
		
		lastscene = g.lastScene[table.getn(g.lastScene)]
		if lastscene then
			print ("Going back to "..lastscene);
			if lastscene == "deals" then
				dealsScreen(true)
			elseif lastscene == "signup" then
				signupScreen(true)
			elseif lastscene == "mywallet" then
				mywalletScreen(true)
			end
			
		end
	end
end

-----------------------------------------------------------------------------------
-- START LAYOUT

-- tabs

-- My Wallet
function mywalletTouch( event )
	local object = event.target
	if event.phase == "began" then
		object.began = true
		g.mouseDown(object)
	end
	if event.phase == "moved" then
		g.mouseUp(object)
	end
	if event.phase == "ended" then
		g.mouseUp(object)
		if object.began == true then
			mywalletScreen()
		end
	end
end 
mywallet = display.newImage( "images/tab1_a.png")
mywallet.x = g.leftPos(mywallet)
mywallet.y = g.bottomPos(mywallet)
g.scaleMe(mywallet)
mywallet:addEventListener( "touch", mywalletTouch )
mywallet_b = display.newImage( "images/tab1_b.png")
mywallet_b.x = g.leftPos(mywallet_b)
mywallet_b.y = g.bottomPos(mywallet_b)
g.scaleMe(mywallet_b)
mywallet_b:addEventListener( "touch", mywalletTouch )
mywallet_b.isVisible = false

-- Deals
function dealsTouch( event )
	local object = event.target
	if event.phase == "began" then
		object.began = true
		g.mouseDown(object)
	end
	if event.phase == "moved" then
		g.mouseUp(object)
	end
	if event.phase == "ended" then
		g.mouseUp(object)
		if object.began == true then
			dealsScreen()
		end
	end
end 
deals = display.newImage( "images/tab2_a.png")
deals.x = mywallet.width * g.scale
deals.y = g.bottomPos(deals)
g.scaleMe(deals)
deals:addEventListener( "touch", dealsTouch )
deals_b = display.newImage( "images/tab2_b.png")
deals_b.x = mywallet.width * g.scale
deals_b.y = g.bottomPos(deals_b)
g.scaleMe(deals_b)
deals_b:addEventListener( "touch", dealsTouch )
deals_b.isVisible = false

-- Sign up
function signupTouch( event )
	local object = event.target
	if event.phase == "began" then
		object.began = true
		g.mouseDown(object)
	end
	if event.phase == "moved" then
		g.mouseUp(object)
	end
	if event.phase == "ended" then
		g.mouseUp(object)
		if object.began == true then
			signupScreen()
		end
	end
end
signup = display.newImage( "images/tab3_a.png")
signup.x = (mywallet.width * g.scale) + (deals.width * g.scale)
signup.y = g.bottomPos(signup)
g.scaleMe(signup)
signup:addEventListener( "touch", signupTouch )
signup_b = display.newImage( "images/tab3_b.png")
signup_b.x = (mywallet.width * g.scale) + (deals.width * g.scale)
signup_b.y = g.bottomPos(signup_b)
g.scaleMe(signup_b)
signup_b:addEventListener( "touch", signupTouch )
signup_b.isVisible = false

--login
function loginTouch( event )
	local object = event.target
	if event.phase == "began" then
		object.began = true
		g.mouseDown(object)
	end
	if event.phase == "moved" then
		g.mouseUp(object)
	end
	if event.phase == "ended" then
		g.mouseUp(object)
		if object.began == true then
			-- resetTabs()
			-- signup_b.isVisible = true;
			signupScreen()
			--goBack()
		end
	end
end
login = display.newImage( "images/login.png")
login.x = g.leftPos(login)
login.y = g.topPos(login)
g.scaleMe(login)
login:addEventListener( "touch", loginTouch )
login_b = display.newImage( "images/login_b.png")
login_b.x = g.leftPos(login_b)
login_b.y = g.topPos(login_b)
g.scaleMe(login_b)
login_b.isVisible = false

logo = display.newImage( "images/logo.png")
logo.x = login.width * g.scale
logo.y = g.topPos(logo)
g.scaleMe(logo)

-- default call
resetTabs()
deals_b.isVisible = true;
dealsScreen()
--mywalletScreen()

local function onKeyEvent( event )
    local keyname = event.keyName;
    if (event.phase == "up" and (event.keyName=="back" or event.keyName=="menu")) then
            if keyname == "menu" then
            	-- goToMenuScreen()
            elseif keyname == "back" then
            	goBack();
            elseif keyname == "search" then
            	-- performSearch();
            end
	end
    return true;
end
 --add the runtime event listener
if system.getInfo( "platformName" ) == "Android" then  Runtime:addEventListener( "key", onKeyEvent ) end



			
-- arrangements
local display_stage = display.getCurrentStage()
display_stage:insert( mywallet )
display_stage:insert( mywallet_b )
display_stage:insert( deals )
display_stage:insert( deals_b )
display_stage:insert( signup )
display_stage:insert( signup_b )
display_stage:insert( login )
display_stage:insert( login_b )