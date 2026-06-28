-- ╔══════════════════════════════════════════════════════════╗
-- ║   Packet Hook Library — Full Feature Example             ║
-- ║   Covers every API method available in Library.lua       ║
-- ╚══════════════════════════════════════════════════════════╝
--
-- USAGE: Copy this file, rename it for your game, fill in
--        real logic where the print() stubs are.

local repo = 'https://raw.githubusercontent.com/PacketHook/Packet-Hook-Lib/main/'

-- ── Load library ──────────────────────────────────────────────────────────
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

-- Show errors as on-screen notifications instead of crashing the executor.
Library.NotifyOnError = true

-- ── Create window ─────────────────────────────────────────────────────────
-- Title        : top-left text in the sidebar
-- GameName     : subtitle text below Title
-- ImageId      : decal asset ID shown in the icon circle instead of a letter
--                (omit or set to '' to fall back to the first letter of Title)
-- Center       : spawn window at screen centre
-- AutoShow     : show immediately after creation (false = call Library:Show() manually)
-- TabPadding   : extra px between tab buttons in the sidebar
-- MenuFadeTime : open/close animation duration in seconds
local Window = Library:CreateWindow({
    Title        = 'Packet Hook',
    GameName     = 'Example Game',
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
    -- ImageId   = '70485288567788',  -- uncomment to use a custom icon image
})

-- ── Tabs ──────────────────────────────────────────────────────────────────
-- Window:AddTab(name, iconId?)
-- Library:LucideIcon(name) returns the image ID for a Lucide icon.
-- Browse icons at: https://lucide.dev/icons/
local Tabs = {
    Main            = Window:AddTab('Main',           Library:LucideIcon('sword')),
    Combat          = Window:AddTab('Combat',         Library:LucideIcon('crosshair')),
    Visuals         = Window:AddTab('Visuals',        Library:LucideIcon('eye')),
    Misc            = Window:AddTab('Misc',           Library:LucideIcon('wrench')),
    ['UI Settings'] = Window:AddTab('UI Settings',   Library:LucideIcon('settings')),
}

-- ── Rename window title at runtime ────────────────────────────────────────
-- Window:SetWindowTitle('New Title')   -- can be called any time

-- ═════════════════════════════════════════════════════════════════════════
-- MAIN TAB
-- ═════════════════════════════════════════════════════════════════════════

-- AddLeftGroupbox(name) / AddRightGroupbox(name)
-- Both sides fill vertically and scroll independently.
local FeatureGroup   = Tabs.Main:AddLeftGroupbox('Features')
local PlaybackGroup  = Tabs.Main:AddRightGroupbox('Playback')

-- ── Toggle ────────────────────────────────────────────────────────────────
-- Idx     : unique key; value lives in Toggles[Idx]
-- Text    : label shown next to the pill
-- Default : starting state (true/false)
-- Tooltip : hover hint (optional)
-- BlankSize : extra spacing below this element (default 7)
FeatureGroup:AddToggle('AutoFarm', {
    Text    = 'Auto Farm',
    Default = false,
    Tooltip = 'Automatically farms resources every second.',
})

-- OnChanged fires immediately when the value changes.
Toggles.AutoFarm:OnChanged(function()
    print('AutoFarm:', Toggles.AutoFarm.Value)
end)

FeatureGroup:AddToggle('GodMode', {
    Text     = 'God Mode',
    Default  = false,
    Tooltip  = 'Prevents the player from taking damage.',
    -- Setting RiskText marks this toggle red to warn the user it is detectable.
    RiskText = 'DETECTED',
})

-- ── Slider ────────────────────────────────────────────────────────────────
-- Min / Max / Default / Rounding (decimal places 0-10)
-- Value lives in Options[Idx].Value
FeatureGroup:AddSlider('WalkSpeed', {
    Text     = 'Walk Speed',
    Min      = 16,
    Max      = 300,
    Default  = 16,
    Rounding = 0,
    Tooltip  = 'Character walk speed.',
    Callback = function(val)
        local char = game:GetService('Players').LocalPlayer.Character
        if char and char:FindFirstChild('Humanoid') then
            char.Humanoid.WalkSpeed = val
        end
    end,
})

FeatureGroup:AddSlider('JumpPower', {
    Text     = 'Jump Power',
    Min      = 0,
    Max      = 200,
    Default  = 50,
    Rounding = 0,
})

