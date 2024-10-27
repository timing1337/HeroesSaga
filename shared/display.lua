--[[--
    display
]]

--[[----

The display module provides access to cocos2d-x core features.

-   Query display screen information.
-   Mange scenes.
-   Creates display objects.

]]

local display = {}

local sharedDirector         = CCDirector:sharedDirector()
local sharedTextureCache     = CCTextureCache:sharedTextureCache()
local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()

display.contentScaleFactor = sharedDirector:getContentScaleFactor();

display.SCENE_TRANSITIONS = {
    CROSSFADE       = {CCTransitionCrossFade, 2},
    FADE            = {CCTransitionFade, 3, ccc3(0, 0, 0)},
    FADEBL          = {CCTransitionFadeBL, 2},
    FADEDOWN        = {CCTransitionFadeDown, 2},
    FADETR          = {CCTransitionFadeTR, 2},
    FADEUP          = {CCTransitionFadeUp, 2},
    FLIPANGULAR     = {CCTransitionFlipAngular, 3, kCCTransitionOrientationLeftOver},
    FLIPX           = {CCTransitionFlipX, 3, kCCTransitionOrientationLeftOver},
    FLIPY           = {CCTransitionFlipY, 3, kCCTransitionOrientationUpOver},
    JUMPZOOM        = {CCTransitionJumpZoom, 2},
    MOVEINB         = {CCTransitionMoveInB, 2},
    MOVEINL         = {CCTransitionMoveInL, 2},
    MOVEINR         = {CCTransitionMoveInR, 2},
    MOVEINT         = {CCTransitionMoveInT, 2},
    PAGETURN        = {CCTransitionPageTurn, 3, false},
    ROTOZOOM        = {CCTransitionRotoZoom, 2},
    SHRINKGROW      = {CCTransitionShrinkGrow, 2},
    SLIDEINB        = {CCTransitionSlideInB, 2},
    SLIDEINL        = {CCTransitionSlideInL, 2},
    SLIDEINR        = {CCTransitionSlideInR, 2},
    SLIDEINT        = {CCTransitionSlideInT, 2},
    SPLITCOLS       = {CCTransitionSplitCols, 2},
    SPLITROWS       = {CCTransitionSplitRows, 2},
    TURNOFFTILES    = {CCTransitionTurnOffTiles, 2},
    ZOOMFLIPANGULAR = {CCTransitionZoomFlipAngular, 2},
    ZOOMFLIPX       = {CCTransitionZoomFlipX, 3, kCCTransitionOrientationLeftOver},
    ZOOMFLIPY       = {CCTransitionZoomFlipY, 3, kCCTransitionOrientationUpOver},
}

