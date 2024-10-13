ESX = exports["es_extended"]:getSharedObject()

local vehicles = {}

RegisterNetEvent("mystic_inputGame", function()
    local input = lib.inputDialog('Vehicle Game', {
        {type = 'input', label = 'Vehicle Model', description = 'You enter a vehicle name', required = true},
        {type = 'input', label = 'Vehicle Plate', description = 'Enter vehicle plate', required = false},
        {type = 'color', label = 'Vehicle Color', default = '#eb4034'},
        {type="select", label = "Location Spawn", description = "Choose a location spawn for vehicle", required = true,
        options={
          {label = "Easy", value = "easy"},
          {label = "Medium", value = "medium"},
          {label = "Hard", value = "hard"},
        }},
        {type = 'checkbox', label = 'Fulltune'}
    })
  
    if input then
        local model = input[1]
        local plate = input[2] or "MYSTIC"
        local color = input[3]
        local locationLevel = input[4]
        local fulltune = input[5]

        local selectedLocation = nil
        if locationLevel == "easy" then
            selectedLocation = Config.Locations.Easy[math.random(#Config.Locations.Easy)]
        elseif locationLevel == "medium" then
            selectedLocation = Config.Locations.Medium[math.random(#Config.Locations.Medium)]
        elseif locationLevel == "hard" then
            selectedLocation = Config.Locations.Hard[math.random(#Config.Locations.Hard)]
        end

        if selectedLocation then
            local hash = GetHashKey(model)
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(100)
            end
            local vehicle = CreateVehicle(hash, selectedLocation.x, selectedLocation.y, selectedLocation.z, selectedLocation.heading, true, false)
            if input[2] == nil or input[2] == "" then
                print("normal plate")
            else
                SetVehicleNumberPlateText(vehicle, plate)
                print(input[2])
            end
            local r, g, b = HexToRGB(color)
            SetVehicleCustomPrimaryColour(vehicle, r, g, b)
            SetVehicleCustomSecondaryColour(vehicle, r, g, b)

            if fulltune then
                FullTuneVehicle(vehicle)
            end
            FreezeEntityPosition(vehicle, true)
            table.insert(vehicles, {vehicle = vehicle, plate = plate, model = model, color = color, fulltune = fulltune})
            DisplayVehiclePrompt(vehicle, plate)
            --TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            TriggerServerEvent("mystic:startSearch", model, plate)
        end
    end
end)

function HexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function FullTuneVehicle(vehicle)
    SetVehicleModKit(vehicle, 0)
    for i = 0, 49 do
        local modCount = GetNumVehicleMods(vehicle, i)
        if modCount > 0 then
            SetVehicleMod(vehicle, i, modCount - 1, false)
        end
    end
    ToggleVehicleMod(vehicle, 18, true)
    ToggleVehicleMod(vehicle, 22, true)
end

function DisplayVehiclePrompt(vehicle, plate)
    Citizen.CreateThread(function()
        while DoesEntityExist(vehicle) do
            Citizen.Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)

            if distance < 5.0 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to claim the vehicle")

                if IsControlJustPressed(0, 38) then
                    FreezeEntityPosition(vehicle, false)
                    RemoveVehicleFromList(vehicle)
                    SaveVehicleToDatabase(vehicle)
                    break
                end
            end
        end
    end)
end

function RemoveVehicleFromList(vehicle)
    for i, vehicleData in ipairs(vehicles) do
        if vehicleData.vehicle == vehicle then
            table.remove(vehicles, i)
            local playerName = GetPlayerName(PlayerId())
            TriggerServerEvent('mystic:broadcastVehicleClaimed', playerName, vehicleData.plate)
            break
        end
    end
end

function SaveVehicleToDatabase(vehicle)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    TriggerServerEvent('mystic:saveVehicle', vehicleProps)
end

RegisterNetEvent("mystic_activateGames", function()
    if #vehicles == 0 then
        ESX.ShowNotification("There are no active vehicles!")
        return
    end

    local options = {}
    for i, vehicleData in ipairs(vehicles) do
        local desc = "Model: " .. vehicleData.model .. "\nColor: " .. vehicleData.color
        if vehicleData.fulltune then
            desc = desc .. "\nFulltune: Yes"
        else
            desc = desc .. "\nFulltune: No"
        end

        table.insert(options, {
            title = "Vehicle #" .. i,
            description = desc,
            event = "mystic:teleportToVehicle",
            args = {vehicle = vehicleData.vehicle}
        })
    end

    lib.registerContext({
        id = 'active_games_menu',
        title = 'Active Vehicles',
        options = options
    })
    
    lib.showContext('active_games_menu')
end)

RegisterNetEvent('mystic:teleportToVehicle', function(data)
    local vehicle = data.vehicle
    local vehicleCoords = GetEntityCoords(vehicle)

    SetEntityCoords(PlayerPedId(), vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0)
    ESX.ShowNotification("You are teleported to the vehicle!")
end)