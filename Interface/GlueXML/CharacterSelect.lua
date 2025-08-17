local EPOCH_CLASS_COLORS = {
    ["Druid"]   = { r = 1.00, g = 0.49, b = 0.04, colorStr = "ffFF7C0A" },
    ["Mage"]    = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3FC7EB" },
    ["Hunter"]  = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffAAD372" },
    ["Paladin"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "ffF48CBA" },
    ["Priest"]  = { r = 1.00, g = 1.00, b = 1.00, colorStr = "ffFFFFFF" },
    ["Rogue"]   = { r = 1.00, g = 0.96, b = 0.41, colorStr = "ffFFF468" },
    ["Shaman"]  = { r = 0.00, g = 0.44, b = 0.87, colorStr = "ff0070DD" },
    ["Warlock"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788EE" },
    ["Warrior"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffC69B6D" },
}

function GetSortedCharacterIndices()
    local currentAccount = nil;
    if Autologin_SelectedIdx and Autologin_Table and Autologin_Table[Autologin_SelectedIdx] then
        currentAccount = Autologin_Table[Autologin_SelectedIdx].name;
    else
        currentAccount = AccountLoginAccountEdit and AccountLoginAccountEdit:GetText();
    end

    local characterOrder = nil;
    if currentAccount and AutoLoginAccounts then
        for _, account in ipairs(AutoLoginAccounts) do
            if account.name == currentAccount and account.characterOrder then
                characterOrder = account.characterOrder;
                break;
            end
        end
    end

    if not characterOrder or table.getn(characterOrder) == 0 then
        local indices = {};
        local numChars = GetNumCharacters();
        for i = 1, numChars do
            indices[i] = i;
        end
        return indices;
    end

    local numChars = GetNumCharacters();
    local sortedIndices = {};
    local usedIndices = {};
    local sortIndex = 1;

    for _, characterName in ipairs(characterOrder) do
        for i = 1, numChars do
            local name = GetCharacterInfo(i);
            if name == characterName and not usedIndices[i] then
                sortedIndices[sortIndex] = i;
                usedIndices[i] = true;
                sortIndex = sortIndex + 1;
                break;
            end
        end
    end

    for i = 1, numChars do
        if not usedIndices[i] then
            sortedIndices[sortIndex] = i;
            sortIndex = sortIndex + 1;
        end
    end

    return sortedIndices;
end

function UpdateCharacterList()
    local numChars = GetNumCharacters();
    local sortedIndices = GetSortedCharacterIndices();
    local index = 1;

    for displayPos = 1, numChars do
        local charIndex = sortedIndices[displayPos];
        local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(charIndex);
        local button = _G["CharSelectCharacterButton"..index];

        if not name then
            button:SetText("ERROR - Contact Bennylavaa");
        else
            if not zone then
                zone = "";
            end
            _G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetText(name);
            local infoString = _G["CharSelectCharacterButton"..index.."ButtonTextInfo"];
            local colorInfo = EPOCH_CLASS_COLORS[class];

            if colorInfo then
                local coloredClass = string.format("|c%s%s|r", colorInfo.colorStr, class);
                if ghost then
                    infoString:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, coloredClass);
                else
                    infoString:SetFormattedText(CHARACTER_SELECT_INFO, level, coloredClass);
                end
            else
                if ghost then
                    infoString:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, class);
                else
                    infoString:SetFormattedText(CHARACTER_SELECT_INFO, level, class);
                end
            end
            _G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(zone);
        end

        button.actualCharIndex = charIndex;
        button:Show();

        -- Setup paid service buttons
        _G["CharSelectCharacterCustomize"..index]:Hide();
        _G["CharSelectRaceChange"..index]:Hide();
        _G["CharSelectFactionChange"..index]:Hide();
        if PFC then
            _G["CharSelectFactionChange"..index]:Show();
        elseif PRC then
            _G["CharSelectRaceChange"..index]:Show();
        elseif PCC then
            _G["CharSelectCharacterCustomize"..index]:Show();
        end

        index = index + 1;
        if index > MAX_CHARACTERS_DISPLAYED then
            break;
        end
    end

    if numChars == 0 then
        CharacterSelectDeleteButton:Disable();
        CharSelectEnterWorldButton:Disable();
    else
        CharacterSelectDeleteButton:Enable();
        CharSelectEnterWorldButton:Enable();
    end

    CharacterSelect.createIndex = 0;
    CharSelectCreateCharacterButton:Hide();

    local connected = IsConnectedToServer();
    for i = index, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..i];
        if CharacterSelect.createIndex == 0 and numChars < MAX_CHARACTERS_PER_REALM then
            CharacterSelect.createIndex = i;
            if connected then
                CharSelectCreateCharacterButton:SetID(i);
                CharSelectCreateCharacterButton:Show();
            end
        end
        _G["CharSelectCharacterCustomize"..i]:Hide();
        _G["CharSelectFactionChange"..i]:Hide();
        _G["CharSelectRaceChange"..i]:Hide();
        button:Hide();
    end

    if numChars == 0 then
        CharacterSelect.selectedIndex = 0;
        CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
        return;
    end

    if CharacterSelect.selectLast == 1 then
        CharacterSelect.selectLast = 0;
        local lastDisplayIndex = numChars;
        local lastCharIndex = sortedIndices[lastDisplayIndex];
        CharacterSelect_SelectCharacter(lastCharIndex, 1);
        return;
    end

    if CharacterSelect.selectedIndex == 0 or CharacterSelect.selectedIndex > numChars then
        local firstCharIndex = sortedIndices[1];
        CharacterSelect_SelectCharacter(firstCharIndex, 1);
        return;
    end

    CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