-- ── Dropdown — single select ───────────────────────────────────────────────
-- AllowNull=true lets the user deselect (value becomes nil).
-- Default sets the preselected value (must be one of Values).
FeatureGroup:AddDropdown('FarmMode', {
    Text    = 'Farm Mode',
    Values  = { 'Nearest', 'Farthest', 'Strongest', 'Weakest' },
    Default = 'Nearest',
    Tooltip = 'Targeting priority for Auto Farm.',
})

Options.FarmMode:OnChanged(function()
    print('Farm mode changed to:', Options.FarmMode.Value)
end)

-- ── Dropdown — multi select ────────────────────────────────────────────────
-- Multi=true lets the user pick several items.
-- Value is a dict: { ItemName = true, ... } for selected items.
FeatureGroup:AddDropdown('IgnoreItems', {
    Text      = 'Ignore Items',
    Values    = { 'Wood', 'Stone', 'Gold', 'Diamond' },
    Multi     = true,
    AllowNull = true,
    Tooltip   = 'Items to skip during auto-collect.',
})

Options.IgnoreItems:OnChanged(function()
    for item, selected in pairs(Options.IgnoreItems.Value or {}) do
        if selected then print('Ignoring:', item) end
    end
end)

-- ── Input ─────────────────────────────────────────────────────────────────
-- Numeric=true  → only allows numbers
-- Finished=true → OnChanged fires only when Enter is pressed / focus lost
--                 (false = fires on every keystroke)
FeatureGroup:AddInput('TargetPlayer', {
    Text     = 'Target Player',
    Default  = '',
    Numeric  = false,
    Finished = true,
    Tooltip  = 'Name of the player to target.',
})

Options.TargetPlayer:OnChanged(function()
    print('Target player set to:', Options.TargetPlayer.Value)
end)

-- ── Divider ───────────────────────────────────────────────────────────────
-- Draws a horizontal separator line inside the groupbox.
FeatureGroup:AddDivider()

-- ── Label ─────────────────────────────────────────────────────────────────
-- Plain label (no wrapping, truncated if too long):
local StatusLbl = FeatureGroup:AddLabel('Status: Idle')

-- Wrapped label (second argument = true):
FeatureGroup:AddLabel('This is a longer description that will wrap onto multiple lines if needed.', true)

-- Labels expose :SetText(str) to update them at runtime:
-- StatusLbl:SetText('Status: Running')

-- ── AddBlank(pixels) ──────────────────────────────────────────────────────
-- Inserts empty vertical space (useful to group elements visually).
FeatureGroup:AddBlank(8)

-- ── Buttons ───────────────────────────────────────────────────────────────
-- Simple form — just a string and a callback:
FeatureGroup:AddButton('Heal Player', function()
    Library:Notify('Healed!', 2)
end)

-- Table form — supports Tooltip and chained sub-button:
FeatureGroup:AddButton({
    Text    = 'Teleport Options',
    Func    = function() print('Main button clicked') end,
    Tooltip = 'Open teleport sub-menu.',
}):AddButton({
    Text    = 'To Spawn',
    Func    = function()
        local lp = game:GetService('Players').LocalPlayer
        if lp.Character then
            lp.Character:SetPrimaryPartCFrame(CFrame.new(0, 5, 0))
        end
    end,
    Tooltip = 'Teleport to the spawn point.',
})

-- ── ColorPicker ───────────────────────────────────────────────────────────
-- Chained after AddLabel. Value is a Color3; Transparency is a 0-1 number.
PlaybackGroup:AddLabel('ESP Color'):AddColorPicker('EspColor', {
    Default      = Color3.fromRGB(255, 0, 0),
    Title        = 'ESP Color',
    Transparency = 0,
    Callback     = function(val)
        print('ESP color changed:', val)
    end,
})

Options.EspColor:OnChanged(function()
    print('ESP Color:', Options.EspColor.Value, 'Transparency:', Options.EspColor.Transparency)
end)

