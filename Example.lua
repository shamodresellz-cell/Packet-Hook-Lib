-- Packet Hook hub — example script
-- Copy this file and rename it for each game you support.

local repo = 'https://raw.githubusercontent.com/shamodresellz-cell/Packet-Hook-Lib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

Library.NotifyOnError = true   -- show errors as notifications instead of crashing executor

local Window = Library:CreateWindow({
    Title        = 'Packet Hook',
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Main            = Window:AddTab('Main',         Library:LucideIcon('sword')),
    ['UI Settings'] = Window:AddTab('UI Settings',  Library:LucideIcon('settings')),
}

-- ── Feature toggles ───────────────────────────────────────────────────
local MainGroup = Tabs.Main:AddLeftGroupbox('Features')

MainGroup:AddToggle('MyFeature', {
    Text    = 'Example Feature',
    Default = false,
})

Toggles.MyFeature:OnChanged(function()
    print('MyFeature toggled:', Toggles.MyFeature.Value)
end)

MainGroup:AddButton('Example Button', function()
    print('Button clicked!')
end)

-- ── UI Settings ───────────────────────────────────────────────────────
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI    = true,
    Text    = 'Menu keybind',
})
Library.ToggleKeybind = Options.MenuKeybind

local ThemeManager = loadstring(game:HttpGet(repo .. 'ThemeManager.lua'))()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('Packet Hook')
ThemeManager:ApplyToTab(Tabs['UI Settings'])
ThemeManager:LoadAutoloadTheme()

local SaveManager = loadstring(game:HttpGet(repo .. 'SaveManager.lua'))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder('Packet Hook/GameName')   -- change GameName per game
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
