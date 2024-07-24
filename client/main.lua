lib.locale()
local carryCarcass = 0
local heaviestCarcass = 0
local animalModel = {}
local animalItems = {}
local carcassByItem = {}
for key, value in pairs(Config.carcass) do
    animalModel[#animalModel + 1] = key
    animalItems[#animalItems + 1] = value.item
    carcassByItem[value.item] = key
end

local function customControl()
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local enable = true

        while enable do
            if IsControlPressed(0, 35) then -- Right
                FreezeEntityPosition(playerPed, false)
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + 0.5)
            elseif IsControlPressed(0, 34) then -- Left
                FreezeEntityPosition(playerPed, false)
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) - 0.5)
            elseif IsControlPressed(0, 32) or IsControlPressed(0, 33) then
                FreezeEntityPosition(playerPed, false)
            else
                FreezeEntityPosition(playerPed, true)
                TaskPlayAnim(PlayerPedId(), 'combat@drag_ped@', 'injured_drag_plyr', 0.0, 0.0, 1, 2, 7, false, false, false)
            end
            Wait(7)
            if heaviestCarcass ~= 0 then
                enable = Config.carcass[heaviestCarcass].pos.drag
            else
                enable = false
            end
        end
        FreezeEntityPosition(playerPed, false)
        ClearPedSecondaryTask(playerPed)
        ClearPedTasksImmediately(playerPed)
    end)
end

local function playCarryAnim()
    if carryCarcass ~= 0 then
        if Config.carcass[heaviestCarcass].pos.drag then
            lib.requestAnimDict('combat@drag_ped@')
            TaskPlayAnim(PlayerPedId(), 'combat@drag_ped@', 'injured_drag_plyr', 2.0, 2.0, 100000, 1, 0, false, false, false)
            customControl()
            while carryCarcass ~= 0 do
                while not IsEntityPlayingAnim(PlayerPedId(), 'combat@drag_ped@', 'injured_drag_plyr', 1) do
                    TaskPlayAnim(PlayerPedId(), 'combat@drag_ped@', 'injured_drag_plyr', 2.0, 2.0, 100000, 1, 0, false, false, false)
                    Wait(0)
                end
                Wait(500)
            end
        else
            lib.requestAnimDict('missfinale_c2mcs_1')
            TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, 100000, 49, 0, false, false, false)
            while carryCarcass ~= 0 do
                while not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 49) do
                    TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, 100000, 49, 0, false, false, false)
                    Wait(0)
                end
                Wait(500)
            end
        end
    else
        ClearPedSecondaryTask(PlayerPedId())
    end
end

exports.ox_target:addModel(animalModel, {
    {
        label = locale('pickup_carcass'),
        name = 'ox:option1',
        icon = "fa-solid fa-paw",
        distance = 3.0,
        onSelect = function(data)
            TriggerEvent('ox_inventory:disarm')
            local _, bone = GetPedLastDamageBone(data.entity)
            TaskTurnPedToFaceEntity(PlayerPedId(), data.entity, -1)
            Wait(500)
            if lib.progressBar({
                    duration = 5000,
                    label = locale('pickup_carcass'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                        mouse = false
                    },
                    anim = {
                        dict = 'amb@medic@standing@kneel@idle_a',
                        clip = 'idle_a',
                        flag = 1,
                    },
                }) then
                local weapon = GetPedCauseOfDeath(data.entity)
                local weaponGroup = GetWeapontypeGroup(weapon)
                TriggerServerEvent('nfire_hunting:server:harvestCarcass', NetworkGetNetworkIdFromEntity(data.entity), bone, weaponGroup)
            end
        end,
        canInteract = function(entity)
            return IsEntityDead(entity) and not IsEntityAMissionEntity(entity)
        end
    },
}
)

AddEventHandler('ox_inventory:updateInventory', function(changes) 
    TriggerEvent('nfire_hunting:client:CarryCarcass')
end)


AddEventHandler('nfire_hunting:client:CarryCarcass', function()
    local carcassCount = 0
    local playerPed = PlayerPedId()
    for key, value in pairs(exports.ox_inventory:Search('count', animalItems)) do
        carcassCount = carcassCount + value
    end
    if carcassCount > 0 then
        TriggerEvent('ox_inventory:disarm')
        FreezeEntityPosition(playerPed, false)
        heaviestCarcass = 0
        if carcassCount > 0 then
            local inventory = exports.ox_inventory:Search('slots', animalItems)
            if inventory then
                local weight = 0
                for key, value in pairs(inventory) do
                    if next(value) ~= nil and value[1].weight > weight then
                        weight = value[1].weight
                        heaviestCarcass = carcassByItem[key]
                    end
                end

                lib.requestModel(heaviestCarcass)
                DeleteEntity(carryCarcass)
                carryCarcass = CreatePed(1, heaviestCarcass, GetEntityCoords(playerPed), GetEntityHeading(playerPed), true, true)
                SetEntityInvincible(carryCarcass, true)
                SetEntityHealth(carryCarcass, 0)
                local pos = Config.carcass[heaviestCarcass].pos
                AttachEntityToEntity(carryCarcass, playerPed, 11816, pos.coords, pos.rotate, false, false, false, true, 2, true)
                playCarryAnim()
            end
        end
    elseif carryCarcass ~= 0 then
        heaviestCarcass = 0
        DeleteEntity(carryCarcass)
        carryCarcass = 0
        playCarryAnim()
    end
end)

RegisterCommand('carcass', function()
    lib.requestAnimDict('amb@medic@standing@kneel@idle_a')
    TaskPlayAnim(PlayerPedId(), 'amb@medic@standing@kneel@idle_a', 'idle_a', 8.0, -8.0, 10000, 1, 0, false, false, false)
end, true)

--------------------- SELL -----------------------------------
for k, v in pairs(Config.salepoints) do
    exports.ox_target:addSphereZone({
        coords = Config.salepoints[k].location,
        radius = Config.salepoints[k].radius,
        options = {
            {
                name = 'sellcarcass1',
                icon = "fa-solid fa-comment-dollar",
                label = locale('sell_carcass'),
                onSelect = function()
                    if lib.progressBar({
                            duration = 5000,
                            label = locale('sell_in_progress'),
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                car = true,
                                combat = true,
                                mouse = false
                            },
                        }) then
                        TriggerServerEvent('nfire_hunting:server:SellCarcass', Config.carcass[heaviestCarcass])
                    end
                end,
                items = animalItems,
                anyItem = true
            },
        },
    })
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.salepoints) do
        if v.blip then
            local blip = AddBlipForCoord(v.location)
            SetBlipSprite(blip, 141)
            SetBlipScale(blip, 0.8)
            SetBlipColour(kblip, 21)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(locale 'blip_name')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

RegisterNetEvent('nfire_hunting:client:applytag')
AddEventHandler('nfire_hunting:client:applytag', function()
    lib.progressBar({
        duration = 6000,
        label = 'Tagging Animal..',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
        anim = {
            dict = 'amb@prop_human_parking_meter@male@base',
            clip = 'base'
        },
    })
end)