end

function CharacterSelectButton_OnClick(self)
    local actualIndex = self.actualCharIndex or self:GetID();
    if actualIndex ~= CharacterSelect.selectedIndex then
        CharacterSelect_SelectCharacter(actualIndex);
    end
end

function CharacterSelectButton_OnDoubleClick(self)
    local actualIndex = self.actualCharIndex or self:GetID();
    if actualIndex ~= CharacterSelect.selectedIndex then
        CharacterSelect_SelectCharacter(actualIndex);
    end
    CharacterSelect_EnterWorld();
end

function Autologin_OnCharactersLoad()
  Autologin_Load();
  local selected = Autologin_Table[Autologin_SelectedIdx];
  if (not selected) then
    AutologinSaveCharacterButton:Hide();
    return;
  end

  AutologinSaveCharacterButton:Show();
  if (selected.character == '-') then return end

  -- Get id from the character name
  -- for i = 1, GetNumCharacters() do
  --   local name = GetCharacterInfo(i);
  --   if (name == selected.character) then
  --     SelectCharacter(i);
  --     EnterWorld();
  --   end
  -- end
  SelectCharacter(tonumber(selected.character));
  EnterWorld();
end

function Autologin_EnterWorld()
  -- Update autologin character if checkbox is checked
  if (Autologin_SelectedIdx and AutologinSaveCharacterButton:GetChecked()) then
    -- local name = GetCharacterInfo(CharacterSelect.selectedIndex);
    -- Autologin_Table[Autologin_SelectedIdx].character = name;
    Autologin_Table[Autologin_SelectedIdx].character = CharacterSelect.selectedIndex;
    Autologin_Save();
  end

  EnterWorld();
end

-- Wrath code

CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 10;
MAX_CHARACTERS_PER_REALM = 10;


function CharacterSelect_OnLoad(self)
    self:SetSequence(0);
    self:SetCamera(0);
CharacterSelectLogo:ClearAllPoints(); CharacterSelectLogo:SetPoint("TOPLEFT", 55, -7);

    self.createIndex = 0;
    self.selectedIndex = 0;
    self.selectLast = 0;
    self.currentModel = nil;
    self:RegisterEvent("ADDON_LIST_UPDATE");
    self:RegisterEvent("CHARACTER_LIST_UPDATE");
    self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
    self:RegisterEvent("SELECT_LAST_CHARACTER");
    self:RegisterEvent("SELECT_FIRST_CHARACTER");
    self:RegisterEvent("SUGGEST_REALM");
    self:RegisterEvent("FORCE_RENAME_CHARACTER");

    -- CharacterSelect:SetModel("Interface\\Glues\\Models\\UI_Orc\\UI_Orc.m2");

    -- local fogInfo = CharModelFogInfo["ORC"];
    -- CharacterSelect:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b);
    -- CharacterSelect:SetFogNear(0);
    -- CharacterSelect:SetFogFar(fogInfo.far);

    SetCharSelectModelFrame("CharacterSelect");

    -- Color edit box backdrops
    local backdropColor = DEFAULT_TOOLTIP_COLOR;
    CharacterSelectCharacterFrame:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
    CharacterSelectCharacterFrame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6], 0.85);

end