-- ── KeyPicker ─────────────────────────────────────────────────────────────
-- Chained after AddLabel.
-- Mode : 'Always' | 'Toggle' | 'Hold' — can be changed per-picker
-- Modes: restrict which modes the user can pick (default all three)
-- NoUI : hides the label so only the binding text is shown (used for menu keybind)
PlaybackGroup:AddLabel('Activate Key'):AddKeyPicker('ActivateKey', {
    Default = 'F',
    Text    = 'Activate Key',
    Mode    = 'Toggle',
    -- Modes = { 'Toggle', 'Hold' },  -- restrict available modes
    Callback = function(val)
        print('ActivateKey state:', val)
    end,
})

Options.ActivateKey:OnChanged(function()
    print('Key changed to:', Options.ActivateKey.Value, 'mode:', Options.ActivateKey.Mode)
end)

-- ── DependencyBox ─────────────────────────────────────────────────────────
-- A container that shows/hides based on a Toggle's state.
-- Create it from a groupbox, add elements to it, then wire dependencies.
local DepBox = FeatureGroup:AddDependencyBox()
DepBox:AddSlider('FarmDelay', {
    Text     = 'Farm Delay (s)',
    Min      = 0.1,
    Max      = 5,
    Default  = 1,
    Rounding = 1,
})
DepBox:AddToggle('FarmLoot', {
    Text    = 'Collect Loot',
    Default = true,
})
-- Only show DepBox when AutoFarm is ON (true):
DepBox:SetupDependencies({ { Toggles.AutoFarm, true } })


-- ═════════════════════════════════════════════════════════════════════════
-- COMBAT TAB — TabBox (sub-tabs inside a tab)
-- ═════════════════════════════════════════════════════════════════════════

-- AddLeftTabbox(name) / AddRightTabbox(name)
-- Returns a Tabbox; call :AddTab(name) on it to add inner tabs.
local CombatBox  = Tabs.Combat:AddLeftTabbox('Combat Settings')
local AimTab     = CombatBox:AddTab('Aimbot')
local TriggerTab = CombatBox:AddTab('Triggerbot')

AimTab:AddToggle('AimbotEnabled', {
    Text    = 'Enable Aimbot',
    Default = false,
})
AimTab:AddSlider('AimbotFOV', {
    Text     = 'FOV Radius',
    Min      = 10,
    Max      = 500,
    Default  = 150,
    Rounding = 0,
})
AimTab:AddDropdown('AimbotBone', {
    Text    = 'Target Bone',
    Values  = { 'Head', 'HumanoidRootPart', 'UpperTorso' },
    Default = 'Head',
})

TriggerTab:AddToggle('TriggerEnabled', {
    Text    = 'Enable Triggerbot',
    Default = false,
})
TriggerTab:AddSlider('TriggerDelay', {
    Text     = 'Shot Delay (ms)',
    Min      = 0,
    Max      = 500,
    Default  = 50,
    Rounding = 0,
})

local CombatRightBox = Tabs.Combat:AddRightTabbox('Prediction')
local BulletTab      = CombatRightBox:AddTab('Bullet Drop')
local LaggTab        = CombatRightBox:AddTab('Lag Comp')

BulletTab:AddToggle('BulletDrop', {
    Text    = 'Bullet Drop Comp',
    Default = false,
})
BulletTab:AddSlider('Gravity', {
    Text     = 'Gravity Factor',
    Min      = 0,
    Max      = 200,
    Default  = 100,
    Rounding = 0,
})

LaggTab:AddToggle('LagComp', {
    Text    = 'Lag Compensation',
    Default = false,
})


-- ═════════════════════════════════════════════════════════════════════════
-- VISUALS TAB
-- ═════════════════════════════════════════════════════════════════════════

local EspGroup   = Tabs.Visuals:AddLeftGroupbox('ESP')
local ChamsGroup = Tabs.Visuals:AddRightGroupbox('Chams')

EspGroup:AddToggle('EspEnabled', {
    Text    = 'Enable ESP',
    Default = false,
})

local EspDepBox = EspGroup:AddDependencyBox()
EspDepBox:AddToggle('EspNames', {
    Text    = 'Show Names',
    Default = true,
})
EspDepBox:AddToggle('EspBoxes', {
    Text    = 'Show Boxes',
    Default = true,
})
EspDepBox:AddToggle('EspHealth', {
    Text    = 'Show Health',
    Default = true,
})
EspDepBox:AddSlider('EspMaxDist', {
    Text     = 'Max Distance (studs)',
    Min      = 50,
    Max      = 2000,
    Default  = 500,
    Rounding = 0,
})
EspDepBox:SetupDependencies({ { Toggles.EspEnabled, true } })

