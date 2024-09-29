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
