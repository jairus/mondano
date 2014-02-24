local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
 
----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

--forward declarations
local scene1Btn = display.newGroup();
local scene2Btn = display.newGroup();
local scene3Btn = display.newGroup();

-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view
 
        -----------------------------------------------------------------------------
                
        --      CREATE display objects and add them to 'group' here.
        --      Example use-case: Restore 'group' from previously saved state.
        
        -----------------------------------------------------------------------------
        -------------------------
        --create the scene menu objects (title + 3 buttons)
        -------------------------
        local padding = 30;
        local menuGroup = display.newGroup();
        local title = display.newText("Menu",0,0,native.systemFont, 20);
        title.x , title.y = 0,0;
        menuGroup:insert(title);
        
        --button to link to scene 1
        menuGroup:insert(scene1Btn);
        scene1Btn.bg = display.newRect(scene1Btn,0,0,100,20);
        scene1Btn.bg:setFillColor(50,50,50)
        scene1Btn.txt = display.newText(scene1Btn,"Scene 1",0,0,native.systemFont, 20);
        scene1Btn.x,scene1Btn.y = 0 , title.y + padding;
        
        --button to link to scene 2
        menuGroup:insert(scene2Btn);
        scene2Btn.bg = display.newRect(scene2Btn,0,0,100,20);
        scene2Btn.bg:setFillColor(50,50,50)
        scene2Btn.txt = display.newText(scene2Btn,"Scene 2",0,0,native.systemFont, 20);
        scene2Btn.x,scene2Btn.y = 0 , scene1Btn.y + padding;
        
        --button to link to scene 3
        menuGroup:insert(scene3Btn);
        scene3Btn.bg = display.newRect(scene3Btn,0,0,100,20);
        scene3Btn.bg:setFillColor(50,50,50)
        scene3Btn.txt = display.newText(scene3Btn,"Scene 3",0,0,native.systemFont, 20);
        scene3Btn.x,scene3Btn.y = 0 , scene2Btn.y + padding;
        
        --assign screen names to each button (so the event handler later can tell where each button is directing to)
        scene1Btn.pointTo = "scene1";
        scene2Btn.pointTo = "scene2";
        scene3Btn.pointTo = "scene3";
        
        --position the menu group
        menuGroup.x,menuGroup.y = display.contentWidth*.5,display.contentHeight*.5;
        group:insert(menuGroup);
        
        
        
        
end
 
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
                
        --      INSERT code here (e.g. start timers, load audio, start listeners, etc.)
        
        -----------------------------------------------------------------------------

        -------------------------
    	--event functions
        -------------------------
        local function buttonClicked(e)
        	local sceneNameToGoTo = e.target.pointTo
        	print("you clicked "..sceneNameToGoTo);
        	--goto scene
        	storyboard.gotoScene( sceneNameToGoTo );
        	return true;
        end
        
        scene1Btn:addEventListener("tap", buttonClicked);
        scene2Btn:addEventListener("tap", buttonClicked);
        scene3Btn:addEventListener("tap", buttonClicked);
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
        
        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
        
        -----------------------------------------------------------------------------
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
        
        --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)
        
        -----------------------------------------------------------------------------
        
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
