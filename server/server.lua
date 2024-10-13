ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function checkIdentfier(identifier)
    for k, v in pairs(Config.Identfier) do
        if identifier == v then
            return true
        end
    end
    return false
end

RegisterServerEvent('mystic:saveVehicle')
AddEventHandler('mystic:saveVehicle', function(vehicleProps)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate) VALUES (@owner, @vehicle, @plate)', {
        ['@owner'] = xPlayer.identifier,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@plate'] = vehicleProps.plate
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vehicle saved!')
        end
    end)
end)

RegisterServerEvent('mystic:broadcastVehicleClaimed')
AddEventHandler('mystic:broadcastVehicleClaimed', function(playerName, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if checkIdentfier(xPlayer.identifier) then
        local msg = "Player " .. playerName .. " found the vehicle"
        TriggerClientEvent('esx:showNotification', -1, msg)
    else
        DropPlayer(source, "nice try :)")
    end
end)


RegisterServerEvent('mystic:startSearch')
AddEventHandler('mystic:startSearch', function(model, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if checkIdentfier(xPlayer.identifier) then
        local msg = "A hidden vehicle has been spawned! Model: " .. model .. ",\nStart searching!"
        TriggerClientEvent('esx:showNotification', -1, msg)
    else
        DropPlayer(source, "nice try :)")
    end
end)


RegisterCommand("creategame", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if checkIdentfier(xPlayer.identifier) then
        TriggerClientEvent("mystic_inputGame", source)
    else
        xPlayer.showNotification("You don't have permission.")
    end
end)


RegisterCommand("activategames", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if checkIdentfier(xPlayer.identifier) then
        TriggerClientEvent("mystic_activateGames", source)
    else
        xPlayer.showNotification("You don't have permission.")
    end
end)