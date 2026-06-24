-- ThemeManager for Packet Hook Library
-- Load via: local ThemeManager = loadstring(game:HttpGet(url))()

local httpService = game:GetService('HttpService')

local ThemeManager = {}
ThemeManager.Folder = 'PacketHook'

function ThemeManager:SetLibrary(library)
	self.Library = library
end

function ThemeManager:SetFolder(folder)
	self.Folder = folder
	self:BuildFolderTree()
end

function ThemeManager:ApplyToTab(tab)
	self:BuildThemeSection(tab)
end

function ThemeManager:BuildFolderTree()
	local parts = {}
	for segment in self.Folder:gmatch('[^/\\]+') do
		table.insert(parts, segment)
		local p = table.concat(parts, '/')
		if not isfolder(p) then makefolder(p) end
	end
	local t = self.Folder .. '/themes'
	if not isfolder(t) then makefolder(t) end
end

function ThemeManager:Save(name)
	local lib = self.Library
	local data = {
		AccentColor     = lib.AccentColor:ToHex(),
		BackgroundColor = lib.BackgroundColor:ToHex(),
		MainColor       = lib.MainColor:ToHex(),
		OutlineColor    = lib.OutlineColor:ToHex(),
		Transparency    = lib.CurrentTransparency or 0,
	}
	local ok, encoded = pcall(httpService.JSONEncode, httpService, data)
	if not ok then return false, 'encode error' end
	writefile(self.Folder .. '/themes/' .. name .. '.json', encoded)
	return true
end

function ThemeManager:Load(name)
	local lib  = self.Library
	local file = self.Folder .. '/themes/' .. name .. '.json'
	if not isfile(file) then return false, 'invalid file' end
	local ok, data = pcall(httpService.JSONDecode, httpService, readfile(file))
	if not ok then return false, 'decode error' end

	local Opts = getgenv().Options

	if data.AccentColor then
		lib.AccentColor = Color3.fromHex(data.AccentColor)
		if Opts and Opts.ThemeAccent then Opts.ThemeAccent:SetValueRGB(lib.AccentColor) end
	end
	if data.BackgroundColor then
		lib.BackgroundColor = Color3.fromHex(data.BackgroundColor)
		if Opts and Opts.ThemeBackground then Opts.ThemeBackground:SetValueRGB(lib.BackgroundColor) end
	end
	if data.MainColor then
		lib.MainColor = Color3.fromHex(data.MainColor)
		if Opts and Opts.ThemeMain then Opts.ThemeMain:SetValueRGB(lib.MainColor) end
	end
	if data.OutlineColor then
		lib.OutlineColor = Color3.fromHex(data.OutlineColor)
		if Opts and Opts.ThemeOutline then Opts.ThemeOutline:SetValueRGB(lib.OutlineColor) end
	end

	lib:UpdateColorsUsingRegistry()

	if data.Transparency ~= nil then
		if Opts and Opts.UiTransparency then
			Opts.UiTransparency:SetValue(data.Transparency)
		else
			lib.SetTransparency(data.Transparency)
		end
	end

	return true
end

function ThemeManager:RefreshThemeList()
	local list = listfiles(self.Folder .. '/themes')
	local out  = {}
	for _, file in next, list do
		if file:sub(-5) == '.json' then
			local pos   = file:find('.json', 1, true)
			local start = pos
			local char  = file:sub(pos, pos)
			while char ~= '/' and char ~= '\\' and char ~= '' do
				pos  = pos - 1
				char = file:sub(pos, pos)
			end
			if char == '/' or char == '\\' then
				table.insert(out, file:sub(pos + 1, start - 1))
			end
		end
	end
	return out
end

function ThemeManager:LoadAutoloadTheme()
	local path = self.Folder .. '/themes/autoload.txt'
	if not isfile(path) then return end
	local name = readfile(path)
	local ok, err = self:Load(name)
	if ok then
		self.Library:Notify("Auto loaded theme '" .. name .. "'", 5)
	else
		self.Library:Notify('Theme autoload failed: ' .. tostring(err), 5)
	end
end