function CharacterSelect_OnShow()
    -- request account data times from the server (so we know if we should refresh keybindings, etc...)
    ReadyForAccountDataTimes()

    local CurrentModel = CharacterSelect.currentModel;

    if ( CurrentModel ) then
        PlayGlueAmbience(GlueAmbienceTracks[strupper(CurrentModel)], 4.0);
    end

    UpdateAddonButton();

    local serverName, isPVP, isRP = GetServerName();
    local connected = IsConnectedToServer();
    local serverType = "";
    if ( serverName ) then
        if( not connected ) then
            serverName = serverName.."\n("..SERVER_DOWN..")";
        end
        if ( isPVP ) then
            if ( isRP ) then
                serverType = RPPVP_PARENTHESES;
            else
                serverType = PVP_PARENTHESES;
            end
        elseif ( isRP ) then
            serverType = RP_PARENTHESES;
        end
        CharSelectRealmName:SetText(serverName.." "..serverType);
        CharSelectRealmName:Show();
    else
        CharSelectRealmName:Hide();
    end

    if ( connected ) then
        GetCharacterListUpdate();
    else
        UpdateCharacterList();
    end

    -- Gameroom billing stuff (For Korea and China only)
    if ( SHOW_GAMEROOM_BILLING_FRAME ) then
        local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
        if ( paymentPlan == 0 ) then
            -- No payment plan
            GameRoomBillingFrame:Hide();
            CharacterSelectRealmSplitButton:ClearAllPoints();
            CharacterSelectRealmSplitButton:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
        else
            local billingTimeLeft = GetBillingTimeRemaining();
            -- Set default text for the payment plan
            local billingText = _G["BILLING_TEXT"..paymentPlan];
            if ( paymentPlan == 1 ) then
                -- Recurring account
                billingTimeLeft = ceil(billingTimeLeft/(60 * 24));
                if ( billingTimeLeft == 1 ) then
                    billingText = BILLING_TIME_LEFT_LAST_DAY;
                end
            elseif ( paymentPlan == 2 ) then
                -- Free account
                if ( billingTimeLeft < (24 * 60) ) then
                    billingText = format(BILLING_FREE_TIME_EXPIRE, billingTimeLeft.." "..MINUTES_ABBR);
                end
            elseif ( paymentPlan == 3 ) then
                -- Fixed but not recurring
                if ( isGameRoom == 1 ) then
                    if ( billingTimeLeft <= 30 ) then
                        billingText = BILLING_GAMEROOM_EXPIRE;
                    else
                        billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1));
                    end
                else
                    -- personal fixed plan
                    if ( billingTimeLeft < (24 * 60) ) then
                        billingText = BILLING_FIXED_LASTDAY;
                    else
                        billingText = format(billingText, MinutesToTime(billingTimeLeft));
                    end
                end
            elseif ( paymentPlan == 4 ) then
                -- Usage plan
                if ( isGameRoom == 1 ) then
                    -- game room usage plan
                    if ( billingTimeLeft <= 600 ) then
                        billingText = BILLING_GAMEROOM_EXPIRE;
                    else
                        billingText = BILLING_IGR_USAGE;
                    end
                else
                    -- personal usage plan
                    if ( billingTimeLeft <= 30 ) then
                        billingText = BILLING_TIME_LEFT_30_MINS;
                    else
                        billingText = format(billingText, billingTimeLeft);
                    end
                end
            end
            -- If fallback payment method add a note that says so
            if ( hasFallBackBillingMethod == 1 ) then
                billingText = billingText.."\n\n"..BILLING_HAS_FALLBACK_PAYMENT;
            end
            GameRoomBillingFrameText:SetText(billingText);
            GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26);
            GameRoomBillingFrame:Show();
            CharacterSelectRealmSplitButton:ClearAllPoints();
            CharacterSelectRealmSplitButton:SetPoint("TOP", GameRoomBillingFrame, "BOTTOM", 0, -10);
        end
    end

    if( IsTrialAccount() ) then
        CharacterSelectUpgradeAccountButton:Show();
    else
        CharacterSelectUpgradeAccountButton:Hide();
    end

    -- fadein the character select ui
    GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

    RealmSplitCurrentChoice:Hide();
    RequestRealmSplitInfo();

    --Clear out the addons selected item
    GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);
end

function CharacterSelect_OnHide()
    CharacterDeleteDialog:Hide();
    CharacterRenameDialog:Hide();
    if ( DeclensionFrame ) then
        DeclensionFrame:Hide();
    end
    SERVER_SPLIT_STATE_PENDING = -1;
end

