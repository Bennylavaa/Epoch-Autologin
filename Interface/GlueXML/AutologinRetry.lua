local autologinActive = false
local autoStart = false
local AutologinLoopFrame = CreateFrame("Frame")
local checkInterval = 0.2 -- 200 ms
local elapsedSinceLastCheck = 0
local lastGlueDialogErrorText = nil
local memorySignals = {}

-- Config loading
if AutologinRetry then
    if AutologinRetry.autoStart ~= nil then
        autoStart = AutologinRetry.autoStart
    end
    if AutologinRetry.checkInterval ~= nil then
        checkInterval = AutologinRetry.checkInterval
    end
    if AutologinRetry.alarmCooldown ~= nil then
        alarmCooldown = AutologinRetry.alarmCooldown
    end
end

-- Cannot find a way to hook the GlueDialog Error text directly, so we use a secure hook
hooksecurefunc("GlueDialog_Show", function(which, text)
    if text and text ~= "" then
        lastGlueDialogErrorText = text
    end
end)

local function MakeMemorySignal(msg, tag)
    prefix = "Â§Â§AUTO-LOGINÂ§Â§";
    sufix = "Â§Â§AUTO-LOGIN-ENDÂ§Â§";
    spacer = "::"
    tag = tag or "BASIC"

-- Overwrite old value to erase from memory
    if _G[tag] then
        _G[tag] = string.rep(" ", #_G[tag])
    end

    if tag and msg then
        _G[tag] = prefix .. tostring(time()) .. spacer .. tag .. spacer .. msg .. sufix
    end
end

local function IsOnLoginScreen()
    -- Replace with your actual check if needed
    return GlueParent and GlueParent:IsShown()
end

local function StopAutologinOnCharSelect()
    if autologinActive then
        autologinActive = false
        if AutologinRetryButton then
            AutologinRetryButton:SetText("Autologin START")
        end
        if AutologinStatusText then
            AutologinStatusText:SetText("Status: Idle")
        end
        if AutologinStatusBox then
            AutologinStatusBox:SetBackdropColor(1.0, 1.0, 1.0, 1.0)
        end
    end
end

local function Autologin_OnUpdate(self, elapsed)

    -- Reseting lastGlueDialogText if GlueDialog is not shown
    if lastGlueDialogErrorText ~= nil and (not GlueDialog or not GlueDialog:IsShown()) then
        lastGlueDialogErrorText = nil
    end

    elapsedSinceLastCheck = elapsedSinceLastCheck + elapsed
    if elapsedSinceLastCheck >= checkInterval then
        elapsedSinceLastCheck = 0

        -- User Stoped Autologin
        if not autologinActive then
            self:SetScript("OnUpdate", nil)
            return
        end

        -- Check if we are still on the login screen
        if not IsOnLoginScreen() then
            AutologinStatusText:SetText("Not on login screen!")
            -- autologinActive = false
            -- AutologinRetryButton:SetText("Autologin START")
            -- self:SetScript("OnUpdate", nil)

            AutologinStatusBox:SetBackdropColor(1.0, 0.0, 0.0, 1.0)  -- Red (R, G, B, Alpha)
            -- Play alarm sound to indicate we are not on the login screen
            PlayAlarm()

            return
        end




        if GlueDialog and GlueDialog:IsShown() then
            local dialogType = GlueDialog.which or "UNKNOWN"
            -- If GlueDialog is shown, we assume we are in a dialog state
            AutologinStatusText:SetText((GlueDialogText:GetText() or "NO TEXT"))


            if dialogType == "CANCEL" then
                AutologinStatusText:SetText((GlueDialogText:GetText() or "NO TEXT"))
                if not GlueDialogText:GetText() then
                    GlueDialogText:SetText("No text provided for this dialog.")
                    -- Click the CANCEL button
                    if GlueDialogButton1
                        and GlueDialogButton1:IsShown()
                        and GlueDialogButton1:IsVisible()
                        and GlueDialogButton1:IsEnabled()
                    then
                        GlueDialogButton1:Click()
                    end
                end
                MakeMemorySignal((GlueDialogText:GetText() or "NO TEXT"))


            elseif dialogType == "CONNECTION_HELP_HTML" then
                AutologinStatusText:SetText((lastGlueDialogErrorText or "NO ERROR"))
                MakeMemorySignal("CONNECTION_HELP_HTML")

                -- Click the OK button for HTML dialog
                if GlueDialogButton2
                    and GlueDialogButton2:IsShown()
                    and GlueDialogButton2:IsVisible()
                    and GlueDialogButton2:IsEnabled()
                then
                    GlueDialogButton2:Click()
                end

            elseif dialogType == "DISCONNECTED" then
                AutologinStatusText:SetText((GlueDialogText:GetText() or "NO TEXT"))
                MakeMemorySignal("DISCONNECTED")

                -- Click the OK button for HTML dialog
                if GlueDialogButton1
                    and GlueDialogButton1:IsShown()
                    and GlueDialogButton1:IsVisible()
                    and GlueDialogButton1:IsEnabled()
                then
                    GlueDialogButton1:Click()
                end

            elseif dialogType == "OKAY" then
                AutologinStatusText:SetText((GlueDialogText:GetText() or "NO TEXT"))
                MakeMemorySignal("OKAY BOX")
                -- Click the OK button for OK dialog
                if GlueDialogButton1
                    and GlueDialogButton1:IsShown()
                    and GlueDialogButton1:IsVisible()
                    and GlueDialogButton1:IsEnabled()
                then
                    GlueDialogButton1:Click()
                end

            else
                AutologinStatusText:SetText((GlueDialogText:GetText() .. "| ERROR:" .. lastGlueDialogErrorText or "NO TEXT"))
                AutologinStatusBox:SetBackdropColor(1.0, 0.0, 0.0, 1.0)  -- Red (R, G, B, Alpha)

                -- Play alarm sound for unknown dialog types
                PlayAlarm()
                -- Stop Autologin
                Autologin()
            end


        elseif RealmQueueFrame and RealmQueueFrame:IsShown() then
            local status = RealmQueueStatusText:GetText() or "No position"
            local eta = RealmQueueEstimate:GetText() or "No ETA"
            AutologinStatusText:SetText("In queue: " .. status .. " | ETA: " .. eta)


        else
            AutologinStatusText:SetText("Status: Running")
            if AccountLoginLoginButton
                and AccountLoginLoginButton:IsShown()
                and AccountLoginLoginButton:IsVisible()
                and AccountLoginLoginButton:IsEnabled() then

                AutologinStatusText:SetText("Attempting login...")
                AccountLoginLoginButton:Click()
            end
        end

    end
end

local function AutologinFrame_OnEvent(self, event)
    if event == "CHARACTER_LIST_UPDATE" then
        StopAutologinOnCharSelect()
    end
end

lastAlarmTime = 0
function PlayAlarm()
        -- Only play alarm if enough time has passed
    local alarmCooldown = 1 -- seconds
    local currentTime = GetTime()
    if (currentTime - lastAlarmTime) > alarmCooldown then
        PlaySoundFile("Interface\\GlueXML\\Sounds\\alarm.wav")
        lastAlarmTime = currentTime
    end
end


function Autologin()
    autologinActive = not autologinActive

    if autologinActive then
        AutologinRetryButton:SetText("Autologin STOP")
        AutologinStatusText:SetText("Status: Running")
        elapsedSinceLastCheck = 0
        AutologinLoopFrame:SetScript("OnUpdate", Autologin_OnUpdate)

        -- Change status box to yellow when script starts
        AutologinStatusBox:SetBackdropColor(1.0, 1.0, 0.0, 1.0)  -- Yellow (R, G, B, Alpha)
    else
        AutologinRetryButton:SetText("Autologin START")
        AutologinStatusText:SetText("Status: Idle")
        AutologinLoopFrame:SetScript("OnUpdate", nil)

        AutologinStatusBox:SetBackdropColor(1.0, 1.0, 1.0, 1.0)  -- White (R, G, B, Alpha)
    end
end

local function AutoStart(self, elapsed)
    -- Wait until required UI elements are available
    if AccountLoginLoginButton and AutologinRetryButton and AutologinStatusText and AutologinStatusBox then
        -- Elements are ready, start autologin if needed
        AutologinLoopFrame:SetScript("OnUpdate", nil)
        Autologin()  -- or StartAutologin() if you used the refactor

    end
end

-- Register for character list update event
AutologinLoopFrame:RegisterEvent("CHARACTER_LIST_UPDATE")
AutologinLoopFrame:SetScript("OnEvent", AutologinFrame_OnEvent)

-- If autoStart is true, set the OnUpdate script to start autologin
if autoStart then
    AutologinLoopFrame:SetScript("OnUpdate", AutoStart)
end