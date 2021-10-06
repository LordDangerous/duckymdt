ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('duckymdt:searchPerson')
AddEventHandler('duckymdt:searchPerson', function (person)
    local _source = source
    local result = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE UPPER(`firstname`) = UPPER(@person) OR UPPER(`lastname`) = UPPER(@person) OR CONCAT(UPPER(`firstname`), ' ', UPPER(`lastname`)) = UPPER(@person)", {
        ['@person'] = person
    })

    local jobs = MySQL.Sync.fetchAll("SELECT * FROM `jobs`")

    for i = 1, #result do
        for j = 1, #jobs do
            if jobs[j].name == result[i].job then
                result[i].job = jobs[j].label
            end
        end
    end

    TriggerClientEvent('duckymdt:returnSearchPerson', _source, result)
end)


RegisterNetEvent('duckymdt:searchVehicle')
AddEventHandler('duckymdt:searchVehicle', function (vehicleplate)
    local _source = source
    local vehiclePlateSeparated = {}
    local vehiclePlateLetters
    local vehiclePlateNumber
    local vehiclePlateCheckSpaceLetters = string.sub(vehicleplate, 1, 3)
    local vehiclePlateCheckSpaceNumber = string.sub(vehicleplate, 4, 7)

    for i in string.gmatch(vehicleplate, "%S+") do
        table.insert(vehiclePlateSeparated, i)
    end

    vehiclePlateLetters = vehiclePlateSeparated[1]
    vehiclePlateNumber = vehiclePlateSeparated[2]

    local result = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `plate` = @vehicleplate OR `plate` = CONCAT(UPPER(@vehiclePlateLetters), ' ', @vehiclePlateNumber) OR `plate` = CONCAT(UPPER(@vehiclePlateCheckSpaceLetters), ' ', @vehiclePlateCheckSpaceNumber)", {
        ['@vehicleplate'] = vehicleplate,
        ['@vehiclePlateLetters'] = vehiclePlateLetters,
        ['@vehiclePlateNumber'] = vehiclePlateNumber,
        ['@vehiclePlateCheckSpaceLetters'] = vehiclePlateCheckSpaceLetters,
        ['@vehiclePlateCheckSpaceNumber'] = vehiclePlateCheckSpaceNumber
    })

    local owner = nil
    local vehicle = nil
    local vehicleHash = nil

    for i = 1, #result do
        owner = result[1].owner
        vehicle = json.decode(result[1].vehicle)
        vehicleHash = vehicle.model
    end
    
    local name = MySQL.Sync.fetchAll("SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = @owner", {
        ['@owner'] = owner
    })

    local firstname = nil
    local lastname = nil

    for i = 1, #name do
        firstname = name[1].firstname
        lastname = name[1].lastname
    end

    TriggerClientEvent('duckymdt:returnSearchVehicle', _source, owner, firstname, lastname, vehicleHash)
end)

RegisterNetEvent('duckymdt:searchPersonDatasheet')
AddEventHandler('duckymdt:searchPersonDatasheet', function (identifier)
    local _source = source
    local vehicleList
    local licenses = nil

    local result = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })

    local mugshoturl = MySQL.Sync.fetchAll("SELECT `mugshot_url` FROM `mdt_profile` WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })

    vehicleList = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier", {
        ['@identifier'] = identifier
    })

    local jobs = MySQL.Sync.fetchAll("SELECT * FROM `jobs`")

    for i = 1, #result do
        if mugshoturl[1] then
            result[i].mugshot_url = mugshoturl[i].mugshot_url
        else
            result[i].mugshot_url = Config.defaultMugshot
        end
        for j = 1, #jobs do
            if jobs[j].name == result[i].job then
                result[i].job = jobs[j].label
            end
        end
    end

    local fines = MySQL.Sync.fetchAll("SELECT * FROM `mdt_fines` WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })

    licenses = MySQL.Sync.fetchAll("SELECT * FROM `user_licenses` WHERE `owner` = @identifier", {
        ['@identifier'] = identifier
    })

    local licenseslabel = MySQL.Sync.fetchAll("SELECT * FROM `licenses`")

    for i = 1, #licenses do
        for j = 1, #licenseslabel do
            if licenses[i].type == licenseslabel[j].type then
                licenses[i].label = licenseslabel[j].label
            end
        end
    end

    TriggerClientEvent('duckymdt:returnSearchPersonDatasheet', _source, result, fines, vehicleList, licenses)
end)


