Config = {}

Config.carcass  = {
    [-832573324]=           'carcass_boar', --a_c_boar
    [-1430839454] =   'carcass_hawk', --a_c_chickenhawk
    [1457690978] =     'carcass_cormorant', --a_c_cormorant
    [1682622302] =        'carcass_coyote', --a_c_coyote
    [-664053099] =          'carcass_deer', --a_c_deer
    [307287994] =        'carcass_mtlion', --a_c_mtlion
    [-541762431] =     'carcass_rabbit' --a_c_rabbit_01
}

Config.salepoints = {
    ['paleto'] = {location = vector3(-69.12, 6249.44, 31.05), radius = 2},
    ['city'] = {location = vector3(963.34, -2115.39, 31.47), radius = 1}
}

Config.carcassPos  = {
    [-832573324]=     {drag = true, xPos = -0.7, yPos = 1.2, zPos = -1.0, xRot = -200.0, yRot = 0.0, zRot = 0.0},
    [-1430839454] =   {drag = false, xPos = 0.15, yPos = 0.2, zPos = 0.45, xRot = 0.0, yRot = -90.0, zRot = 0.0},
    [1457690978] =    {drag = false, xPos = 0.15, yPos = 0.2, zPos = 0.4, xRot = 0.0, yRot = -90.0, zRot = 0.0},
    [1682622302] =    {drag = false, xPos = -0.2, yPos = 0.15, zPos = 0.45, xRot = 0.0, yRot = -90.0, zRot = 0.0},
    [-664053099] =    {drag = true, xPos = 0.1, yPos = 1.0, zPos = -1.2, xRot = -200.0, yRot = 30.0, zRot = 0.0},
    [307287994] =     {drag = true, xPos = 0.1, yPos = 0.7, zPos = -1.0, xRot = -210.0, yRot = 0.0, zRot = 0.0},
    [-541762431] =    {drag = false, xPos = 0.12, yPos = 0.25, zPos = 0.45, xRot = 0.0, yRot = 90.0, zRot = 0.0},
}

Config.goodWeapon = {
    -1466123874, -- Musket
    10041652, -- Sniper 10041652
    -952879014, -- Marksman Rifle
    1785463520, -- Marksman Rifle Mk2
    -1716189206, -- Knife
    -2084633992, -- Carbine RIfle
    487013001, -- Pump Shotgun
}


Config.sellPrice = {
    ['carcass_boar'] =      {min = 150,max = 1000}, -- min = 0 durability   max = 100 durability
    ['carcass_hawk'] =      {min = 200,max = 1200},
    ['carcass_cormorant'] = {min = 60,max = 600},
    ['carcass_coyote'] =    {min = 30,max = 300},
    ['carcass_deer'] =      {min = 50,max = 500},
    ['carcass_mtlion'] =    {min = 80,max = 950},
    ['carcass_rabbit'] =    {min = 40,max = 400}
}

Config.degrade = false

Config.gradeMultiplier = {
    ['★☆☆'] = 0.5, -- not killed by a goodWeapon
    ['★★☆'] = 1.0, -- killed by a goodWeapon
    ['★★★'] = 2.0  -- headshot
}

Config.headshotBones = {
    [-832573324] =    {31086},
    [-1430839454] =   {39317},
    [1457690978] =    {24818},
    [1682622302] =    {31086},
    [-664053099] =    {31086},
    [307287994] =     {31086},
    [-541762431] =    {31086}
}

Config.antiFarm = {
    enable = true, size = 70.0, time = 10 * 60, maxAmount = 3, personal = true
}
