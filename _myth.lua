local NoName = ...
local JSON = NoName.Utils.JSON
local Draw = NoName.Utils.Draw:New()

local write = NoName.Utils.Storage.write
local aes = NoName.Utils.AES
local sha = NoName.Utils.sha

local enable_draw_path = false
local enable_draw_player_target_info = false
local enable_draw_entity_info = false
local enable_draw_line_to_herbs = false
local enable_draw_line_to_ores = false
local enable_draw_esp_player = false

local walked_path = {}



-- [[ GUI Functions ]]
local cur_y_offset = 0

local function _gui_add_esp_option(frame, name, desc, callback, x, y)
    local check = CreateFrame("CheckButton", "leEspOption" .. name, frame, "ChatConfigCheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetChecked(false)
    check:SetScript("OnClick", function(self) callback(self:GetChecked()) end)
    _G[check:GetName() .. "Text"]:SetText(desc)
    _G[check:GetName() .. "Text"]:SetTextColor(1, 1, 1)
    _G[check:GetName() .. "Text"]:SetFont("Fonts\\FRIZQT__.TTF", 12)
    check:SetHitRectInsets(0, -_G[check:GetName() .. "Text"]:GetStringWidth(), 0, 0)
end
function GUI_add_category(frame, category, items, x, y)
    local title = frame:CreateFontString("leEspTitle", "OVERLAY", "GameFontNormal")
    title:SetText(category)
    title:SetPoint("TOPLEFT", x, y)
    title:SetTextColor(1, 1, 1)

    local item_x = 0
    local item_y = 20
    local last_y = 0
    for _, item in pairs(items) do
        if _ % 4 == 0 then
            item_x = 0
            item_y = item_y + 25
        elseif _ > 1 then
            item_x = item_x + 90
        end
        _gui_add_esp_option(frame, item.name, item.desc, item.callback, x + item_x, y - item_y)
        last_y = y - item_y
    end
    cur_y_offset = cur_y_offset + item_y  - 10

    -- border lines
    local line = frame:CreateTexture("leEspLine", "OVERLAY")
    line:SetColorTexture(1, 1, 1, 0.5)
    line:SetSize(250, 1)
    local line_y = last_y - 20
    line:SetPoint("TOPLEFT", x, line_y)
end



-- [[ GUI ]]
local frame = CreateFrame("Frame", "le ESP", UIParent)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetSize(570, 220)
frame:SetPoint("CENTER", 0, 0)

local bg_texture = frame:CreateTexture("leEspBgTexture", "BACKGROUND")
bg_texture:SetAllPoints()
bg_texture:SetColorTexture(0, 0, 0, 0.5)

local title = frame:CreateFontString("leEspTitle", "OVERLAY", "GameFontNormal")
title:SetText("Myth ESP (some lua shitcode)")
title:SetPoint("TOP", 0, -5)

-- local player
local enable_draw_esp_local_player = false
local enable_draw_esp_local_player_pet = false
local enable_draw_esp_local_player_target = false
local enable_draw_esp_local_player_target_path = false
local enable_draw_esp_local_player_box = false
local function state_DrawEspLocalPlayer(state)         enable_draw_esp_local_player = state end
local function state_DrawEspLocalPlayerPet(state)      enable_draw_esp_local_player_pet = state end
local function state_DrawEspLocalPlayerTarget(state)   enable_draw_esp_local_player_target = state end
local function state_DrawEspLocalPlayerTargetPath(state)   enable_draw_esp_local_player_target_path = state end
local function state_DrawEspLocalPlayerBox(state)      enable_draw_esp_local_player_box = state end
GUI_add_category(frame, "LocalPlayer", {
    {name = "esp_draw_esp_local_player",                desc = "Enable",        callback = state_DrawEspLocalPlayer },
    {name = "esp_draw_esp_local_player_pet",            desc = "Pet",           callback = state_DrawEspLocalPlayerPet },
    {name = "esp_draw_esp_local_player_target",         desc = "Target",        callback = state_DrawEspLocalPlayerTarget },
    {name = "esp_draw_esp_local_player_target_path",    desc = "Target Path",   callback = state_DrawEspLocalPlayerTargetPath },
    {name = "esp_draw_esp_local_player_box",            desc = "Localplayer",           callback = state_DrawEspLocalPlayerBox },
}, 10, -30)

-- entities
local enable_draw_esp_entities = false
local enable_draw_esp_entities_herbs = false
local enable_draw_esp_entities_ores = false
local enable_draw_esp_entities_mobs = false
local enable_draw_esp_entities_players = false
local enable_draw_esp_entities_npc = false
local function state_DrawEspEntities(state)         enable_draw_esp_entities = state end
local function state_DrawEspEntitiesHerbs(state)    enable_draw_esp_entities_herbs = state end
local function state_DrawEspEntitiesOres(state)     enable_draw_esp_entities_ores = state end
local function state_DrawEspEntitiesMobs(state)     enable_draw_esp_entities_mobs = state end
local function state_DrawEspEntitiesPlayers(state)  enable_draw_esp_entities_players = state end
local function state_DrawEspEntitiesNpc(state)      enable_draw_esp_entities_npc = state end
GUI_add_category(frame, "Entities", {
    {name = "esp_draw_esp_entities",                desc = "Enable",        callback = state_DrawEspEntities },
    {name = "esp_draw_esp_entities_herbs",          desc = "Herbs",         callback = state_DrawEspEntitiesHerbs },
    {name = "esp_draw_esp_entities_ores",           desc = "Ores",          callback = state_DrawEspEntitiesOres },
    {name = "esp_draw_esp_entities_mobs",           desc = "Mobs",          callback = state_DrawEspEntitiesMobs },
    {name = "esp_draw_esp_entities_players",        desc = "Players",       callback = state_DrawEspEntitiesPlayers },
    {name = "esp_draw_esp_entities_npc",            desc = "NPC",           callback = state_DrawEspEntitiesNpc },
}, 300, -30)

-- misc
local enable_draw_esp_misc = false
local enable_draw_esp_misc_corpses = false
local enable_draw_esp_misc_traps = false
local enable_draw_esp_misc_walked_path = false
local enable_draw_esp_misc_snaplines = false
local function state_DrawEspMisc(state)             enable_draw_esp_misc = state end
local function state_DrawEspMiscCorpses(state)      enable_draw_esp_misc_corpses = state end
local function state_DrawEspMiscTraps(state)        enable_draw_esp_misc_traps = state end
local function state_DrawEspMiscWalkedPath(state)   enable_draw_esp_misc_walked_path = state end
local function state_DrawEspMiscSnaplines(state)    enable_draw_esp_misc_snaplines = state end
GUI_add_category(frame, "Misc", {
    {name = "esp_draw_esp_misc",                desc = "Enable",        callback = state_DrawEspMisc },
    {name = "esp_draw_esp_misc_corpses",        desc = "Corpses",       callback = state_DrawEspMiscCorpses },
    {name = "esp_draw_esp_misc_traps",          desc = "Traps",         callback = state_DrawEspMiscTraps },
    {name = "esp_draw_esp_misc_walked_path",    desc = "Walked Path",   callback = state_DrawEspMiscWalkedPath },
    {name = "esp_draw_esp_misc_snaplines",      desc = "Snaplines",     callback = state_DrawEspMiscSnaplines },
}, 10, -30 + -cur_y_offset)

-- close button
local close = CreateFrame("Button", "MyESPFrameCloseButton", frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 0, 0)
close:SetScript("OnClick", function(self) frame:Hide() end)

frame:Show()
-- [[ END GUI ]]

local function drawBox(draw, px, py, pz, rot, color)
    rot = rot + math.pi / 4
    draw:SetColor(color)

    local width = 1.25
    local height = 2.55

    local x1 = px + math.cos(rot) * width
    local y1 = py + math.sin(rot) * width
    local x2 = px + math.cos(rot + math.pi / 2) * width
    local y2 = py + math.sin(rot + math.pi / 2) * width
    local x3 = px + math.cos(rot + math.pi) * width
    local y3 = py + math.sin(rot + math.pi) * width
    local x4 = px + math.cos(rot + math.pi * 3 / 2) * width
    local y4 = py + math.sin(rot + math.pi * 3 / 2) * width

    -- bottom
    draw:Line(x1, y1, pz, x2, y2, pz)
    draw:Line(x2, y2, pz, x3, y3, pz)
    draw:Line(x3, y3, pz, x4, y4, pz)
    draw:Line(x4, y4, pz, x1, y1, pz)

    -- top
    draw:Line(x1, y1, pz + height, x2, y2, pz + height)
    draw:Line(x2, y2, pz + height, x3, y3, pz + height)
    draw:Line(x3, y3, pz + height, x4, y4, pz + height)
    draw:Line(x4, y4, pz + height, x1, y1, pz + height)

    -- sides
    draw:Line(x1, y1, pz, x1, y1, pz + height)
    draw:Line(x2, y2, pz, x2, y2, pz + height)
    draw:Line(x3, y3, pz, x3, y3, pz + height)
    draw:Line(x4, y4, pz, x4, y4, pz + height)


end

local function drawEntityInfo(entity, draw)
    -- draw health bar
    local x, y, z = ObjectPosition(entity)

    if not x or not y or not z or not entity then
        return
    end
    
    -- draw text corner
    draw:SetColor(draw.colors.white)
    local esp_text = UnitName(entity) .. " (HP:" .. UnitHealth(entity) .. "/" .. UnitHealthMax(entity) .. ")"
    local height = 2.55
    draw:Text(
        esp_text,
        "GameTooltipText",
        x,
        y,
        z + height + 1
    )
end

local function drawWalkedPath(draw)
    if #walked_path > 250 then
        --remove first
        table.remove(walked_path, 1)
    end
    
    local px, py, pz = ObjectPosition("player")
    local lastX, lastY, lastZ = 0, 0, 0
    for i = 1, #walked_path do
        
        local x, y, z, _time = walked_path[i].x, walked_path[i].y, walked_path[i].z, walked_path[i]._time
        if _time + 10 < GetTime() then
            -- remove old nodes
            table.remove(walked_path, i)
            i = i - 1
            return
        else
            if i > 1 then
                draw:SetColor(draw.colors.red)
                draw:Line(x, y, z, lastX, lastY, lastZ)
            end
            if i % 65 == 0 or i == 1 then
                local dist = math.sqrt((x-px)^2 + (y-py)^2 + (z-pz)^2)
                draw:SetColor(draw.colors.white)
                dist = string.format("%.2f", dist)
                draw:Text(dist, "GameTooltipTextSmall", x, y, z + 0.25)
            end
            lastX, lastY, lastZ = x, y, z
        end
        
    end
    
    if #walked_path > 0 then
        local lastNode = walked_path[#walked_path]
        local dist = math.sqrt((lastNode.x-px)^2 + (lastNode.y-py)^2 + (lastNode.z-pz)^2)
        if dist < 1 then
            return
        end
    end
    table.insert(walked_path, {x = px, y = py, z = pz, _time = GetTime()})
end

function isOre(name)
    local name = UnitName(name)
    if name == "Copper Vein" or name == "Tin Vein" or name == "Silver Vein" or name == "Iron Deposit" or name == "Gold Vein" or name == "Mithril Deposit" or name == "Truesilver Deposit" or name == "Small Thorium Vein" or name == "Ooze Covered Mithril Deposit" or name == "Ooze Covered Silver Vein" or name == "Ooze Covered Gold Vein" or name == "Ooze Covered Truesilver Deposit" or name == "Ooze Covered Mithril Deposit" or name == "Ooze Covered Thorium Vein" then
        return true
    end
    return false
end
function isHerb(name)
    local name = UnitName(name)
    if name == "Peacebloom" or name == "Silverleaf" or name == "Earthroot" or name == "Mageroyal" or name == "Briarthorn" or name == "Bruiseweed" or name == "Wild Steelbloom" or name == "Grave Moss" then
        return true
    end
    return false
end
function isLocalPlayer(name)
    if ObjectType(name) == 7 then
        return true
    end
    return false
end
function isPlayer(name)
    if UnitIsPlayer(name) then
        return true
    end
    return false
end
function isNPC(name)
    if UnitIsFriend("player", name) and UnitIsPlayer(name) == false then
        return true
    end
    return false
end
function isMob(name)
    if UnitIsEnemy("player", name) and UnitIsPlayer(name) == false then
        return true
    end
    return false
end
function isPet(name)
    if UnitIsUnit(name, "pet") then
        return true
    end
    return false
end
function isObject(name)
    if isMob(name) == false and isNPC(name) == false and isPlayer(name) == false and isHerb(name) == false and isOre(name) == false and isPet(name) == false then
        return true
    end
    return false
end
function isCorpse(name)
    if ObjectType(name) == 3 then
        return true
    end
    return false
end
function isTrap(name)
    if ObjectType(name) == 6 and isPlayer(name) == false and isPet(name) == false and isMob(name) == false and isNPC(name) == false then
        return true
    end
    return false
end

-- [[ ESP ENTITIES ]]
Draw:Sync(
    function(draw)
        if enable_draw_esp_entities == false then
            return
        end

        entitites = Objects()
        for v, k in pairs(entitites) do
            if isLocalPlayer(k) == false and isPet(k) == false then
                local x, y, z = ObjectPosition(k)

                local _draw = false
                local clr = draw.colors.white
                
                if isOre(k) and enable_draw_esp_entities_ores == true then
                    _draw = true
                    clr = draw.colors.blue
                elseif isHerb(k) and enable_draw_esp_entities_herbs then
                    _draw = true
                    clr = draw.colors.blue
                elseif isPlayer(k) and enable_draw_esp_entities_players then
                    _draw = true
                    clr = draw.colors.purple
                elseif isMob(k) and enable_draw_esp_entities_mobs == true then
                    _draw = true
                    clr = draw.colors.red
                    if UnitIsDead(k) then
                        clr = {155, 155, 155, 75}
                    end
                    if ObjectLootable(k) or ObjectSkinnable(k) then
                        clr = {255, 255, 0, 75}
                    end


                elseif isNPC(k) and enable_draw_esp_entities_npc == true then
                    _draw = true
                    clr = draw.colors.green
                end
            
                if _draw then
                    drawBox(draw, x, y, z, ObjectFacing(k), clr)
                    if enable_draw_esp_misc_snaplines == true then
                        draw:Line(x, y, z, ObjectPosition("player"))
                    end
                    drawEntityInfo(k, draw)
                end
            end
        end
    end
)
Draw:Enable()

-- [[ LOCAL PLAYER ESP ]]]
Draw:Sync(
    function(draw)
        if enable_draw_esp_local_player == false then
            return
        end

        if enable_draw_esp_local_player_box == true then
            local px, py, pz = ObjectPosition("player")
            drawEntityInfo("player", draw)
            drawBox(draw, px, py, pz, ObjectFacing("player"), draw.colors.yellow)
        end
        if enable_draw_esp_local_player_pet then
            local hasPet = UnitExists("pet")
            if hasPet then
                local px, py, pz = ObjectPosition("pet")
                drawEntityInfo("pet", draw)
                drawBox(draw, px, py, pz, ObjectFacing("pet"), draw.colors.blue)
                draw:Line(px, py, pz, ObjectPosition("player"))
            end
        end

        if enable_draw_esp_local_player_target then
            local hasTarget = UnitExists("target")
            if hasTarget then
                local tx, ty, tz = ObjectPosition("target")
                drawEntityInfo("target", draw)
                drawBox(draw, tx, ty, tz, ObjectFacing("target"), draw.colors.red)
            end
        end
    end
)
Draw:Enable()
-- [[ LOCAL PLAYER ESP ]]]

