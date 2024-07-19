local ox_inventory = exports.ox_inventory
lib.locale()
local antifarm = {}
local issuedTags = {}
local QBCore = exports['qb-core']:GetCoreObject()


local function inTable(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function antifarmFunction(source, coords)
    if Config.antiFarm.enable == false then return true end
    if Config.antiFarm.personal == false then
        source = 1
    end

    local curentTime = os.time()
    if not next(antifarm) or antifarm[source] == nil or not next(antifarm[source]) then -- table empty
        antifarm[source] = {}
        table.insert(antifarm[source], { time = curentTime, coords = coords, amount = 1 })
        return true
    end
    for i = 1, #antifarm[source], 1 do
        if (curentTime - antifarm[source][i].time) > Config.antiFarm.time then    -- delete old table
            table.remove(antifarm[source], i)
        elseif #(antifarm[source][i].coords - coords) < Config.antiFarm.size then -- if found table in coord
            if antifarm[source][i].amount >= Config.antiFarm.maxAmount then       -- if amount more than max
                return false
            end
            antifarm[source][i].amount = antifarm[source][i].amount + 1 -- if not amount more than max
            antifarm[source][i].time = curentTime
            return true
        end
    end
    table.insert(antifarm[source], { time = curentTime, coords = coords, amount = 1 }) -- if no table in coords found
    return true
end

local function map(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

RegisterNetEvent('nfire_hunting:server:harvestCarcass')
AddEventHandler('nfire_hunting:server:harvestCarcass', function(entityId, bone, weaponGroup)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local entity = NetworkGetEntityFromNetworkId(entityId)
    local entityCoords = GetEntityCoords(entity)
    if #(playerCoords - entityCoords) < 5 then
        if antifarmFunction(source, entityCoords) then
            local model = GetEntityModel(entity)
            local item = Config.carcass[model].item
            local grade = '★☆☆'
            local gradescale = 1
            local image = item .. 1

            if inTable(Config.goodWeapon, weaponGroup) then
                gradescale = gradescale + 1
            end

            if inTable(Config.carcass[model].headshotBones, bone) then
                gradescale = gradescale + 1
            end

            if gradescale == 2 then
                grade = '★★☆'
                image = item .. 2
            elseif gradescale == 3 then
                grade = '★★★'
                image = item .. 3
            end

            if exports.ox_inventory:CanCarryItem(source, item, 1) and DoesEntityExist(entity) and GetEntityAttachedTo(entity) == 0 then
                exports.ox_inventory:AddItem(source, item, 1, { type = grade, image = image, model = model })
                DeleteEntity(entity)
            end
        else
            TriggerClientEvent('QBCore:Notify', source, locale['stop_farm'], 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, locale['too_far'], 'error')
    end
end)

RegisterNetEvent('nfire_hunting:server:SellCarcass')
AddEventHandler('nfire_hunting:server:SellCarcass', function(item)
    local itemData = exports.ox_inventory:Search(source, 'slots', item)[1]
    if itemData.count >= 1 then
        local reward = Config.carcass[itemData.metadata.model].max * Config.gradeMultiplier[itemData.metadata.type]
        if Config.degrade and itemData.metadata.durability ~= nil then
            local currentTime = os.time()
            local maxTime = itemData.metadata.durability
            local minTime = maxTime - itemData.metadata.degrade * 60
            if currentTime >= maxTime then
                currentTime = maxTime
            end
            reward = math.floor(map(currentTime, maxTime, minTime, Config.sellPrice[item].min * Config.gradeMultiplier[itemData.metadata.type], Config.sellPrice[item].max * Config.gradeMultiplier[itemData.metadata.type]))
        end
        exports.ox_inventory:RemoveItem(source, item, 1, nil, itemData.slot)
        exports.ox_inventory:AddItem(source, 'money', reward)
    end
end)


local function tagAnimal(payload)
    local src = payload.source
    TriggerClientEvent('ox_inventory:closeInventory', src)
    TriggerClientEvent('nfire_hunting:client:applytag', src)
    payload.toSlot.metadata.tagged = true
    payload.toSlot.metadata.description = payload.toSlot.metadata.description .. "  \n"..payload.fromSlot.metadata.description
    Wait(6000)
    ox_inventory:RemoveItem(src, 'tag', 1, payload.from.metadata)
    ox_inventory:SetMetadata(src, payload.toSlot.metadata, payload.toSlot.metadata)
end

local function hasHuntingLicense(source)
    local idcard = exports.ox_inventory:Search(source, 'slots', 'id_card')
    if idcard then
        for k,v in pairs(idcard) do
            if v.metadata.documentName == "Hunting" then
                return true
            end
        end
        return false
    end
end

local tagHook = ox_inventory:registerHook('swapItems', function(payload)
        if type(payload.toSlot) == "table" and not payload.toSlot.metadata.tagged and payload.fromInventory == payload.source then
            tagAnimal(payload)
            return false
        end
    end,
    {
        print = false,
        itemFilter = {
            tag = true
        },
    })

RegisterNetEvent('nfire_hunting:server:issuetag')
AddEventHandler('nfire_hunting:server:issuetag', function()
    local src = source
    local player = QBCore.Functions.GetPlayerBySource(src)
    if hasHuntingLicense(source) then
        if not issuedTags[player.PlayerData.citizenid] then
            local tagDate = os.date("%m/%d/%y @ %I:%M")
            local tagName = player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
            local metadata = {
                description = "Authorized To: "..tagName.."  \nIssued Date: "..tagDate
            }
            issuedTags[player.PlayerData.citizenid] = true
            exports.ox_inventory:AddItem(src, 'tag', 6, metadata)
        else
            TriggerClientEvent('QBCore:Notify', src, "You already received your tags today!", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You do not have a valid hunting license", 'error')
    end
end)

if Config.debug then
    lib.addCommand('group.admin', 'giveCarcass', function(source, args)
        for key, value in pairs(Config.carcass) do
            exports.ox_inventory:AddItem(source, value, 1, { type = '★☆☆', image = value .. 1 })
            exports.ox_inventory:AddItem(source, value, 1, { type = '★★☆', image = value .. 2 })
            exports.ox_inventory:AddItem(source, value, 1, { type = '★★★', image = value .. 3 })
        end
    end)

    lib.addCommand('group.admin', 'spawnPed', function(source, args)
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local entity = CreatePed(0, GetHashKey(args.hash), playerCoords, true, true)
    end, { 'hash:string' })

    lib.addCommand('group.admin', 'printAntifarm', function(source, args)
        print(json.encode(antifarm, { indent = true }))
    end)

    lib.addCommand('group.admin', 'printInv', function(source, args)
        print(json.encode(exports.ox_inventory:Inventory(source).items, { indent = true }))
    end)
end