RegisterNetEvent('duckymdt:changeMugshotImage')
AddEventHandler('duckymdt:changeMugshotImage', function (identifier, url)
    local result = MySQL.Sync.fetchAll("SELECT * FROM `mdt_profile` WHERE identifier=@identifier", {
        ['@identifier'] = identifier
    })
    if result[1] then
        MySQL.Async.execute("UPDATE mdt_profile SET mugshot_url = @mugshot_url WHERE identifier=@identifier", {
            ['@mugshot_url'] = url,
            ['@identifier'] = identifier
        })
    else
        MySQL.Async.execute("INSERT INTO mdt_profile (identifier, mugshot_url) VALUES (@identifier, @mugshot_url)", {
            ['@identifier'] = identifier,
            ['@mugshot_url'] = url
        })
    end
end)

RegisterNetEvent('duckymdt:removeFine')
AddEventHandler('duckymdt:removeFine', function (fine)
    MySQL.Async.execute("DELETE FROM `mdt_fines` WHERE charge=@charge AND id=@id", {
        ['@charge'] = fine.charge,
        ['@id'] = fine.id
    })
end)

RegisterNetEvent('duckymdt:changeRiskiness')
AddEventHandler('duckymdt:changeRiskiness', function (identifier, newRiskiness)
    MySQL.Async.execute("UPDATE `users` SET riskiness = @newRiskiness WHERE identifier = @identifier", {
        ['@newRiskiness'] = newRiskiness,
        ['@identifier'] = identifier
    })
end)

RegisterNetEvent('duckymdt:removeLicence')
AddEventHandler('duckymdt:removeLicence', function (identifier, licence)
    MySQL.Async.execute("DELETE FROM `user_licenses` WHERE type=@licence AND owner=@identifier", {
        ['@licence'] = licence.type,
        ['@identifier'] = identifier
    })
end)

RegisterNetEvent('duckymdt:requestAllFines')
AddEventHandler('duckymdt:requestAllFines', function ()
    local _source = source
    local fines = MySQL.Sync.fetchAll("SELECT * FROM `fine_types")
    TriggerClientEvent('duckymdt:returnAllFines', _source, fines)
end)

RegisterNetEvent('duckymdt:addFinetoPlayer')
AddEventHandler('duckymdt:addFinetoPlayer', function(identifier, name, fine)
    local _source = source

    local amount = fine.amount
    local finded = false

    for _, playerId in ipairs(GetPlayers()) do
        local possibleName = GetPlayerName(playerId)
        if possibleName == name then
            finded = true
            MySQL.Async.execute("INSERT INTO `mdt_fines` (identifier, charge, amount) VALUES (@identifier, @charge, @amount)", {
                ['@identifier'] = identifier,
                ['@charge'] = fine.label,
                ['@amount'] = fine.amount
            })
            TriggerClientEvent('duckymdt:addBilltoPlayer', _source, playerId, fine.label, amount)
            TriggerClientEvent('esx:showNotification', _source, _U('added_fine'))
        end
    end
    if not finded then
        TriggerClientEvent('esx:showNotification', _source, _U('error_adding_fine'))
    end
end)

RegisterNetEvent('duckymdt:requestNotesofPerson')
AddEventHandler('duckymdt:requestNotesofPerson', function (identifier)
    local _source = source
    local result = MySQL.Sync.fetchAll("SELECT * FROM `mdt_notes` WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })

    TriggerClientEvent('duckymdt:returnNotesofPerson', _source, result)
end)

RegisterNetEvent('duckymdt:removeNote')
AddEventHandler('duckymdt:removeNote', function (note)
    MySQL.Async.execute("DELETE FROM `mdt_notes` WHERE note = @note", {
        ['@note'] = note.note
    })
end)

RegisterNetEvent('duckymdt:createNote')
AddEventHandler('duckymdt:createNote', function (identifier, firstname, lastname, note)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local steamName = xPlayer.getName()
    local name = MySQL.Sync.fetchAll("SELECT `firstname`, `lastname` FROM `users` WHERE name=@name", {
        ['@name'] = steamName
    })
    local agentfirstname = name[1].firstname
    local agentlastname = name[1].lastname
    local agent = agentfirstname .. " " .. agentlastname
    local author = firstname .. " " .. lastname
    local date = os.date('%d-%m-%Y %H:%M:%S', os.time())
    
    MySQL.Async.execute("INSERT INTO `mdt_notes` (identifier, name, note, agent, date) VALUES (@identifier, @name, @note, @agent, @date)", {
        ['@identifier'] = identifier,
        ['@name'] = author,
        ['@note'] = note,
        ['@agent'] = agent,
        ['@date'] = date
    })
end)