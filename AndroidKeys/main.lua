--libraries
local storyboard = require "storyboard";

--allow access to "global" vars (see globalVars.lua for explanation)
local g = require ("globalVars");

local function onSystemEvent( event )
	if  "applicationExit" == event.type then
		
		--add code here to save your user stats
		print("put a function that saves stats here....")
		
		print("exiting app")
		native.requestExit();
	end 
end
 
Runtime:addEventListener( "system", onSystemEvent );

--------------------------------------------------
--create a software version of the navigation menu 
--(Just so we can navigate on iOS builds and with the Corona simulator)
--------------------------------------------------
local navMenu = display.newGroup();
--Navigation menu button constructor
local function createNavBtn(title)
	local btn = display.newGroup();
	--text
	local txt = display.newText(title,0,0,native.systemFont, 20);
	--background
	local bg = display.newRect(0,0,txt.contentWidth+10,40);
	bg:setFillColor(50,50,100);
	--add to group
	btn:insert(bg);
	btn:insert(txt);
	--add an ID to the button so we can identify it using an event handler function later
	btn.ID = title;
	return btn;
end

local menuBtn = createNavBtn("Menu")
local backBtn = createNavBtn("Back")
local searchBtn = createNavBtn("Search")

menuBtn.x,menuBtn.y = 0,0;
backBtn.x,backBtn.y = menuBtn.x + menuBtn.contentWidth + 10 ,0;
searchBtn.x,searchBtn.y = backBtn.x + backBtn.contentWidth + 10 , 0;
navMenu:insert(menuBtn);
navMenu:insert(backBtn);
navMenu:insert(searchBtn);
--position the navigation menu
navMenu.x,navMenu.y = (display.contentWidth - navMenu.contentWidth)*.5, 50;

--------------------------------------------------
--navigation buttons functions
--------------------------------------------------
g.lastScene = "menu";
local function goToMenuScreen()
	storyboard.gotoScene( "menu" );
end

local function goBack()
	print ("Going back to "..g.lastScene);
	storyboard.gotoScene(g.lastScene);
end

local function performSearch()
	print ("Searching...");
end

--handle my custom nav buttons
local function btnPressed(e)
	local ID = e.target.ID;
	if ID == "Menu" then 
		goToMenuScreen(); 
	elseif ID == "Back" then
		goBack();
	elseif ID == "Search" then
		performSearch();
	end
	return true;
end
--add listeners to our custom software buttons
menuBtn:addEventListener("tap", btnPressed)
backBtn:addEventListener("tap", btnPressed)
searchBtn:addEventListener("tap", btnPressed)

--handle the Android hardware back and menu buttons       
local function onKeyEvent( event )
    local keyname = event.keyName;
    if (event.phase == "up" and (event.keyName=="back" or event.keyName=="menu")) then
            if keyname == "menu" then
            	goToMenuScreen()
            elseif keyname == "back" then
            	goBack();
            elseif keyname == "search" then
            	performSearch();
            end
	end
    return true;
end
 -- Add the key callback
if system.getInfo( "platformName" ) == "Android" then  Runtime:addEventListener( "key", onKeyEvent ) end

--------------------------------------------------
--go to the menu screen - anything above should stay on the screen
--------------------------------------------------
storyboard.gotoScene( "menu" );