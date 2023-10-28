--@name hitbox lib
--@author Elias
--@client

hitboxes=class("hitboxes")
_hitboxes={}

cursorFunc=function()
    local x,y=render.cursorPos()
    return Vector(x,y)
end

function hitboxes.create(layer,id,x,y,w,h,callback,hover,renderFunc)
    if !_hitboxes[layer] then
        _hitboxes[layer]={}
    end
    
    if _hitboxes[layer][id] then
        if hover and _hitboxes[layer][id].hover then
            hover()
        end
        
        if renderFunc then
            renderFunc(x,y,w,h)
        end
        
        return
    end
    
    _hitboxes[layer][id]={
        x=x,
        y=y,
        w=w,
        h=h,
        callback=callback,
        hover=false
    }
end

function hitboxes.each(_hitboxes,func)
    for i,layer in pairs(_hitboxes) do
        for id,hitbox in pairs(layer) do
            func(i,id,hitbox)
        end
    end
end

function hitboxes.edit(layer,id,x,y,w,h,callback)
    local hitbox=_hitboxes[layer][id]
    
    _hitboxes[layer][id]={
        x=x or hitbox.x,
        y=y or hitbox.y,
        w=w or hitbox.w,
        h=h or hitbox.h,
        callback=callback or hitbox.callback,
        hover=false
    }
end

function hitboxes.remove(layer,id)
    hook.remove("inputPressed","hitId_"..i..";"..id)

    _hitboxes[layer][id]=nil
end

function hitboxes.clear(layer)
    for id,hitbox in pairs(_hitboxes[layer]) do
        hook.remove("inputPressed","hitId_"..layer..";"..id)
    end

    hitboxes.each(_hitboxes,function(i,id,hitbox)
    end

    _hitboxes[layer]=nil
end

function hitboxes.renderDebug()
    hitboxes.each(_hitboxes,function(i,id,hitbox)
        render.setColor(Color((i/4)*((id*20)+timer.realtime()*20),1,1):hsvToRGB())
        
        render.drawRectOutline(hitbox.x,hitbox.y,hitbox.w,hitbox.h)
    end)
end

hook.add("render","cl_hitboxes",function()
    cursor=cursorFunc()
    
    if hitboxes.debug then
        hitboxes.renderDebug()
    end
end)

hook.add("think","cl_hitboxes",function()
    local _hitboxes=table.reverse(_hitboxes)
    local curLayer=nil
    
    hitboxes.each(_hitboxes,function(i,id,hitbox)
        if curLayer and curLayer!=i then
            hitboxes.each(_hitboxes,function(i,id,hitbox)
                if curLayer<i then
                    hook.remove("inputPressed","hitId_"..i..";"..id)
                            
                    hitbox.hover=false
                end
            end)
            
            return
        end
            
        if (cursor or Vector()):withinAABox(Vector(hitbox.x,hitbox.y),Vector(hitbox.x+hitbox.w,hitbox.y+hitbox.h)) then
            curLayer=i
            
            if !hitbox.hover then
                hitbox.hover=true

                if hitbox.callback then
                    hook.add("inputPressed","hitId_"..i..";"..id,function(key)
                        hitbox.callback(key,cursor)
                    end)
                end
            end
        else
            if hitbox.hover then
                hitbox.hover=false
                
                hook.remove("inputPressed","hitId_"..i..";"..id)
            end
        end
        
    end)
end)