function ThemeManager:BuildThemeSection(tab)
	assert(self.Library, 'Must call ThemeManager:SetLibrary first')
	local lib  = self.Library
	local Opts = getgenv().Options

	-- ── Color pickers (left column) ──────────────────────────────────
	local colorGroup = tab:AddLeftGroupbox('Theme')

	colorGroup:AddLabel('Accent Color'):AddColorPicker('ThemeAccent', {
		Default  = lib.AccentColor,
		Title    = 'Accent Color',
		Callback = function(val)
			lib.AccentColor = val
			lib:UpdateColorsUsingRegistry()
		end,
	})
	colorGroup:AddLabel('Background'):AddColorPicker('ThemeBackground', {
		Default  = lib.BackgroundColor,
		Title    = 'Background',
		Callback = function(val)
			lib.BackgroundColor = val
			lib:UpdateColorsUsingRegistry()
		end,
	})
	colorGroup:AddLabel('Main Color'):AddColorPicker('ThemeMain', {
		Default  = lib.MainColor,
		Title    = 'Main Color',
		Callback = function(val)
			lib.MainColor = val
			lib:UpdateColorsUsingRegistry()
		end,
	})
	colorGroup:AddLabel('Outline Color'):AddColorPicker('ThemeOutline', {
		Default  = lib.OutlineColor,
		Title    = 'Outline Color',
		Callback = function(val)
			lib.OutlineColor = val
			lib:UpdateColorsUsingRegistry()
		end,
	})
	colorGroup:AddSlider('UiTransparency', {
		Text     = 'UI Transparency',
		Default  = 5,
		Min      = 0,
		Max      = 50,
		Rounding = 1,
		Callback = function(val)
			lib.SetTransparency(val / 50)
		end,
	})
	lib.SetTransparency(5 / 50)

	-- ── Theme save/load (left column, below color pickers) ───────────
	local saveGroup = tab:AddLeftGroupbox('Themes')

	saveGroup:AddInput('ThemeManager_ThemeName', {
		Text     = 'Theme name',
		Default  = '',
		Numeric  = false,
		Finished = false,
	})

	saveGroup:AddDropdown('ThemeManager_ThemeList', {
		Text      = 'Theme list',
		Values    = self:RefreshThemeList(),
		AllowNull = true,
	})

	saveGroup:AddButton('Save theme', function()
		local name = Opts.ThemeManager_ThemeName.Value
		if name:gsub(' ', '') == '' then lib:Notify('Theme name is empty', 3) return end
		local ok, err = self:Save(name)
		if ok then
			lib:Notify("Saved theme '" .. name .. "'", 3)
			Opts.ThemeManager_ThemeList:SetValues(self:RefreshThemeList())
			Opts.ThemeManager_ThemeList:SetValue(nil)
		else
			lib:Notify('Save failed: ' .. tostring(err), 4)
		end
	end)

	saveGroup:AddButton('Load theme', function()
		local name = Opts.ThemeManager_ThemeList.Value
		local ok, err = self:Load(name)
		if ok then lib:Notify("Loaded theme '" .. (name or '') .. "'", 3)
		else lib:Notify('Load failed: ' .. tostring(err or 'none selected'), 4) end
	end)

	saveGroup:AddButton('Overwrite theme', function()
		local name = Opts.ThemeManager_ThemeList.Value
		local ok, err = self:Save(name)
		if ok then lib:Notify("Overwrote theme '" .. (name or '') .. "'", 3)
		else lib:Notify('Save failed: ' .. tostring(err or 'none selected'), 4) end
	end)

	saveGroup:AddButton('Refresh list', function()
		Opts.ThemeManager_ThemeList:SetValues(self:RefreshThemeList())
		Opts.ThemeManager_ThemeList:SetValue(nil)
	end)

	local autoloadLbl

	saveGroup:AddButton('Set as autoload', function()
		local name = Opts.ThemeManager_ThemeList.Value
		if not name then lib:Notify('No theme selected', 3) return end
		writefile(self.Folder .. '/themes/autoload.txt', name)
		autoloadLbl:SetText('Theme autoload: ' .. name)
		lib:Notify("'" .. name .. "' set as theme autoload", 3)
	end)

	saveGroup:AddButton('Reset autoload', function()
		local path = self.Folder .. '/themes/autoload.txt'
		if isfile(path) then delfile(path) end
		autoloadLbl:SetText('Theme autoload: none')
		lib:Notify('Theme autoload cleared', 3)
	end)

	autoloadLbl = saveGroup:AddLabel('Theme autoload: none')

	if isfile(self.Folder .. '/themes/autoload.txt') then
		autoloadLbl:SetText('Theme autoload: ' .. readfile(self.Folder .. '/themes/autoload.txt'))
	end
end

ThemeManager:BuildFolderTree()

return ThemeManager
