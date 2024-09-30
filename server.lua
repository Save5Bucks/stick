local resourceName = GetCurrentResourceName() -- Get the name of the current resource
local url = 'https://raw.githubusercontent.com/Save5Bucks/race-cam/refs/heads/main/fxmanifest.lua'
local localVersion = GetResourceMetadata(resourceName, 'version', 0) -- Read the version from local fxmanifest

-- Function to check the resource version on server start
local function version_check()
    -- Perform HTTP request to get the fxmanifest.lua from the remote GitHub repo
    PerformHttpRequest(
        url,
        function(err, text, headers)
            print('################## SAVE5BUCKS ##################')
            print('[INFO] Performing Update Check for: ' .. resourceName)

            if text ~= nil and err == 200 then
                -- Extract the version from the remote fxmanifest.lua
                local remoteVersion = string.match(text, "version '([%d%.]+)'")

                if remoteVersion then
                    -- Compare the local and remote versions
                    if localVersion == remoteVersion then
                        print('[INFO] ' .. resourceName .. ' is up-to-date (Version: ' .. localVersion .. ').')
                        print('################## SAVE5BUCKS ##################')
                    else
                        print('[WARNING] A newer version of ' .. resourceName .. ' is available!')
                        print('[INFO] Current Version: ' .. localVersion)
                        print('[INFO] Latest Version : ' .. remoteVersion)
                        print('################## SAVE5BUCKS ##################')
                    end
                else
                    print('[ERROR] Unable to find the version number in the remote fxmanifest.lua.')
                    print('################## SAVE5BUCKS ##################')
                end
            else
                print('[ERROR] Unable to retrieve the remote fxmanifest.lua. HTTP Error Code: ' .. tostring(err))
                print('################## SAVE5BUCKS ##################')
            end
        end,
        'GET',
        '',
        ''
    )
end

-- Run the version check when the server starts
AddEventHandler(
    'onResourceStart',
    function(resourceName)
        if GetCurrentResourceName() == resourceName then
            version_check()
        end
    end
)

-- Check transmission type from the database using oxmysql
function checkVehicleTransmission(plate, callback)
    MySQL.query(
        'SELECT transmission FROM player_vehicles WHERE plate = ?',
        {plate},
        function(result)
            if result and result[1] then
                callback(result[1].transmission) -- Pass the transmission type back to the callback
            else
                callback(nil) -- Return nil if no result is found
            end
        end
    )
end

-- Server-side function to check vehicle transmission type from the database using oxmysql
RegisterNetEvent('checkVehicleTransmission')
AddEventHandler(
    'checkVehicleTransmission',
    function(plate)
        local src = source
        -- Use oxmysql to query the database
        MySQL.query(
            'SELECT tmission FROM player_vehicles WHERE plate = ?',
            {plate},
            function(result)
                if result and result[1] then
                    local tmissionValue = result[1].tmission
                    -- Print the raw value of tmission to the server console
                    print('tmission value for plate ' .. plate .. ': ' .. tostring(tmissionValue))

                    -- Check if it's manual (1) or automatic (0), or another value
                    if tmissionValue == true then
                        print('Manual transmission detected for plate: ' .. plate)
                        TriggerClientEvent('receiveTransmissionType', src, true)
                    elseif tmissionValue == false then
                        print('Automatic transmission detected for plate: ' .. plate)
                        TriggerClientEvent('receiveTransmissionType', src, false)
                    else
                        print(
                            'Unknown transmission type for plate: ' .. plate .. ', value: ' .. tostring(tmissionValue)
                        )
                        TriggerClientEvent('receiveTransmissionType', src, false)
                    end
                else
                    print('No result found for plate ' .. plate)
                    TriggerClientEvent('receiveTransmissionType', src, false)
                end
            end
        )
    end
)

-- Export function to set vehicle transmission in the database
-- 0 = automatic, 1 = manual
exports(
    'setVehicleTransmission',
    function(plate, transmissionType)
        MySQL.update(
            'UPDATE player_vehicles SET tmission = ? WHERE plate = ?',
            {transmissionType, plate},
            function(affectedRows)
                if affectedRows > 0 then
                    print(
                        'Transmission type for plate ' ..
                            plate .. ' set to ' .. (transmissionType == 1 and 'Manual' or 'Automatic')
                    )
                else
                    print('No vehicle found with plate: ' .. plate)
                end
            end
        )
    end
)
