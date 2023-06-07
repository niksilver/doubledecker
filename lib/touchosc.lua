local TouchOSC = {}

function TouchOSC:init(bind)
    print("TouchOSC:init - self = " .. TouchOSC.dump(self))
    print("TouchOSC:init - bind = " .. TouchOSC.dump(bind))
    self.bind = bind
end

-- Capture an OSC event frm TouchOSC.
-- Format of the path will be `/doubledecker/page/row/col/layer`.
--
function TouchOSC:osc_event(path, args, from)
    local layer = 1
    local page, row, col, layer = string.match(path, '/doubledecker/(%d+)/(%d+)/(%d+)/(%d+)')
    print("osc.event.path = " .. path)
    if page and row and col and layer then
        local b = self.bind:get(page, row, col, layer)
        local val = args[1]
        if b and val then
            b:set(val)
            screen_dirty = true
            print("osc.event.path: Updated to val = " .. val)
            print("osc.event.path: descriptor = " .. b.descriptor)
        end
    end
end

-- Returns an object in its desconstructed string form.
--
function TouchOSC.dump(o, lvl)
    if lvl == nil then
        lvl = 1
    elseif lvl >= 3 then
        return '...'
    end
    if type(o) == 'table' then
        local indent = string.rep(' ', lvl*2)
        local s = '{\n'
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. indent .. '['..k..'] = ' .. TouchOSC.dump(v, lvl+1) .. ',\n'
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return TouchOSC
