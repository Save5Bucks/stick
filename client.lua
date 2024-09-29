local QBCore = exports['qb-core']:GetCoreObject()

local currentGear = 0
local maxGears = nil
local manualTransmissionActive = false
local vehicle = nil
local MANUAL_TRANSMISSION_FLAGS = 0x400
local AUTOMATIC_TRANSMISSION_FLAGS = 0x200
local isLoggedIn = true

-- Fetch max gears from vehicle's handling data
function fetchMaxGearsFromVehicle()
    if vehicle and DoesEntityExist(vehicle) then
        maxGears = GetVehicleHandlingInt(vehicle, 'CHandlingData', 'nInitialDriveGears')
        currentGear = 0 -- Start at 0
        sendGearDataToUI() -- Update UI with gear
    end
end

-- Set manual transmission flag
function setManualTransmissionFlag()
    if vehicle and DoesEntityExist(vehicle) then
        SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', MANUAL_TRANSMISSION_FLAGS)
        print('Vehicle transmission set to manual.')
    end
end

-- Upshift gear
function Upshift()
    if vehicle and DoesEntityExist(vehicle) and manualTransmissionActive and maxGears then
        if currentGear < maxGears then
            currentGear = currentGear + 1
            print(currentGear)
            Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, currentGear)
            sendGearDataToUI() -- Update the UI
        end
    end
end

-- Downshift gear
function DownShift()
    if vehicle and DoesEntityExist(vehicle) and manualTransmissionActive then
        if currentGear > -1 then
            currentGear = currentGear - 1
            print(currentGear)
            Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, currentGear)
            sendGearDataToUI() -- Update the UI
        end
    end
end

-- Send gear and RPM data to the UI
function sendGearDataToUI()
    SendNUIMessage(
        {
            type = 'show',
            maxGears = maxGears,
            currentGear = currentGear,
            rpm = GetVehicleCurrentRpm(vehicle) * 10000 - 1000 -- Convert to RPM and send it to the UI
        }
    )
end

-- Show gear UI
function showUI()
    SendNUIMessage({type = 'show'})
end

-- Hide gear UI
function hideUI()
    SendNUIMessage({type = 'hide'})
end

-- Activate manual transmission
function activateManualTransmission()
    manualTransmissionActive = true
    vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        fetchMaxGearsFromVehicle()
        setManualTransmissionFlag()
        showUI() -- Ensure UI is shown when manual transmission is activated
        print('Manual transmission activated.')
    else
        print('No vehicle detected.')
        manualTransmissionActive = false
    end
end

-- Deactivate manual transmission
function ManualOff()
    if vehicle and DoesEntityExist(vehicle) then
        SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', AUTOMATIC_TRANSMISSION_FLAGS)
        EnableControlAction(0, 72, true) -- Enable S for reverse
        EnableControlAction(0, 71, true) -- Enable W for braking or reverse
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
    end
    manualTransmissionActive = false
    hideUI() -- Ensure UI is hidden
    print('Manual transmission deactivated.')
end

-- Toggle manual transmission
RegisterCommand(
    'stick',
    function()
        if manualTransmissionActive then
            ManualOff()
            hideUI()
        else
            activateManualTransmission()
        end
    end
)

-- Toggle manual transmission
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler(
    'QBCore:Client:OnPlayerLoaded',
    function()
        isLoggedIn = true
    end
)

-- Handle key presses for shifting gears and clutch management
CreateThread(
    function()
        while true do
            Wait(0)
            if isLoggedIn then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                -- Ensure the vehicle exists and manual transmission is active
                if vehicle ~= 0 and manualTransmissionActive then
                    -- Get current speed and speed vector
                    local speedV = GetEntitySpeedVector(vehicle, true)
                    local speedMph = getSpeedInMph(vehicle)

                    if currentGear == 0 then
                        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 0.0)
                    end

                    -- Clutch control
                    if currentGear ~= 0 then
                        -- Clutch should engage when UpShiftKey is pressed
                        if IsControlJustPressed(0, 21) then
                            print('Clutch pressed')
                            Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 0.0)
                        elseif IsControlJustReleased(0, 21) then
                            Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
                        end
                    end

                    -- Enable or disable controls based on gear and speed
                    if currentGear >= 0 and speedMph > 0 and speedV.y > 0 then
                        EnableControlAction(0, 72, true) -- Enable S for braking or reverse
                    else
                        DisableControlAction(0, 72, true) -- Disable S for braking or reverse
                    end

                    -- Special case for reverse gear
                    if currentGear == -1 then
                        EnableControlAction(0, 72, true) -- Enable S for reverse
                        DisableControlAction(0, 71, true) -- Disable W for braking or reverse
                    end

                    -- Tachometer and gear display update
                    if displayRPM then
                        local rpm = (GetVehicleCurrentRpm(vehicle) * 10000) - 1000 -- Convert to RPM
                        SendNUIMessage({action = 'updateRPM', rpm = rpm})
                    end

                    -- Handle gear shifts
                    if IsControlJustPressed(0, Config.UpShiftKey) then
                        Upshift()
                    elseif IsControlJustPressed(0, Config.DownShiftKey) then
                        DownShift()
                    end

                    -- Send gear data and update RPM
                    local rpm = (GetVehicleCurrentRpm(vehicle) * 10000) - 1000 -- Convert to RPM
                    SendNUIMessage({type = 'updateRPM', rpm = rpm})
                    sendGearDataToUI()
                elseif manualTransmissionActive then
                    -- Exit vehicle handling: deactivate manual transmission when not in a vehicle
                    if vehicle == 0 then
                        ManualOff()
                    else
                        -- Reset car to automatic transmission
                        SetVehicleHandlingInt(
                            vehicle,
                            'CCarHandlingData',
                            'strAdvancedFlags',
                            AUTOMATIC_TRANSMISSION_FLAGS
                        )
                        EnableControlAction(0, 72, true) -- Enable S for reverse
                        EnableControlAction(0, 71, true) -- Enable W for braking or reverse
                        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
                    end
                end
            end
        end
    end
)

function mapRPM(actualRPM)
    --- Define the min and max values for actual RPM and target percentage range
    local minActualRPM = 1037.5
    local maxActualRPM = 1068
    local minTarget = 0
    local maxTarget = 9000

    -- Ensure the actualRPM is within the defined range to avoid errors
    if actualRPM < minActualRPM then
        actualRPM = minActualRPM
    elseif actualRPM > maxActualRPM then
        actualRPM = maxActualRPM
    end

    -- Calculate the mapped value based on the formula
    local mappedValue =
        ((actualRPM - minActualRPM) / (maxActualRPM - minActualRPM)) * (maxTarget - minTarget) + minTarget

    -- Return the result
    return mappedValue
end

-- Get vehicle speed in meters per second
function getVehicleSpeed(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        return GetEntitySpeed(vehicle) -- Speed in meters per second
    else
        return 0.0 -- Return 0 if no vehicle found
    end
end

-- Convert speed from meters per second to miles per hour (mph)
function getSpeedInMph(vehicle)
    local speedMps = getVehicleSpeed(vehicle)
    return speedMps * 2.23694 -- 1 meter per second = 2.23694 mph
end
