local currentGear = 0
local maxGears = nil
local manualTransmissionActive = false
local vehicle = nil
local MANUAL_TRANSMISSION_FLAGS = 0x400
local AUTOMATIC_TRANSMISSION_FLAGS = 0x200
local isLoggedIn = false

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

-- Handle key presses for shifting gears
CreateThread(
    function()
        while true do
            Wait(0)
            if isLoggedIn then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                if manualTransmissionActive == true then
                    -- GET_ENTITY_SPEED_VECTOR
                    local speedV = GetEntitySpeedVector(vehicle, true)
                    -- print(speedV)
                    local speedMph = getSpeedInMph(vehicle)
                    print(IsControlJustPressed(0, 21))
                    if currentGear ~= 0 and IsControlJustPressed(0, 21) or currentGear == 0 then
                        print('Clutch', IsControlJustPressed(0, 21))
                        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, -1.0)
                    else
                        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
                    end

                    if currentGear >= 0 and speedMph > 0 and speedV.y > 0 then
                        EnableControlAction(0, 72, true) -- Enable S for braking or reverse
                    else
                        DisableControlAction(0, 72, true) -- Disable S for braking or reverse
                    end

                    if currentGear == -1 then
                        EnableControlAction(0, 72, true) -- Enable S for reverse
                        DisableControlAction(0, 71, true) -- Disable W for braking or reverse
                    end

                    -- Tachometer Update
                    if displayRPM then
                        local rpm = (GetVehicleCurrentRpm(vehicle) * 10000) - 1000 -- Convert to RPM
                        SendNUIMessage({action = 'updateRPM', rpm = rpm})
                    end

                    if vehicle ~= 0 and manualTransmissionActive then
                        -- Upshift using Right Shift
                        if IsControlJustPressed(0, Config.UpShiftKey) then
                            Upshift()
                        end
                        -- Downshift using Right Control
                        if IsControlJustPressed(0, Config.DownShiftKey) then
                            DownShift()
                        end
                        --local rpm = (Citizen.InvokeNative(GetHashKey('GET_VEHICLE_DASHBOARD_RPM') & 0xFFFFFFFF, vehicle) / 1000000)
                        --local rpm = mapRPM(rpm)
                        local rpm = (GetVehicleCurrentRpm(vehicle) * 10000) - 1000 -- Convert to RPM
                        SendNUIMessage({type = 'updateRPM', rpm = rpm})
                        sendGearDataToUI()
                        local clutch = Citizen.InvokeNative(GetHashKey('GET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle)
                    -- print(clutch)
                    end

                    -- Exit vehicle handling
                    if manualTransmissionActive and vehicle == 0 then
                        ManualOff()
                    end
                else
                    -- Reset car to automatic
                    SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', AUTOMATIC_TRANSMISSION_FLAGS)
                    EnableControlAction(0, 72, true) -- Enable S for reverse
                    EnableControlAction(0, 71, true) -- Enable W for braking or reverse
                    Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
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