-- [[ PATH TO TARGET ]]]
Draw:Sync(
    function(draw)
        if enable_draw_esp_local_player_target_path == false then return end
        if not UnitExists("target") then return end

        local map = select(8, GetInstanceInfo())
        local px,py,pz = ObjectPosition('player')
        local x,y,z = ObjectPosition('target')

        local dist = math.sqrt((x-px)^2 + (y-py)^2 + (z-pz)^2)
        if dist > 10000 then return end

        local path = GenerateLocalPath(map,px,py,pz,x,y,z)
        for node = 1, #path do
            
            local x,y,z = path[node].x, path[node].y, path[node].z
            local lastNode = node - 1
            if lastNode > 0 then
                if node == 1 then return end

                local lx,ly,lz = path[lastNode].x, path[lastNode].y, path[lastNode].z

                if not x or not y or not z or not lx or not ly or not lz then return end

                draw:SetColor({255,155,155,75})
                draw:Line(x,y,z,lx,ly,lz)

                draw:SetColor({255,255,255,75})
                draw:Line(x,y,z,x,y,z+0.25)

                if node < 5 then
                    if not z then return end
                    
                    draw:SetColor({255,255,255,255})
                    draw:Text(math.floor(dist * 100) / 100, "GameTooltipTextSmall", x, y, z + 0.40)
                end
            end
        end
    end

)
Draw:Enable()
-- [[ PATH TO TARGET ]]]


-- [[ MISC ]]
Draw:Sync(
    function(draw)
        if enable_draw_esp_misc == false then
            return
        end

        if enable_draw_esp_misc_walked_path == true then
            drawWalkedPath(draw)
        end

        entitites = Objects()
        for v, k in pairs(entitites) do
            if isLocalPlayer(k) == false and isPet(k) == false then
                local x, y, z = ObjectPosition(k)
                
                if isCorpse(k) and enable_draw_esp_misc_corpses == true then
                    drawBox(draw, x, y, z, ObjectFacing(k), draw.colors.blue)
                    if enable_draw_esp_misc_snaplines == true then
                        draw:Line(x, y, z, ObjectPosition("player"))
                    end
                    drawEntityInfo(k, draw)

                   
                    
                end

            end
        end
    end
)
Draw:Enable()
-- [[ MISC ]]
