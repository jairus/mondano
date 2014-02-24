--  Globals Module mod_globals.lua
local this = {}
 
-- Some pre-defined globals
this.scale = 0.5 --high res

this.lastScene = {}

-- extra functions
local function scaleHeight(obj)
	val = obj.height * this.scale
	return val
end
this.scaleHeight = scaleHeight

local function scaleWidth(obj)
	val = obj.width * this.scale
	return val
end 
this.scaleWidth = scaleWidth

local function scaleMe(obj)
	obj:scale(this.scale, this.scale)
end
this.scaleMe = scaleMe

local function topPos(obj)
	return 0
end
this.topPos = topPos

local function middlePos(obj)
	pos = display.contentHeight / 2
	pos = pos - (scaleHeight(obj) / 2)
	return pos
end
this.middlePos = middlePos

local function bottomPos(obj)
	pos = display.contentHeight - scaleHeight(obj)
	return pos
end
this.bottomPos = bottomPos

local function leftPos(obj)
	return 0
end
this.leftPos = leftPos

local function centerPos(obj)
	pos = display.contentWidth / 2
	pos = pos - (scaleWidth(obj) / 2)
	return pos
end
this.centerPos = centerPos

local function rightPos(obj)
	pos = display.contentWidth - scaleWidth(obj)
	return pos
end
this.rightPos = rightPos
 
local function mouseDown(object)
	object.alpha = 0.9;
	-- object.x = object.x + 1;
	-- object.y = object.y + 1;
end
this.mouseDown = mouseDown

local function mouseUp(object)
	object.alpha = 1;
	-- object.x = object.x - 1;
	-- object.y = object.y - 1;
end
this.mouseUp = mouseUp

local function bounceY(obj)
	pos = obj.y
	t = 50
	transition.to( obj, { time=t, delay=0, alpha=1.0, y = pos-3 })
	transition.to( obj, { time=t, delay=t, alpha=1.0, y = pos+3 })
	transition.to( obj, { time=t, delay=t*2, alpha=1.0, y = pos })
end
this.bounceY = bounceY

local function bounceRand(obj)
	posY = obj.y
	posX = obj.x
	w = obj.width
	h = obj.height
	wp = obj.width  * this.scale * 0.20
	hp = obj.height  * this.scale * 0.20
	obj.width = obj.width + wp
	obj.height = obj.height + hp
	obj.x = obj.x - wp / 4
	obj.y = obj.y - hp / 4
	t = 20
	transition.to( obj, { time=t, delay=t*0, alpha=1.0, width = w, height = h, x = posX, y = posY })
	pix = 1
	nx = math.random(pix*-1, pix)
	ny = math.random(pix*-1, pix)
	transition.to( obj, { time=t, delay=t*1, alpha=1.0, x = posX+nx, y = posY+ny })
	nx = math.random(pix*-1, pix)
	ny = math.random(pix*-1, pix)
	transition.to( obj, { time=t, delay=t*2, alpha=1.0, x = posX+nx, y = posY+ny })
	nx = math.random(pix*-1, pix)
	ny = math.random(pix*-1, pix)
	transition.to( obj, { time=t, delay=t*3, alpha=1.0, x = posX+nx, y = posY+ny })
	transition.to( obj, { time=t, delay=t*4, alpha=1.0, x = posX, y = posY })

end
this.bounceRand = bounceRand

local function slideDown(obj, speed, delay)
	obj.isVisible = true
	if speed == nil then
		speed = 200
	end
	if delay == nil then
		delay = 0
	end
	if bounce == nil then
		bounce = true
	end
	pos = obj.y
	obj.alpha = 0
	obj.y = obj.height / 2 * -1
	
	if bounce == true then
		transition.to( obj, { time=speed, delay=delay, alpha=1.0, y = pos, onComplete=bounceY })
	elseif bounce == false then
		transition.to( obj, { time=speed, delay=delay, alpha=1.0, y = pos })
	end
end
this.slideDown = slideDown

local function explode(obj, speed, delay, bounce)
	obj.isVisible = true
	if speed == nil then
		speed = 200
	end
	if delay == nil then
		delay = 0
	end
	if bounce == nil then
		bounce = false
	end
	
	origWidth = obj.width
	origHeight = obj.height
	width = scaleWidth(obj)
	height = scaleHeight(obj)
	x = obj.x
	y = obj.y
	
	obj.alpha = 0
	obj.anchorX = 0.5
	obj.anchorY = 0.5
	obj.x = obj.x + width / 2
	obj.y = obj.y + height / 2
	obj.width = 0
	obj.height = 0

	if bounce == false then
		transition.to( obj, { time=speed, delay=delay, alpha=1.0, width = origWidth, height = origHeight})
		transition.to( obj, { time=1, delay=(speed+delay), anchorX=0, anchorY=0, x=x, y=y })
	else
		transition.to( obj, { time=speed, delay=delay, alpha=1.0, width = origWidth, height = origHeight})
		transition.to( obj, { time=1, delay=(speed+delay), anchorX=0, anchorY=0, x=x, y=y, onComplete=bounceRand })
	end
end
this.explode = explode

local function fadeIn(obj, speed, delay)
	obj.isVisible = true
	if speed == nil then
		speed = 200
	end
	if delay == nil then
		delay = 0
	end
	obj.alpha = 0
	transition.to( obj, { time=speed, delay=delay, alpha=1.0})
end
this.fadeIn = fadeIn




-- Return globals module
return this