repeat
	task.wait()
until game:IsLoaded()

-- Initialization
getgenv().loaded = false
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer
local combat = ReplicatedStorage.Remotes.ServerCombatHandler

getgenv().Settings = {
	Autoraid = { Toggle = false },
}

local function initializeSettings()
	return [[
		local clonef = clonefunction
		local loading = clonef(loadstring)
		loading(game:HttpGet("https://raw.githubusercontent.com/erutluZ/LuaTest/main/testbossraid.lua"))()
		repeat task.wait() until getgenv().loaded == true
		getgenv().Settings = {
			Autoraid = { Toggle = true },
		}
	]]
end

local function handleQueuedTeleport()
	if not _G.queued then
		queue_on_teleport(initializeSettings())
		_G.queued = true
	end
end

local function handleKisukeInteraction()
	local Kisuke = Workspace.NPCs.RaidBoss.Kisuke
	if Kisuke and plr.Character and plr.Character:FindFirstChild("CharacterHandler") then
		if plr.PlayerGui.MissionsUI.MainFrame.Visible then
			if not plr:FindFirstChild("Kisuke") then
				fireclickdetector(Kisuke:FindFirstChildWhichIsA("ClickDetector"))
			else
				plr.Kisuke:FireServer("Yes")
				handleQueuedTeleport()
			end
		else
			plr.Character.CharacterHandler.Remotes.PartyCreate:FireServer()
			handleQueuedTeleport()
		end
	end
end

local function handleCombat(target)
	plr.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	plr.Character.HumanoidRootPart.Velocity = Vector3.new()
	if plr.Character:FindFirstChild("Zanpakuto") then
		plr.Character.CharacterHandler.Remotes.Weapon:FireServer()
	end
	combat:FireServer("LightAttack")
	getgenv().skill = readfile("skill.lua")
	if getgenv().skill then
		local ohString1 = getgenv().skill
		local ohString2 = "Released"
		plr.Character.CharacterHandler.Remotes.Skill:FireServer(ohString1, ohString2)
	end
end

local function handleLowHealthCombat(target)
	plr.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,
50, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	getgenv().skill = readfile("skill.lua")
	if getgenv().skill then
		local ohString1 = "Skill"
		local ohString2 = getgenv().skill
		local ohString3 = "Pressed"
		ReplicatedStorage.Remotes.ServerCombatHandler:FireServer(ohString1, ohString2, ohString3)
	end
end

local function isKarakuraTown()
	local Kisuke = Workspace.NPCs.RaidBoss.Kisuke
	if Kisuke and plr.Character and plr.Character:FindFirstChild("CharacterHandler") then
		handleKisukeInteraction()
	end
end

local function isBossRaidMap()
	if not plr.Character then return end
	for _, target in next, Workspace.Entities:GetChildren() do
		if target.Name ~= plr.Name and target:FindFirstChild("Head") then
			if (plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth) * 100 > 30 then
				handleCombat(target)
			else
				handleLowHealthCombat(target)
			end
		end
	end
	handleQueuedTeleport()
end

local function handleOtherPlaces()
	handleQueuedTeleport()
	if plr.Character then
		local serverlist = ReplicatedStorage.Requests.RequestServerList:InvokeServer("Karakura Town")
		ReplicatedStorage.Requests.RequestCCList:InvokeServer()
		local function teleport()
			if serverlist and not _G.Teleporting then
				for _, server in next, serverlist do
					plr.Character.CharacterHandler.Remotes.ServerListTeleport:FireServer("Karakura Town", server["JobID"])
					_G.Teleporting = true
				end
			end
		end
		teleport()
	end
end

function autoraid()
	if getgenv().Settings.Autoraid.Toggle then
		if game.PlaceId == 14069678431 then
			isKarakuraTown()
		elseif game.PlaceId == 17047374266 then
			isBossRaidMap()
		else
			handleOtherPlaces()
		end
	end
end