function CharacterSelect_OnUpdate(elapsed)
    if ( SERVER_SPLIT_STATE_PENDING > 0 ) then
        CharacterSelectRealmSplitButton:Show();

        if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
            RealmSplit_SetChoiceText();
            RealmSplitPending:SetPoint("TOP", RealmSplitCurrentChoice, "BOTTOM", 0, -10);
        else
            RealmSplitPending:SetPoint("TOP", CharacterSelectRealmSplitButton, "BOTTOM", 0, 0);
            RealmSplitCurrentChoice:Hide();
        end

        if ( SERVER_SPLIT_STATE_PENDING > 1 ) then
            CharacterSelectRealmSplitButton:Disable();
            CharacterSelectRealmSplitButtonGlow:Hide();
            RealmSplitPending:SetText( SERVER_SPLIT_PENDING );
        else
            CharacterSelectRealmSplitButton:Enable();
            CharacterSelectRealmSplitButtonGlow:Show();
            local datetext = SERVER_SPLIT_CHOOSE_BY.."\n"..SERVER_SPLIT_DATE;
            RealmSplitPending:SetText( datetext );
        end

        if ( SERVER_SPLIT_SHOW_DIALOG and not GlueDialog:IsShown() ) then
            SERVER_SPLIT_SHOW_DIALOG = false;
            local dialogString = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
            if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
                local serverChoice = RealmSplit_GetFormatedChoice(SERVER_SPLIT_REALM_CHOICE);
                local stringWithDate = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
                dialogString = stringWithDate.."\n\n"..serverChoice;
                GlueDialog_Show("SERVER_SPLIT_WITH_CHOICE", dialogString);
            else
                GlueDialog_Show("SERVER_SPLIT", dialogString);
            end
        end
    else
        CharacterSelectRealmSplitButton:Hide();
    end

    -- Account Msg stuff
    if ( (ACCOUNT_MSG_NUM_AVAILABLE > 0) and not GlueDialog:IsShown() ) then
        if ( ACCOUNT_MSG_HEADERS_LOADED ) then
            if ( ACCOUNT_MSG_BODY_LOADED ) then
                local dialogString = AccountMsg_GetHeaderSubject( ACCOUNT_MSG_CURRENT_INDEX ).."\n\n"..AccountMsg_GetBody();
                GlueDialog_Show("ACCOUNT_MSG", dialogString);
            end
        end
    end
end

function CharacterSelect_OnKeyDown(self,key)
    if ( key == "ESCAPE" ) then
        CharacterSelect_Exit();
    elseif ( key == "ENTER" ) then
        CharacterSelect_EnterWorld();
    elseif ( key == "PRINTSCREEN" ) then
        Screenshot();
    elseif ( key == "UP" or key == "LEFT" ) then
        local numChars = GetNumCharacters();
        if ( numChars > 1 ) then
            if ( self.selectedIndex > 1 ) then
                CharacterSelect_SelectCharacter(self.selectedIndex - 1);
            else
                CharacterSelect_SelectCharacter(numChars);
            end
        end
    elseif ( arg1 == "DOWN" or arg1 == "RIGHT" ) then
        local numChars = GetNumCharacters();
        if ( numChars > 1 ) then
            if ( self.selectedIndex < GetNumCharacters() ) then
                CharacterSelect_SelectCharacter(self.selectedIndex + 1);
            else
                CharacterSelect_SelectCharacter(1);
            end
        end
    end
end

function CharacterSelect_OnEvent(self, event, ...)
    if ( event == "ADDON_LIST_UPDATE" ) then
        UpdateAddonButton();
    elseif ( event == "CHARACTER_LIST_UPDATE" ) then
        UpdateCharacterList();
        CharSelectCharacterName:SetText(GetCharacterInfo(self.selectedIndex));
        Autologin_OnCharactersLoad();
    elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
        local index = ...;
        if ( index == 0 ) then
            CharSelectCharacterName:SetText("");
        else
            CharSelectCharacterName:SetText(GetCharacterInfo(index));
            self.selectedIndex = index;
        end
        UpdateCharacterSelection(self);
    elseif ( event == "SELECT_LAST_CHARACTER" ) then
        self.selectLast = 1;
    elseif ( event == "SELECT_FIRST_CHARACTER" ) then
        CharacterSelect_SelectCharacter(1, 1);
    elseif ( event == "SUGGEST_REALM" ) then
        local category, id = ...;
        local name = GetRealmInfo(category, id);
        if ( name ) then
            SetGlueScreen("charselect");
            ChangeRealm(category, id);
        else
            if ( RealmList:IsShown() ) then
                RealmListUpdate();
            else
                RealmList:Show();
            end
        end
    elseif ( event == "FORCE_RENAME_CHARACTER" ) then
        local message = ...;
        CharacterRenameDialog:Show();
        CharacterRenameText1:SetText(_G[message]);
    end
end

function CharacterSelect_UpdateModel(self)
    UpdateSelectionCustomizationScene();
    self:AdvanceTime();
