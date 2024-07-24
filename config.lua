Config = {
    debug           = false, -- Add Debug Commands

    carcass         = {
        ['a_c_boar'] = {
            headshotBones = { 31086 },
            item = 'carcass_boar',
            min = 150,
            max = 1000,
            pos = { drag = true, xPos = -0.7, yPos = 1.2, zPos = -1.0, xRot = -200.0, yRot = 0.0, zRot = 0.0 }
        },
        ['a_c_chickenhawk'] = {
            headshotBones = { 39317 },
            item = 'carcass_hawk',
            min = 200,
            max = 1200,
            pos = { drag = false, coords = vector3(0.15, 0.2, 0.45), vector3(0.0, -90.0, 0.0) }
        }, 
        ['a_c_cormorant'] = {
            headshotBones = { 24818 },
            item = 'carcass_cormorant',
            min = 60,
            max = 600,
            pos = { drag = false, coords = vector3(0.15, 0.2, 0.4), vector3(0.0, -90.0, 0.0) }
        }, 
        ['a_c_coyote'] = {
            headshotBones = { 31086 },
            item = 'carcass_coyote',
            min = 30,
            max = 300,
            pos = { drag = false, coords = vector3(-0.2, 0.15, 0.45), vector3(0.0, -90.0, 0.0) },
        },
        ['a_c_deer'] = {
            headshotBones = { 31086 },
            item = 'carcass_deer',
            min = 50,
            max = 500,
            pos = { drag = true, coords = vector3(0.1, 1.0, -1.2), rotate = vector3(-200.0, 30.0, 0.0) }
        }, 
        ['a_c_mtlion'] = {
            headshotBones = { 31086 },
            item = 'carcass_mtlion',
            min = 80,
            max = 950,
            pos = { drag = true, coords = vector3(0.1, 0.7, -1.0), rotate = vector3(-210.0, 0.0, 0.0) }
        },
        ['carcass_rabbit'] = {
            headshotBones = { 31086 },
            item = 'carcass_rabbit',
            min = 40,
            max = 400,
            pos = { drag = false, coords = vector3(0.12, 0.25, 0.45), rotate = vector3(0.0, 90.0, 0.0) }
        } 
    },

    salepoints      = {
        ['paleto'] = { location = vector3(-69.12, 6249.44, 31.05), radius = 2, payMultiplier = 1, blip = true },
        ['city'] = { location = vector3(963.34, -2115.39, 31.47), radius = 2, payMultipler = 1.5, blip = true }
    },

    goodWeapon      = {
        -728555052, -- GROUP_MELEE
        970310034,  -- GROUP_RIFLE
        860033945,  -- GROUP_SHOTGUN
        -1212426201 -- GROUP_SNIPER
    },

    degrade         = false,

    gradeMultiplier = {
        ['★☆☆'] = 0.5, -- not killed by a goodWeapon
        ['★★☆'] = 1.0, -- killed by a goodWeapon
        ['★★★'] = 2.0 -- headshotBones
    },

    antiFarm        = {
        enable = true, size = 70.0, time = 10 * 60, maxAmount = 3, personal = true
    },
}


function NotifyFunction(source, text, type)
    TriggerClientEvent('QBCore:Notify', source, text, type)
end

function HasHuntingLicense(source)
    -- Pickles Documents
    local idcard = exports.ox_inventory:Search(source, 'slots', 'id_card')
    if idcard then
        for k, v in pairs(idcard) do
            if v.metadata.documentName == "Hunting" then
                return true
            end
        end
        return false
    end
end

function GetCitizenInfo(source)
    -- QbCore
    local player = QBCore.Functions.GetPlayerBySource(source)
    local citizen = {
        citizenid = player.PlayerData.citizenid,
        fullname = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname    
    }
    return citizen
end