--[[----

]]
function display.wrapSceneWithTransition(scene, transitionType, time, more)
    local key = string.upper(tostring(transitionType))
    if string.sub(key, 1, 12) == "CCTRANSITION" then
        key = string.sub(key, 13)
    end

    if key == "RANDOM" then
        local keys = table.keys(display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if display.SCENE_TRANSITIONS[key] then
        local cls, count, default = unpack(display.SCENE_TRANSITIONS[key])
        time = time or 0.2

        if count == 3 then
            scene = cls:create(time, scene, more or default)
        else
            scene = cls:create(time, scene)
        end
    else
        echoError("display.wrapSceneWithTransition() - invalid transitionType %s", tostring(transitionType))
    end
    return scene
end

--[[----

Replaces the running scene with a new one.

### Example:

    display.replaceScene(scene1)
    display.replaceScene(scene2, "CROSSFADE", 0.5)
    display.replaceScene(scene3, "FADE", 0.5, ccc3(255, 255, 255))

### Parameters:

-   CCScene **newScene** scene of want to display

-   [_optional string **transitionType**_] is one of the following:

    Transition Type             | Note
    --------------------------- | -------------------
    CROSSFADE       | Cross fades two scenes using the CCRenderTexture object
    FADE            | Fade out the outgoing scene and then fade in the incoming scene
    FADEBL          | Fade the tiles of the outgoing scene from the top-right corner to the bottom-left corner
    FADEDOWN        | Fade the tiles of the outgoing scene from the top to the bottom
    FADETR          | Fade the tiles of the outgoing scene from the left-bottom corner the to top-right corner
    FADEUP          | Fade the tiles of the outgoing scene from the bottom to the top
    FLIPANGULAR     | Flips the screen half horizontally and half vertically
    FLIPX           | Flips the screen horizontally
    FLIPY           | Flips the screen vertically
    JUMPZOOM        | Zoom out and jump the outgoing scene, and then jump and zoom in the incoming
    MOVEINB         | Move in from to the bottom the incoming scene
    MOVEINL         | Move in from to the left the incoming scene
    MOVEINR         | Move in from to the right the incoming scene
    MOVEINT         | Move in from to the top the incoming scene
    PAGETURN        | A transition which peels back the bottom right hand corner of a scene to transition to the scene beneath it simulating a page turn
    ROTOZOOM        | Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming
    SHRINKGROW      | Shrink the outgoing scene while grow the incoming scene
    SLIDEINB        | Slide in the incoming scene from the bottom border
    SLIDEINL        | Slide in the incoming scene from the left border
    SLIDEINR        | Slide in the incoming scene from the right border
    SLIDEINT        | Slide in the incoming scene from the top border
    SPLITCOLS       | The odd columns goes upwards while the even columns goes downwards
    SPLITROWS       | The odd rows goes to the left while the even rows goes to the right
    TURNOFFTILES    | Turn off the tiles of the outgoing scene in random order
    ZOOMFLIPANGULAR | Flips the screen half horizontally and half vertically doing a little zooming out/in
    ZOOMFLIPX       | Flips the screen horizontally doing a zoom out/in The front face is the outgoing scene and the back face is the incoming scene
    ZOOMFLIPY       | Flips the screen vertically doing a little zooming out/in The front face is the outgoing scene and the back face is the incoming scene

-   [_optional float **time**_] duration of the transition

-   [_optional mixed **more**_] parameter for the transition

]]
function display.replaceScene(newScene, transitionType, time, more)
    if sharedDirector:getRunningScene() then
        if transitionType then
            newScene = display.wrapSceneWithTransition(newScene, transitionType, time, more)
        end
        sharedDirector:replaceScene(newScene)
    else
        sharedDirector:runWithScene(newScene)
    end
end

--[[----

Get current running scene.

### Returns:

-   CCScene

]]
function display.getRunningScene()
    return sharedDirector:getRunningScene()
end

--[[----

Pauses the running scene.

]]
function display.pause()
    sharedDirector:pause()
end

--[[----

Resumes the paused scene.

]]
function display.resume()
    sharedDirector:resume()
end


function display.removeSpriteFramesWithFile(plistFilename, imageName)
    sharedSpriteFrameCache:removeSpriteFramesFromFile(plistFilename)
    if imageName then
        display.removeSpriteFrameByImageName(imageName)
    end
end

--[[----

]]
function display.removeSpriteFrameByImageName(imageName)
    sharedSpriteFrameCache:removeSpriteFrameByName(imageName)
    CCTextureCache:sharedTextureCache():removeTextureForKey(imageName)
end

--[[----

Creates CCSpriteBatchNode object from an image.

CCSpriteBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call (often known as "batch draw").

A CCSpriteBatchNode can reference one and only one texture (one image file, one texture atlas). Only the CCSprites that are contained in that texture can be added to the CCSpriteBatchNode. All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call. If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.

Limitations:

-   The only object that is accepted as child (or grandchild, grand-grandchild, etc...) is CCSprite or any subclass of CCSprite. eg: particles, labels and layer can't be added to a CCSpriteBatchNode.
-   Either all its children are Aliased or Antialiased. It can't be a mix. This is because "alias" is a property of the texture, and all the sprites share the same texture.

### Example:

    local imageName = "sprites.png"
    display.addSpriteFramesWithFile("sprites.plist", imageName) -- load sprite frames

    -- it will draw them in 1 single OpenGL call
    local batch = display.newBatch(imageName)
    for i = 1, 100 do
        local sprite = display.newSprite("#sprite0001.png")
        batch:addChild(sprite)
    end

    --

    -- it will draw them use 100 OpenGL call
    local group = display.newNode()
    for i = 1, 100 do
        local sprite = display.newSprite("#sprite0001.png")
        group:addChild(sprite)
    end

### Parameters:

-   string **image** filename of image

-   [_optional int **capacity**_] estimated capacity of batch

### Returns:

-   CCSpriteBatchNode

]]
function display.newBatchNode(image, capacity)
    return CCNodeExtend.extend(CCSpriteBatchNode:create(image, capacity or 29))
end

--[[----

Returns an Sprite Frame that was previously added.

### Example:

    display.addSpriteFramesWithFile("sprites.plist", "sprites.png")
    local sprite = display.newSprite("#sprite0001")

    local frame2 = display.newSpriteFrame("sprite0002.png")
    local frame3 = display.newSpriteFrame("sprite0003.png")

    ....

    sprite:setDisplayFrame(frame2)  -- change sprite texture without recreate
    -- or
    sprite:setDisplayFrame(frame3)

### Parameters:

-   string **frameName** name of sprite frame, without prefix character '#'.

### Returns:

-   CCSpriteFrame

]]
function display.newSpriteFrame(frameName)
    local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
    if not frame then
        echoError("display.newSpriteFrame() - invalid frame, name %s", tostring(frameName))
    end
    return frame
end

--[[----



### Example:

### Parameters:

### Returns:

]]
function display.newSpriteWithFrame(frame, x, y)
    local sprite = CCSprite:createWithSpriteFrame(frame)
    if sprite then CCSpriteExtend.extend(sprite) end
    if x and y then sprite:setPosition(x, y) end
    return sprite
end

--[[----

Creates multiple frames by pattern.

### Example:

    -- create array of CCSpriteFrame [walk0001.png -> walk0020.png]
    local frames = display.newFrames("walk%04d.png", 1, 20)

### Parameters:

-   string **pattern**

-   int **begin**

-   int **length**

-   [_optional bool **isReversed**_]

### Returns:

-   table

]]
function display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
        if not frame then
            echoError("display.newFrames() - invalid frame, name %s", tostring(frameName))
            return
        end

        frames[#frames + 1] = frame
    end
    return frames
end

--[[----

create animation

### Example:

    display.newAnimation(frames, time)

### Example:

    local frames    = display.newFrames("walk_%02d.png", 1, 20)
    local animation = display.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames

]]
function display.newAnimation(frames, time)
    local count = #frames
    local array = CCArray:create()
    for i = 1, count do
        array:addObject(frames[i])
    end
    time = time or 1.0 / countinsta
    return CCAnimation:createWithSpriteFrames(array, time)
end

--[[--

create animate

### Example:

    display.newAnimate(animation, isRestoreOriginalFrame)

### Example:

    local frames = display.newFrames("walk_%02d.png", 1, 20)
    local sprite = display.newSpriteWithFrame(frames[1])

    local animation = display.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames
    local animate = display.newAnimate(animation)

]]
function display.newAnimate(animation)
    return CCAnimate:create(animation)
end

return display
