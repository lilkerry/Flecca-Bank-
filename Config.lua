Config = {}

-- Bank Locations
Config.Banks = {
    {
        id = 1,
        label = 'Flecca Bank - Del Perro',
        coords = vector3(149.54, -1040.86, 29.37),
        heading = 340.0,
        vault_coords = vector3(146.75, -1044.73, 29.37),
        safe_coords = vector3(147.5, -1043.0, 29.37),
        difficulty = 'easy',
    },
    {
        id = 2,
        label = 'Flecca Bank - Downtown',
        coords = vector3(255.41, 225.1, 101.88),
        heading = 160.0,
        vault_coords = vector3(258.15, 221.53, 101.88),
        safe_coords = vector3(257.0, 222.5, 101.88),
        difficulty = 'medium',
    },
    {
        id = 3,
        label = 'Flecca Bank - Pillbox',
        coords = vector3(1175.73, -326.29, 69.2),
        heading = 0.0,
        vault_coords = vector3(1179.54, -329.73, 69.2),
        safe_coords = vector3(1178.0, -328.5, 69.2),
        difficulty = 'hard',
    },
}

-- Robbery Settings
Config.Robbery = {
    minPolice = 2,
        maxPolice = 10,
    minCrew = 2,
    maxCrew = 4,
    cooldown = 30 * 60 * 1000, -- 30 minutes in milliseconds
    reward_per_player = 5000,
    alarm_delay = 5000, -- 5 seconds before alarm triggers
    police_response_time = 30, -- seconds
    lockpick_difficulty = 50, -- 1-100
}

-- Hack Settings
Config.Hacking = {
    time_limit = 60, -- seconds
    min_correct = 3,
    difficulty = 'medium', -- easy, medium, hard
}

-- Drill Settings
Config.Drilling = {
    time_limit = 90, -- seconds
    heat_increase = 1.5,
    max_heat = 100,
}

-- Animations
Config.Animations = {
    hack = {
        dict = 'anim@heists@diamond@safe',
        clip = 'hack_loop',
    },
    crack = {
        dict = 'anim@heists@diamond@safe',
        clip = 'hack_loop',
    },
    drill = {
        dict = 'anim@heists@diamond@safe',
        clip = 'hack_loop',
    },
}

-- Loot
Config.Loot = {
    {
        item = 'money_bag',
        label = 'Money Bag',
        amount = {min = 1000, max = 2500},
        weight = 1000,
    },
    {
        item = 'dirty_money',
        label = 'Dirty Cash',
        amount = {min = 1500, max = 3500},
        weight = 1500,
    },
    {
        item = 'gold_bar',
        label = 'Gold Bar',
        amount = {min = 2, max = 5},
        weight = 500,
    },
    {
        item = 'diamond',
        label = 'Diamond',
        amount = {min = 1, max = 3},
        weight = 100,
    },
}

-- Police Job
Config.PoliceJob = 'police'

-- Command Settings
Config.Commands = {
    start_robbery = 'bankrobbery',
    test_heist = 'bankrobberytest',
}

-- Notifications
Config.Notifications = {
    success = 'success',
    error = 'error',
    info = 'info',
    warning = 'warning',
}

-- Debug Mode
Config.Debug = false