end

function UpdateCharacterSelection(self)
    for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
        _G["CharSelectCharacterButton"..i]:UnlockHighlight();
    end

    local sortedIndices = GetSortedCharacterIndices();
    local displayIndex = nil;
    for i = 1, table.getn(sortedIndices) do
        if sortedIndices[i] == self.selectedIndex then
            displayIndex = i;
            break;
        end
    end

    if displayIndex and displayIndex > 0 and displayIndex <= MAX_CHARACTERS_DISPLAYED then
        _G["CharSelectCharacterButton"..displayIndex]:LockHighlight();
    end
end

function CharacterSelect_TabResize(self)
    local buttonMiddle = _G[self:GetName().."Middle"];
    local buttonMiddleDisabled = _G[self:GetName().."MiddleDisabled"];
    local width = self:GetTextWidth() - 8;
    local leftWidth = _G[self:GetName().."Left"]:GetWidth();
    buttonMiddle:SetWidth(width);
    buttonMiddleDisabled:SetWidth(width);
    self:SetWidth(width + (2 * leftWidth));
end

function CharacterSelect_SelectCharacter(id, noCreate)
    if ( id == CharacterSelect.createIndex ) then
        if ( not noCreate ) then
            PlaySound("gsCharacterSelectionCreateNew");
            SetGlueScreen("charcreate");
        end
    else
        CharacterSelect.currentModel = GetSelectBackgroundModel(id);
        SetBackgroundModel(CharacterSelect,CharacterSelect.currentModel);

        SelectCharacter(id);
    end
end

function CharacterDeleteDialog_OnShow()
    local name, race, class, level = GetCharacterInfo(CharacterSelect.selectedIndex);
    CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
    CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
    CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
    PlaySound("gsCharacterSelectionEnterWorld");
    StopGlueAmbience();
    Autologin_EnterWorld();
end

function CharacterSelect_Exit()
    PlaySound("gsCharacterSelectionExit");
    DisconnectFromServer();
    SetGlueScreen("login");
end

function CharacterSelect_AccountOptions()
    PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
    PlaySound("gsCharacterSelectionAcctOptions");
    LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
    PlaySound("gsCharacterSelectionDelCharacter");
    if ( CharacterSelect.selectedIndex > 0 ) then
        CharacterDeleteDialog:Show();
    end
end

function CharacterSelect_ChangeRealm()
    PlaySound("gsCharacterSelectionDelCharacter");
    RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
    if ( button == "LeftButton" ) then
        CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
        CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
    end
end

function CharacterSelectFrame_OnMouseUp(button)
    if ( button == "LeftButton" ) then
        CHARACTER_SELECT_ROTATION_START_X = nil
    end
end

function CharacterSelectFrame_OnUpdate()
    if ( CHARACTER_SELECT_ROTATION_START_X ) then
        local x = GetCursorPosition();
        local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
        CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
        SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
    end
end

function CharacterSelectRotateRight_OnUpdate(self)
    if ( self:GetButtonState() == "PUSHED" ) then
        SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT);
    end
end

function CharacterSelectRotateLeft_OnUpdate(self)
    if ( self:GetButtonState() == "PUSHED" ) then
        SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT);
    end
end

function CharacterSelect_ManageAccount()
    PlaySound("gsCharacterSelectionAcctOptions");
    LaunchURL(AUTH_NO_TIME_URL);
end

function RealmSplit_GetFormatedChoice(formatText)
    if ( SERVER_SPLIT_CLIENT_STATE == 1 ) then
        realmChoice = SERVER_SPLIT_SERVER_ONE;
    else
        realmChoice = SERVER_SPLIT_SERVER_TWO;
    end
    return format(formatText, realmChoice);
end

function RealmSplit_SetChoiceText()
    RealmSplitCurrentChoice:SetText( RealmSplit_GetFormatedChoice(SERVER_SPLIT_CURRENT_CHOICE) );
    RealmSplitCurrentChoice:Show();
end

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
    PAID_SERVICE_CHARACTER_ID = self:GetID();
    PAID_SERVICE_TYPE = service;
    PlaySound("gsCharacterSelectionCreateNew");
    SetGlueScreen("charcreate");
end

function CharacterSelect_DeathKnightSwap(self)
    if ( CharacterSelect.currentModel == "DEATHKNIGHT" ) then
        if (self.currentModel ~= "DEATHKNIGHT") then
            self.currentModel = "DEATHKNIGHT";
            self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
            self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
            self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
        end
    else
        if (self.currentModel == "DEATHKNIGHT") then
            self.currentModel = nil;
            self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
            self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
            self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
        end
    end
end

