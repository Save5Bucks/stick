local QBCore = exports['qb-core']:GetCoreObject()

local currentGear = 0
local maxGears = nil
local manualTransmissionActive = false
local vehicle = nil
local MANUAL_TRANSMISSION_FLAGS = 0x400
local AUTOMATIC_TRANSMISSION_FLAGS = 0x200
local checkPlate = false -- Flag to avoid repeated checks
local displayRPM = true -- Ensure RPM display is active
local alwaysStickActive = false -- Toggle for alwaysStick activation

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

-- Check the vehicle's transmission based on its plate
function checkVehicleTransmission(plate)
    TriggerServerEvent('checkVehicleTransmission', plate) -- Call the server to check the transmission type by plate
end

-- Receive the transmission type from the server
RegisterNetEvent('receiveTransmissionType')
AddEventHandler(
    'receiveTransmissionType',
    function(isManual)
        if isManual then
            activateManualTransmission() -- Make sure the transmission is activated properly
        else
            ManualOff()
        end
    end
)

-- Fetch and validate the plate
function validateAndCheckPlate(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    Wait(100) -- Wait for the plate to be fetched properly
    -- Ensure the plate is valid and has been fetched properly
    if plate and plate ~= '' and string.len(plate) > 0 then
        checkVehicleTransmission(plate) -- Check the transmission type from the server
        print('Plate found: ' .. plate)
        checkPlate = true -- Mark the plate check as done
    else
        print('Error: No valid plate detected.')
        checkPlate = false
    end
end

-- Handle transmission control logic
function handleTransmissionControl()
    local speedV = GetEntitySpeedVector(vehicle, true)
    local speedMph = getSpeedInMph(vehicle)
    local rpm = GetVehicleCurrentRpm(vehicle) * 10000 -- Convert to RPM

    -- Clutch control for shift key and throttle to max revs
    if IsControlPressed(0, Config.ClutchKey) and IsControlPressed(0, 71) then -- Clutch and "W" key are pressed
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CURRENT_RPM') & 0xFFFFFFFF, vehicle, Config.maxRpm / 10000) -- Rev to max RPM
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, -1.0)
    elseif IsControlPressed(0, Config.ClutchKey) then
        -- Disengage clutch when shift key is held
    elseif IsControlReleased(0, Config.ClutchKey) and IsControlPressed(0, 71) then
        -- Re-engage clutch and allow the vehicle to move forward when W is pressed
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0)
    end

    -- Apply drag when RPM exceeds redline, speed is over Config.DragMPH, and W isn't pressed
    if rpm > Config.RedlineRPM and speedMph > Config.DragMPH and not IsControlPressed(0, 71) then -- 71 is the control for "W" (throttle)
        local dragAmount = Config.RedlineDrag
        -- Apply gentle drag using ApplyForceToEntity
        ApplyForceToEntity(vehicle, 1, 0.0, -dragAmount, 0.0, 0.0, 0.0, false, true, true, false, true)
    end

    -- Clutch control for currentGear = 0
    if currentGear == 0 then
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, -1.0)
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
        SendNUIMessage({type = 'updateRPM', rpm = rpm})
    end

    -- Handle gear shifts using Config
    if IsControlJustPressed(0, Config.UpShiftKey) then
        Upshift()
    elseif IsControlJustPressed(0, Config.DownShiftKey) then
        DownShift()
    end

    -- Send gear data and update RPM
    sendGearDataToUI()
end

-- Upshift gear
function Upshift()
    if vehicle and DoesEntityExist(vehicle) and manualTransmissionActive and maxGears then
        if currentGear < maxGears then
            currentGear = currentGear + 1
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
            Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, currentGear)
            sendGearDataToUI() -- Update the UI
        end
    end
end

-- Send gear and RPM data to the UI
function sendGearDataToUI()
    if vehicle and DoesEntityExist(vehicle) then
        local rpm = GetVehicleCurrentRpm(vehicle) * 10000 - 1000 -- Convert to RPM and send it to the UI
        SendNUIMessage(
            {
                type = 'show', -- Correct type for showing UI data
                maxGears = maxGears,
                currentGear = currentGear,
                rpm = rpm
            }
        )
    end
end

-- Show gear UI
function showUI()
    SendNUIMessage({type = 'show'}) -- Ensure this message shows the UI
end

-- Hide gear UI
function hideUI()
    SendNUIMessage({type = 'hide'}) -- Ensure this message hides the UI
end

-- Activate manual transmission
function activateManualTransmission()
    manualTransmissionActive = true
    vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        fetchMaxGearsFromVehicle()
        setManualTransmissionFlag()
        Citizen.InvokeNative(GetHashKey('SET_VEHICLE_CLUTCH') & 0xFFFFFFFF, vehicle, 1.0) -- Ensure clutch is engaged for movement
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

-- EXPORTS TO USE IN OTHER SCRIPTS NO SQL REQUIRED --
exports('activateManualTransmission', activateManualTransmission)
exports('ManualOff', ManualOff)

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

-- Handle key presses for shifting gears and clutch management
CreateThread(
    function()
        while true do
            Wait(0)
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            -- Check if player is the driver
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                -- If alwaysStick is true, activate manual transmission for all vehicles
                if Config.alwaysStick then
                    if not manualTransmissionActive and not alwaysStickActive then
                        activateManualTransmission() -- Force manual transmission for all vehicles
                        alwaysStickActive = true
                        manualTransmissionActive = true
                        sendGearDataToUI() -- Update UI immediately when activated
                    end
                    -- Call transmission control to handle clutch, gears, and display updates
                    handleTransmissionControl()
                else
                    -- Ensure the vehicle exists and plate check hasn't been done
                    if not checkPlate then
                        validateAndCheckPlate(vehicle) -- Check the vehicle's plate
                    end

                    -- Handle transmission if it's already active
                    if manualTransmissionActive then
                        handleTransmissionControl() -- Call the new function to manage clutch, gears, and display updates
                    end
                end
            else
                -- Player is not in the driver's seat or has left the vehicle
                if manualTransmissionActive or alwaysStickActive then
                    ManualOff() -- Ensure transmission is deactivated and UI is hidden when leaving the vehicle
                    checkPlate = false
                    alwaysStickActive = false
                end
            end
        end
    end
)

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
