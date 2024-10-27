

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--- Create an class.
function class(classname, super , ...)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end

        for k,v in pairs(arg) do
            if(k~='n')then
                for fn,ft in pairs(v) do
                    if (type(ft)=="function") then
                        cls[fn] = ft;
                    end
                end
            end
        end

        if(arg~=nil)then
            for k,v in pairs(arg) do
                if(k~='n')then
                    for fn,ft in pairs(v) do
                        if (type(ft)=="function") then
                            cls[fn] = ft;
                        end
                    end
                end
            end
        end

        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls[super.__cname] = super
        else
            cls = {ctor = function() end}
        end

        if(arg~=nil)then
            for k,v in pairs(arg) do
                if(k~='n')then
                    for fn,ft in pairs(v) do
                        if (type(ft)=="function") then
                            cls[fn] = ft;
                        end
                    end
                end
            end
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end



-- Create a interface
--[[
    interface is nil table
    it only have function with interface,
    the function mast be implementation at child class
    
]]
function interface(  )
    -- body
    return {};
end



function schedule(node, callback, delay)
    local delay = CCDelayTime:create(delay)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    local action = CCRepeatForever:create(sequence)
    node:runAction(action)
    return action
end
--[[--
    延迟回调
]]
function performOtherWithDelay(node, callback, time)
    --cclog("performOtherWithDelay11111")
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(time * public_config.action_rythm));
    animArr:addObject(CCCallFunc:create(callback));
    local sequence = CCSequence:create(animArr)
    node:runAction(sequence);
    --cclog("performOtherWithDelay22222")
    return sequence
end

function performWithDelay(node, callback, time)
    --[[if time <= 0.000001 then
        callback()
        return nil
    end]]--
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(time * public_config.action_rythm));
    animArr:addObject(CCCallFunc:create(callback));
    local sequence = CCSequence:create(animArr)
    node:runAction(sequence);
    return sequence
end

function performWithMove(node, callback, time ,pos)
    local moveaction = CCMoveTo:create(time * public_config.action_rythm,pos)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(moveaction, callfunc)
    node:runAction(sequence)
    return sequence
end

function performWithJump(node, callback, time ,pos,height)
    local moveaction = CCJumpTo:create(time * public_config.action_rythm,pos,height,1)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(moveaction, callfunc)
    node:runAction(sequence)
    return sequence
end

function performWithScale(node, callback, time ,scaleX,scaleY)
    local scaleaction = CCScaleTo:create(time * public_config.action_rythm,scaleX,scaleY)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(scaleaction, callfunc)
    node:runAction(sequence)
    return sequence
end

function performWithFade(node, callback, time ,mtype)
    local fadeaction;
    if(mtype == 0) then
        fadeaction = CCFadeIn:create(time * public_config.action_rythm)
    elseif(mtype == 1) then
        fadeaction = CCFadeOut:create(time * public_config.action_rythm)
    else
        return performWithDelay(node, callback, time)
    end
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(fadeaction, callfunc)
    node:runAction(sequence)
    return sequence
end

function getActionPerformTime(frames)
    return frames * public_config.anim_durition
end