ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

-----------------------------------------------------------------
local display = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 10) then
            ShowHideMDT(not display)
        end
    end
end)

RegisterCommand('mdt', function (source)
    ShowHideMDT(not display)
end)

function ShowHideMDT(visible)
    local job = PlayerData.job.name
    if job == 'police' then
        SetNuiFocus(visible, visible)
        SendNUIMessage({
            type = 'nui',
            status = visible
        })
    else
        ESX.ShowNotification(_U('not_police'))
    end
end

RegisterNUICallback('exit', function ()
    ShowHideMDT(false)
end)

RegisterNUICallback('searchperson', function (data,cb)
    TriggerServerEvent('duckymdt:searchPerson', data.query)
    cb('ok')
end)

RegisterNUICallback('searchvehicle', function (data, cb)
    TriggerServerEvent('duckymdt:searchVehicle', data.query)
    cb('ok')
end)

RegisterNetEvent('duckymdt:returnSearchPerson')
AddEventHandler('duckymdt:returnSearchPerson', function (results)
    SendNUIMessage({
        type = "returnedPersonMatches",
        matches = results
    })
end)

RegisterNetEvent('duckymdt:returnSearchVehicle')
AddEventHandler('duckymdt:returnSearchVehicle', function (identifier, firstname, lastname, vehicleHash)
    local vehicleModel = GetDisplayNameFromVehicleModel(vehicleHash)
    SendNUIMessage({
        type = 'returnedPersonVehicles',
        identifier = identifier,
        firstname = firstname,
        lastname = lastname,
        vehicleModel = vehicleModel
    })
end)

RegisterNUICallback('persondatasheet', function (data, cb)
    TriggerServerEvent('duckymdt:searchPersonDatasheet', data.identifier)
    cb('ok')
end)


RegisterNetEvent('duckymdt:returnSearchPersonDatasheet')
AddEventHandler('duckymdt:returnSearchPersonDatasheet', function (result, fines, vehicleList, licenses)
    local vehicle
    for i = 1, #vehicleList do
        vehicle = json.decode(vehicleList[i].vehicle)
        vehicleList[i].model = GetDisplayNameFromVehicleModel(vehicle.model)
    end
    SendNUIMessage({
        type = 'returnedSearchPersonDatasheet',
        result = result,
        fines = fines,
        vehicleList = vehicleList,
        licenses = licenses
    })
end)

RegisterNUICallback('changeimage', function(data, cb)
    SetNuiFocus(false, false)
    local url

    if Config.enableCamera then
        CreateMobilePhone(1)
        CellCamActivate(true, true)
        takePhoto = true
        Citizen.Wait(0)
        while takePhoto do
            Citizen.Wait(0)

            if IsControlJustPressed(1, 177) then -- CANCEL PHOTO (BACKSPACE, RIGHT MOUSE CLICK)
                DestroyMobilePhone()
                CellCamActivate(false, false)
                cb(json.encode({ url = nil }))
                takePhoto = false
            break
            elseif IsControlJustPressed(1, 176) then -- TAKE PHOTO (ENTER KEY)
                    exports['screenshot-basic']:requestScreenshotUpload(Config.urlhandler, 'files[]', function(dataimage)
                local image = json.decode(dataimage)
                DestroyMobilePhone()
                CellCamActivate(false, false)
                url = image.attachments[1].proxy_url
            end)
            takePhoto = false
            end
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(19)
            HideHudAndRadarThisFrame()
        end
        Citizen.Wait(1000)

    else
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "https://i.gyazo.com/5b16c8a0a300ff1f8767c14acbb0504c.png", "", "", "", 64)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            url =  GetOnscreenKeyboardResult()
        end
    end

    if url ~= '' and url ~= nil then
        TriggerServerEvent('duckymdt:changeMugshotImage', data.identifier, url)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'updatedMugshotImage',
            url = url
        })
    else
        ESX.ShowNotification(_U('invalid_link'))
    end
end)



RegisterNUICallback('removefine', function (data, cb)
    TriggerServerEvent('duckymdt:removeFine', data.fine)
    SendNUIMessage({
        type = 'removedFine'
    })
    ESX.ShowNotification(_U('deleted_antecedent'))
    cb('ok')
end)

RegisterNUICallback('changeriskiness', function (data, cb)
    TriggerServerEvent('duckymdt:changeRiskiness', data.identifier, data.newRiskiness)
    SendNUIMessage({
        type = 'changedRiskiness'
    })
    cb('ok')
end)

RegisterNUICallback('removelicence', function (data, cb)
    TriggerServerEvent('duckymdt:removeLicence', data.identifier, data.licence)
    SendNUIMessage({
        type = 'removedLicence'
    })
    ESX.ShowNotification(_U('deleted_licence'))
    cb('ok')
end)

RegisterNUICallback('requestallfines', function (data, cb)
    TriggerServerEvent('duckymdt:requestAllFines')
    cb('ok')
end)

RegisterNetEvent('duckymdt:returnAllFines')
AddEventHandler('duckymdt:returnAllFines', function (fines)
    SendNUIMessage({
        type = 'returnAllFines',
        fines = fines
    })
end)

RegisterNUICallback('addfine', function (data, cb)
    TriggerServerEvent('duckymdt:addFinetoPlayer', data.identifier, data.name, data.fine)
    cb('ok')
end)

RegisterNetEvent('duckymdt:addBilltoPlayer')
AddEventHandler('duckymdt:addBilltoPlayer', function (playerId, charge, amount)
    TriggerServerEvent('esx_billing:sendBill', playerId, 'society_police', charge, amount)
end)

RegisterNUICallback('requestnotes', function (data, cb)
    TriggerServerEvent('duckymdt:requestNotesofPerson', data.identifier)
    cb('ok')
end)

RegisterNetEvent('duckymdt:returnNotesofPerson')
AddEventHandler('duckymdt:returnNotesofPerson', function (notes)
    SendNUIMessage({
        type = 'returnedNotesofPerson',
        notes = notes
    })
end)

RegisterNUICallback('removenote', function (data, cb)
    TriggerServerEvent('duckymdt:removeNote', data.note)
    SendNUIMessage({
        type = 'removedNote'
    })
    ESX.ShowNotification(_U('deleted_note'))
    cb('ok')
end)

RegisterNUICallback('createnote', function (data, cb)
    TriggerServerEvent('duckymdt:createNote', data.identifier, data.firstname, data.lastname, data.note)
    SendNUIMessage({
        type = 'addedNote'
    })
    ESX.ShowNotification(_U('created_note'))
    cb('ok')
end)