Config = {}

-- Add the database name for player_vehicles
Config.DatabaseName = 'proper_rp' -- Replace with your actual database name

-- Key Configuration
Config.UpShiftKey = 27 -- Up Arrow
Config.DownShiftKey = 173 -- Down Arrow
Config.alwaysStick = false -- Set this to true to make all cars manual by default

-- Config for clutch control and redline drag
Config.ClutchKey = 21 -- Default key for the clutch (Shift)
Config.RedlineRPM = 3500 -- RPM threshold where drag is applied (redline)
Config.RedlineDrag = 0.20 -- Amount of drag applied when over redline (0 = no drag, 1 = full drag) simulates engine braking
Config.DragMPH = 50 -- MPH threshold where drag is applied (redline)
Config.maxRpm = 10000 -- Define max RPM here (adjustable based on your setup)

-- EXPORTS TO USE IN OTHER SCRIPTS NO SQL REQUIRED TEMPORARY --

-- Turn on manual transmission --
-- exports['stick']:activateManualTransmission()

-- Turn off manual transmission --
-- exports['stick']:ManualOff()

-- VEHICLE SELLING SCRIPTS USED WITH SQL FILE PERMINANT --
-- Set a vehicle to automatic transmission (0) --

--local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
--local plate = GetVehicleNumberPlateText(vehicle)
--exports['stick']:setVehicleTransmission(plate, 0)

-- Set a vehicle to manual transmission (1) --

--local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
--local plate = GetVehicleNumberPlateText(vehicle)
--exports['stick']:setVehicleTransmission(plate, 1)

-- MAKE SURE YOU CHECK WHICH SQL SRIPT YOU ARE USING AND UPDATE THE FXMANIFEST.LUA FILE --

--server_scripts {
--    '@mysql-async/lib/MySQL.lua', -- Or '@oxmysql/lib/MySQL.lua' for oxmysql
--    'server.lua'
--}
