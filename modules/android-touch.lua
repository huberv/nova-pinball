local touch = {}

-- Customize button colors
touch.colors = {}
touch.colors.fill = {0, 200, 100, 200}
touch.colors.border = {200, 255, 255, 200}
touch.colors.font = {255, 255, 255, 200}
touch.colors.tint = {200, 255, 200, 128}

-- Remember the last key down
touch.lastkey = nil

-- Limit touch rate
touch.cooldown = 0.15
touch.cooldownvalue = touch.cooldown

-- A zone is a state when to show a button.
touch.zones = {}

-- Add a button to a zone, it's title, position and the key
-- it bubbles to love.keypressed/keyreleased.
-- Position is given as a table of percentages to the display size
-- as top, left, bottom, right values:
--      { top=10, left=10, bottom=15, right=15 }
--  (A button 10% top-left and 15% bottom-right of the device size)
function touch.add(self, zone, key, title, position, image, func, params)
    
    if not self.zones[zone] then
        -- Set up a new zone collection
        self.zones[zone] = {}
    end
    
    local touchData = {
        title=title,
        position=position,
        key=key,
        image=image,
        func=func,
        params=params
    }
    
    table.insert(self.zones[zone], touchData)
    
end

function touch.determine_zone(self, zone, x, y)
    
    -- Test if this zone has buttons
    if not self.zones[zone] then return end
    
    -- Coordinate button positions to a dynamic display size
    local W, H = love.graphics.getDimensions()
    
    for _, button in pairs(self.zones[zone]) do
        
        local bx = button.position.x
        local by = button.position.y
        local bh = button.position.h
        local bw = button.position.w
        
        if by and bh then bh = bh + by end
        
        if button.position.left then
            bx = button.position.left / 100 * W
        end
        if button.position.top then
            by = button.position.top / 100 * H
        end
        if button.position.bottom then
            bh = button.position.bottom / 100 * H
        end
        if button.position.right then
            bw = button.position.right / 100 * W 
        end
        
        if x > bx and x < bw and y > by and y < bh then
            if button.func then
                touch.cooldownvalue = touch.cooldown
                button.func(button.params)
            else
                return button.key
            end
        end
        
    end

end

function touch.draw(self, zone)
    
    -- Test if this zone has buttons
    if not self.active or not self.zones[zone] then return end
    
    -- Coordinate button positions to a dynamic display size
    local W, H = love.graphics.getDimensions()
    
    -- Set button drawing style
    love.graphics.setColor({255, 255, 255, 128})
    love.graphics.setLineWidth(1)
    
    for _, button in pairs(self.zones[zone]) do
        
        local x = button.position.x
        local y = button.position.y
        local h = button.position.h
        local w = button.position.w
        
        if button.position.left then
            x = button.position.left / 100 * W
        end
        if button.position.top then
            y = button.position.top / 100 * H
        end
        if button.position.bottom then
            h = button.position.bottom / 100 * H - y
        end
        if button.position.right then
            w = button.position.right / 100 * W - x 
        end
        
        -- Image
        if button.image then
            
            love.graphics.setColor(touch.colors.tint)
            
            love.graphics.draw(button.image,
                x+w/2, y+h/2,
                0, 1, 1,
                button.image:getWidth()/2,
                button.image:getHeight()/2)
            
            if DEBUG then
                love.graphics.rectangle("line", x, y, w, h)
            end

        else
            
--            -- Fill
--            love.graphics.setColor(touch.colors.fill)
--            love.graphics.rectangle("fill", x, y, w, h)
            
--            -- Border
--            love.graphics.setColor(touch.colors.border)
--            love.graphics.rectangle("line", x, y, w, h)
            
--            -- Title
--            love.graphics.setColor(touch.colors.font)
--            love.graphics.printf(button.title, x, y+h/2, w, "center")
            
        end
        
    end
    
end

--function touch.pressed(self, zone, x, y)
    
--    if not self.active then return end
    
--    local key = self:determine_zone(zone, x, y)
    
--    if key then love.keypressed(key) end
    
--end

--function touch.released(self, zone, x, y)
    
--    if not self.active then return end
    
--    local key = self:determine_zone(zone, x, y)
    
--    if key then love.keyreleased(key) end
    
--end

function touch.update(self, dt, zone)
    
    if not self.active then return end
    
    touch.cooldownvalue = touch.cooldownvalue - dt
    
    if touch.cooldownvalue > 0 then return end
    
    if love.mouse.isDown(1) then
    
        local x, y = love.mouse.getPosition() 
        
        local key = self:determine_zone(zone, x, y)
        
        if key and self.lastkey ~= key then
            -- Release last key first
            if self.lastkey then
                love.keyreleased(self.lastkey)
            end
            -- Press new key
            love.keypressed(key)
            self.lastkey = key
        end
            
    else
        if self.lastkey then
            love.keyreleased(self.lastkey)
            self.lastkey = nil
        end
    end
    
end

function touch.vibe(self, duration)
    if self.active and love.system.vibrate then
        love.system.vibrate(duration)
    end
end

-- Hook the touch regions for android devices
if DEBUG or love.system.getOS() == "Android" then
    touch.active = true
end

return touch