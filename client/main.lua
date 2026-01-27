local QBCore = exports['qb-core']:GetCoreObject()
local isPlayingAnimation = false
local currentAnimDict = nil
local currentAnimName = nil

-- Function to load animation dictionary
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Function to play animation
local function PlayAnimation(animInput)
    local playerPed = PlayerPedId()
    
    -- Convert input to uppercase for scenario checking
    local animUpper = string.upper(animInput)
    
    -- Check if it's a scenario (these start with WORLD_HUMAN_ or PROP_HUMAN_)
    if string.match(animUpper, "^WORLD_HUMAN_") or 
       string.match(animUpper, "^PROP_HUMAN_") or
       string.match(animUpper, "^WORLD_") then
        -- It's a scenario - try to play it
        ClearPedTasks(playerPed)
        TaskStartScenarioInPlace(playerPed, animUpper, 0, true)
        
        -- Give it a moment to start
        Wait(100)
        
        -- Check if the scenario is actually playing
        if IsPedUsingScenario(playerPed, animUpper) or GetIsTaskActive(playerPed, 118) then
            isPlayingAnimation = true
            currentAnimDict = animUpper
            currentAnimName = nil
            QBCore.Functions.Notify('Playing scenario: ' .. animUpper, 'success')
            return true
        else
            ClearPedTasks(playerPed)
            QBCore.Functions.Notify('Animation does not exist: ' .. animInput, 'error')
            return false
        end
    end
    
    -- Otherwise, try to load as animation dictionary
    local dict = animInput
    local success = pcall(function()
        RequestAnimDict(dict)
    end)
    
    if not success then
        QBCore.Functions.Notify('Animation does not exist: ' .. animInput, 'error')
        return false
    end
    
    -- Wait for the animation dictionary to load
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    if not HasAnimDictLoaded(dict) then
        QBCore.Functions.Notify('Animation does not exist: ' .. animInput, 'error')
        return false
    end
    
    -- Try common animation names since we can't easily enumerate all animations in a dictionary
    -- Note: This is a limitation - not all animations may be detected
    -- Users should refer to GTA V native animation lists for specific animation names
    local commonAnimNames = {
        'base', 'idle', 'idle_a', 'idle_b', 'idle_c',
        'enter', 'exit', 'clip', 'clipset', 'intro', 'outro'
    }
    
    local animToPlay = nil
    for _, animName in ipairs(commonAnimNames) do
        -- Try to play the animation
        ClearPedTasks(playerPed)
        TaskPlayAnim(playerPed, dict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
        
        -- Give it a moment and check if it's playing
        Wait(100)
        if IsEntityPlayingAnim(playerPed, dict, animName, 3) then
            animToPlay = animName
            break
        end
    end
    
    if animToPlay then
        isPlayingAnimation = true
        currentAnimDict = dict
        currentAnimName = animToPlay
        QBCore.Functions.Notify('Playing animation: ' .. dict .. ' - ' .. animToPlay, 'success')
        return true
    else
        QBCore.Functions.Notify('Animation does not exist: ' .. animInput, 'error')
        return false
    end
end

-- Function to stop animation
local function StopAnimation()
    local playerPed = PlayerPedId()
    
    if isPlayingAnimation then
        ClearPedTasks(playerPed)
        ClearPedSecondaryTask(playerPed)
        
        -- Clear any attached props
        -- Check for props attached to common bone indices
        local boneIndices = {
            57005, -- Right hand (BONETAG_R_PH_HAND)
            18905, -- Left hand (BONETAG_L_PH_HAND)
            28422  -- Head (BONETAG_HEAD)
        }
        
        for _, boneIndex in ipairs(boneIndices) do
            local attachedEntity = GetEntityAttachedTo(playerPed)
            if attachedEntity ~= 0 and DoesEntityExist(attachedEntity) then
                DeleteEntity(attachedEntity)
            end
        end
        
        isPlayingAnimation = false
        currentAnimDict = nil
        currentAnimName = nil
        
        QBCore.Functions.Notify('Animation stopped', 'success')
    else
        QBCore.Functions.Notify('No animation is currently playing', 'error')
    end
end

-- Register the /animator command
RegisterCommand(Config.CommandName, function(source, args, rawCommand)
    if args[1] and args[1]:lower() == Config.StopCommand then
        -- Stop animation
        StopAnimation()
    else
        -- Show input dialog for animation name
        local keyboard = exports['qb-input']:ShowInput({
            header = "Animation Player",
            submitText = "Play",
            inputs = {
                {
                    text = "Animation Name",
                    name = "animname",
                    type = "text",
                    isRequired = true,
                    placeholder = "e.g., WORLD_HUMAN_CLIPBOARD"
                }
            }
        })
        
        if keyboard then
            local animName = keyboard.animname
            if animName and animName ~= "" then
                PlayAnimation(animName)
            else
                QBCore.Functions.Notify('Please enter an animation name', 'error')
            end
        end
    end
end, false)

-- Optional: Add suggestion for the command
TriggerEvent('chat:addSuggestion', '/' .. Config.CommandName, 'Play an animation', {
    { name = "stop", help = "(Optional) Use 'stop' to stop current animation" }
})

print('^2[ChiLLLix Animator]^7 Script loaded successfully')
