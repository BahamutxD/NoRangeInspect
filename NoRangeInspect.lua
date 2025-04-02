-- Store the last right-clicked unit
local lastInspectedUnit = nil

-- Custom inspect function that bypasses all checks
local function ForceInspect(unit)
    unit = unit or "target"
    if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return
    end
    
    -- Store unit for later use
    lastInspectedUnit = unit
    
    -- Directly call the core inspection function
    NotifyInspect(unit)
    
    -- Manually create inspect frame if needed
    if not InspectFrame then
        CreateFrame("Frame", "InspectFrame", UIParent, "InspectFrameTemplate")
    end
    
    -- Set the unit and show frame
    InspectFrame.unit = unit
    ShowUIPanel(InspectFrame)
    
    -- Force update the paperdoll
    if InspectPaperDollFrame_OnShow then
        InspectPaperDollFrame_OnShow()
    end
end

-- Override default inspect function
InspectUnit = ForceInspect

-- Hook right-click menu
local original_UnitPopup_ShowMenu = UnitPopup_ShowMenu
function UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
    -- Store unit for inspection
    if unit and UnitIsPlayer(unit) then
        lastInspectedUnit = unit
    end
    
    -- Create forced inspect button
    UnitPopupButtons["INSPECT"] = {
        text = INSPECT,
        dist = 0,  -- Remove distance requirement
        func = function()
            if lastInspectedUnit then
                ForceInspect(lastInspectedUnit)
            end
        end
    }
    
    -- Call original menu function
    original_UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
    
    -- Force-enable inspect button
    for i = 1, 30 do  -- Vanilla has no UIDROPDOWNMENU_MAXBUTTONS
        local button = getglobal("DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i)
        if button and button.value == "INSPECT" then
            button.func = function()
                if lastInspectedUnit then
                    ForceInspect(lastInspectedUnit)
                end
            end
            button.disabled = nil
            button:Enable()
        end
    end
end

-- Slash command
SLASH_FORCEINSPECT1 = "/inspect"
SlashCmdList["FORCEINSPECT"] = function(msg)
    ForceInspect(msg ~= "" and msg or "target")
end

-- Load message
DEFAULT_CHAT_FRAME:AddMessage("NoRangeInspect v1.3 loaded! Inspect now works at any range.")