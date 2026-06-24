-- SaveManager for Packet Hook Library
-- Load via: local SaveManager = loadstring(game:HttpGet(url))()

local httpService = game:GetService('HttpService')

local SaveManager = {}

SaveManager.Folder = 'PacketHook'
SaveManager.Ignore = {}
SaveManager.Parser = {
	Toggle = {
		Save = function(idx, o) return { type = 'Toggle', idx = idx, value = o.Value } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] then SaveManager.Options[idx]:SetValue(d.value) end
		end,
	},
	Slider = {
		Save = function(idx, o) return { type = 'Slider', idx = idx, value = tostring(o.Value) } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] then SaveManager.Options[idx]:SetValue(d.value) end
		end,
	},
	Dropdown = {
		Save = function(idx, o) return { type = 'Dropdown', idx = idx, value = o.Value, mutli = o.Multi } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] then SaveManager.Options[idx]:SetValue(d.value) end
		end,
	},
	Colorpicker = {
		Save = function(idx, o) return { type = 'Colorpicker', idx = idx, value = o.Value:ToHex(), transparency = o.Transparency } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] then SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(d.value), d.transparency) end
		end,
	},
	Keybind = {
		Save = function(idx, o) return { type = 'Keybind', idx = idx, mode = o.Mode, key = o.Value } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] then SaveManager.Options[idx]:SetValue(d.key, d.mode) end
		end,
	},
	Input = {
		Save = function(idx, o) return { type = 'Input', idx = idx, text = o.Value } end,
		Load = function(idx, d)
			if SaveManager.Options[idx] and type(d.text) == 'string' then SaveManager.Options[idx]:SetValue(d.text) end
		end,
	},
}

function SaveManager:SetIgnoreIndexes(list)
	for _, key in next, list do self.Ignore[key] = true end
end

function SaveManager:SetFolder(folder)
	self.Folder = folder
	self:BuildFolderTree()
end

function SaveManager:BuildFolderTree()
	local parts = {}
	for segment in self.Folder:gmatch('[^/\\]+') do
		table.insert(parts, segment)
		local p = table.concat(parts, '/')
		if not isfolder(p) then makefolder(p) end
	end
	local s = self.Folder .. '/settings'
	if not isfolder(s) then makefolder(s) end
end

function SaveManager:Save(name)
	if not name then return false, 'no config file is selected' end
	local data = { objects = {} }
	for idx, option in next, SaveManager.Options do
		if not self.Parser[option.Type] then continue end
		if self.Ignore[idx] then continue end
		table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
	end
	local ok, encoded = pcall(httpService.JSONEncode, httpService, data)
	if not ok then return false, 'failed to encode data' end
	writefile(self.Folder .. '/settings/' .. name .. '.json', encoded)
	return true
end

function SaveManager:Load(name)
	if not name then return false, 'no config file is selected' end
	local file = self.Folder .. '/settings/' .. name .. '.json'
	if not isfile(file) then return false, 'invalid file' end
	local ok, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
	if not ok then return false, 'decode error' end
	for _, option in next, decoded.objects do
		if self.Parser[option.type] then
			task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
		end
	end
	return true
end

function SaveManager:RefreshConfigList()
	local list = listfiles(self.Folder .. '/settings')
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
				local name = file:sub(pos + 1, start - 1)
				if name ~= 'options' then table.insert(out, name) end
			end
		end
	end
	return out
end

function SaveManager:SetLibrary(library)
	self.Library = library
	self.Options = getgenv().Options
end

function SaveManager:LoadAutoloadConfig()
	local path = self.Folder .. '/settings/autoload.txt'
	if not isfile(path) then return end
	local name = readfile(path)
	local ok, err = self:Load(name)
	if ok then
		self.Library:Notify("Auto loaded config '" .. name .. "'", 5)
	else
		self.Library:Notify('Autoload failed: ' .. tostring(err), 5)
	end
end

function SaveManager:BuildConfigSection(tab)
	assert(self.Library, 'Must call SaveManager:SetLibrary first')
	local L    = self.Library
	local Opts = self.Options

	local section = tab:AddRightGroupbox('Save Manager')

	section:AddInput('SaveManager_ConfigName', {
		Text     = 'Config name',
		Default  = '',
		Numeric  = false,
		Finished = false,
	})

	section:AddDropdown('SaveManager_ConfigList', {
		Text      = 'Config list',
		Values    = self:RefreshConfigList(),
		AllowNull = true,
	})

	section:AddButton('Create config', function()
		local name = Opts.SaveManager_ConfigName.Value
		if name:gsub(' ', '') == '' then L:Notify('Config name is empty', 3) return end
		local ok, err = self:Save(name)
		if ok then
			L:Notify("Created '" .. name .. "'", 3)
			Opts.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Opts.SaveManager_ConfigList:SetValue(nil)
		else
			L:Notify('Save failed: ' .. err, 4)
		end
	end)

	section:AddButton('Load config', function()
		local name = Opts.SaveManager_ConfigList.Value
		local ok, err = self:Load(name)
		if ok then L:Notify("Loaded '" .. (name or '') .. "'", 3)
		else L:Notify('Load failed: ' .. (err or 'none selected'), 4) end
	end)

	section:AddButton('Overwrite config', function()
		local name = Opts.SaveManager_ConfigList.Value
		local ok, err = self:Save(name)
		if ok then L:Notify("Overwrote '" .. (name or '') .. "'", 3)
		else L:Notify('Save failed: ' .. (err or 'none selected'), 4) end
	end)

	section:AddButton('Refresh list', function()
		Opts.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Opts.SaveManager_ConfigList:SetValue(nil)
	end)

	local autoloadLbl

	section:AddButton('Set as autoload', function()
		local name = Opts.SaveManager_ConfigList.Value
		if not name then L:Notify('No config selected', 3) return end
		writefile(self.Folder .. '/settings/autoload.txt', name)
		autoloadLbl:SetText('Autoload: ' .. name)
		L:Notify("'" .. name .. "' set as autoload", 3)
	end)

	section:AddButton('Reset autoload', function()
		local path = self.Folder .. '/settings/autoload.txt'
		if isfile(path) then delfile(path) end
		autoloadLbl:SetText('Autoload: none')
		L:Notify('Autoload cleared', 3)
	end)

	autoloadLbl = section:AddLabel('Autoload: none')

	if isfile(self.Folder .. '/settings/autoload.txt') then
		autoloadLbl:SetText('Autoload: ' .. readfile(self.Folder .. '/settings/autoload.txt'))
	end

	self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName', 'MenuKeybind' })
end

SaveManager:BuildFolderTree()

return SaveManager