ChamsGroup:AddToggle('ChamsEnabled', {
    Text    = 'Enable Chams',
    Default = false,
})
ChamsGroup:AddLabel('Chams Fill'):AddColorPicker('ChamsFill', {
    Default      = Color3.fromRGB(255, 0, 0),
    Title        = 'Fill Color',
    Transparency = 0.5,
})
ChamsGroup:AddLabel('Chams Outline'):AddColorPicker('ChamsOutline', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Outline Color',
})


-- ═════════════════════════════════════════════════════════════════════════
-- MISC TAB
-- ═════════════════════════════════════════════════════════════════════════

local MiscLeft  = Tabs.Misc:AddLeftGroupbox('Utilities')
local MiscRight = Tabs.Misc:AddRightGroupbox('Info')

MiscLeft:AddButton('Copy Player Name', function()
    local name = game:GetService('Players').LocalPlayer.Name
    setclipboard(name)
    Library:Notify('Copied: ' .. name, 3)
end)

MiscLeft:AddButton('Rejoin Server', function()
    local TS = game:GetService('TeleportService')
    TS:Teleport(game.PlaceId, game:GetService('Players').LocalPlayer)
end)

MiscLeft:AddDivider()

MiscLeft:AddToggle('NoClip', {
    Text    = 'No Clip',
    Default = false,
})

Toggles.NoClip:OnChanged(function()
    -- Example: toggling NoClip via RunService
    if Toggles.NoClip.Value then
        Library:Notify('NoClip ON', 2)
    else
        Library:Notify('NoClip OFF', 2)
    end
end)

-- Library:Notify(message, duration) — floating notification in the corner
MiscLeft:AddButton('Test Notification', function()
    Library:Notify('This is a test notification!', 4)
end)

-- Library:OnUnload(callback) — fires when Library:Unload() is called
Library:OnUnload(function()
    print('[PacketHook] Unloaded — clean up your connections here!')
end)

MiscRight:AddLabel('Place ID: ' .. tostring(game.PlaceId))
MiscRight:AddLabel('Job ID: ' .. tostring(game.JobId):sub(1, 18) .. '...', true)

local PlayerCountLbl = MiscRight:AddLabel('Players: --')
task.spawn(function()
    while true do
        local n = #game:GetService('Players'):GetPlayers()
        PlayerCountLbl:SetText('Players: ' .. n)
        task.wait(5)
    end
end)


-- ═════════════════════════════════════════════════════════════════════════
-- UI SETTINGS TAB
-- ═════════════════════════════════════════════════════════════════════════

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

-- Menu toggle keybind — NoUI=true hides the mode buttons (keep it simple).
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI    = true,
    Text    = 'Menu keybind',
})

-- Wire the keybind to the library so pressing the key opens/closes the menu.
Library.ToggleKeybind = Options.MenuKeybind

-- ── ThemeManager ──────────────────────────────────────────────────────────
-- Provides color pickers + theme save/load/export.
-- ApplyToTab adds two groupboxes to the given tab.
local ThemeManager = loadstring(game:HttpGet(repo .. 'ThemeManager.lua'))()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('Packet Hook')            -- themes saved to: Packet Hook/themes/
ThemeManager:ApplyToTab(Tabs['UI Settings'])     -- adds 'Theme' and 'Themes' groupboxes
ThemeManager:LoadAutoloadTheme()                 -- auto-loads last chosen theme on startup

-- ── SaveManager ───────────────────────────────────────────────────────────
-- Serialises all Toggles/Options/Dropdowns/etc to JSON configs.
-- BuildConfigSection adds the 'Save Manager' groupbox to the given tab.
local SaveManager = loadstring(game:HttpGet(repo .. 'SaveManager.lua'))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder('Packet Hook/ExampleGame')  -- configs saved to: Packet Hook/ExampleGame/settings/
-- Prevent internal keys from being saved to configs:
-- SaveManager:SetIgnoreIndexes({ 'ExtraKeyToIgnore' })
SaveManager:BuildConfigSection(Tabs['UI Settings'])  -- adds 'Save Manager' groupbox
SaveManager:LoadAutoloadConfig()                     -- auto-loads last chosen config on startup
