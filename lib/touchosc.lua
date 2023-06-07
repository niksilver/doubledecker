local TouchOSC = {} function TouchOSC:init(bind)
    -- Capture the binding module
    self.bind = bind

    -- The host and port of the TouchOSC device; only handles one
    self.dest = {}

    self.bind:add_listener(function(page, row, col, layer, normalized)
        print('/' .. page .. '/' .. row .. '/' .. col .. '/' .. layer .. " -> " .. normalized)
    end)
end

-- Capture an OSC event frm TouchOSC.
-- Format of the path will be `/doubledecker/page/row/col/layer`.
--
function TouchOSC:osc_event(path, args, from)
    print("\n\nosc.event.path = " .. path)
    print("\n\nosc.event.args = " .. self.dump(args))

    -- We may have a connection event
    if string.match(path, '^/doubledecker/connect') then
        self:connect_event(from)
        return
    end

    -- We may have an event from a control
    local page, row, col, layer = string.match(path, '/doubledecker/(%d+)/(%d+)/(%d+)/(%d+)')
    if page and row and col and layer then
        self:control_event(page, row, col, layer, args, from)
    end
end

-- Handle a control change from TouchOSC
--
function TouchOSC:control_event(page, row, col, layer, args, from)
    local val = args[1]
    print("osc.event val = " .. tostring(val))
    local b = self.bind:get(page, row, col, layer)
    print("osc.event: b = " .. TouchOSC.dump(b))
    -- print("osc.event: b.param = " .. TouchOSC.dump(b.param))
    print("            tOPTION = " .. params.tOPTION)
    if b.param and val then
        -- See if we can normalize the value from TouchOSC
        local normalized = val
        if b.param.t == params.tOPTION then
            -- An option parameter
            normalized = val / (b.param.count - 1)
        end

        b:set(normalized)
        screen_dirty = true
        print("osc.event.path: Updated to normalized val = " .. normalized)
    end
end

-- Handle an initial connection from TouchOSC.
--
function TouchOSC:connect_event(from)
    if #self.dest == 2 and from[1] == self.dest[1] and from[2] == self.dest[2] then
        -- We already have this connection
    else
        -- It's a new/replacement connection
        self.dest = from
        print("Connection from " .. from[1] .. ":" .. from[2])
    end

    -- Make sure the button is lit
    osc.send(from, '/doubledecker/connect', {1.0})
end

-- Returns an object in its desconstructed string form.
--
function TouchOSC.dump(o, lvl)
    if lvl == nil then
        lvl = 1
    elseif lvl >= 4 then
        return '...'
    end
    if type(o) == 'table' then
        local indent = string.rep(' ', lvl*2)
        local s = '{\n'
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. indent .. '['..k..'] = ' .. TouchOSC.dump(v, lvl+1) .. ',\n'
        end
        indent = string.rep(' ', (lvl-1)*2)
        return s .. indent .. '} '
    else
        return tostring(o)
    end
end

return TouchOSC
