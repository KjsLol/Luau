local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/KjsLol/Fluent/refs/heads/main/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/KjsLol/Fluent/refs/heads/main/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/KjsLol/Fluent/refs/heads/main/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({Title = "Car Speed Changer", SubTitle = "Universal", TabWidth = 160, Size = UDim2.fromOffset(580, 460), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl})
local Tabs = {Speed = Window:AddTab({Title = "Speed", Icon = "gauge"}), Flight = Window:AddTab({Title = "Flight", Icon = "plane"}), Settings = Window:AddTab({Title = "Settings", Icon = "settings"})}

local function GetVehicle(d) return d:FindFirstAncestor(LocalPlayer.Name.."\'s Car") or (d:FindFirstAncestor("Body") and d:FindFirstAncestor("Body").Parent) or (d:FindFirstAncestor("Misc") and d:FindFirstAncestor("Misc").Parent) or d:FindFirstAncestorWhichIsA("Model") end

local flightOn, flightSpd, accelMult, accelKey, brakeKey, brakeMult, stopKey = false, 1, 0.01, Enum.KeyCode.W, Enum.KeyCode.S, 0.05, Enum.KeyCode.P
local accelOn, brakeOn, defParent, flightConn, speedConn = false, false

Tabs.Speed:AddSlider("AccelMultiplier", {Title = "Acceleration", Default = 10, Min = 0, Max = 50, Rounding = 1, Callback = function(v) accelMult = v/1000 end})
Tabs.Speed:AddSlider("BrakeForce", {Title = "Brake Force", Default = 50, Min = 0, Max = 300, Rounding = 1, Callback = function(v) brakeMult = v/1000 end})
Tabs.Speed:AddKeybind("AccelKeybind", {Title = "Acceleration Key", Mode = "Hold", Default = "W", ChangedCallback = function(n) accelKey = n end})
Tabs.Speed:AddKeybind("BrakeKeybind", {Title = "Brake Key", Mode = "Hold", Default = "S", ChangedCallback = function(n) brakeKey = n end})
Tabs.Speed:AddKeybind("StopKeybind", {Title = "Stop Vehicle", Mode = "Toggle", Default = "P", ChangedCallback = function(n) stopKey = n end})

local function HandleFlight()
	local c = LocalPlayer.Character if not c then return end
	local h = c:FindFirstChildWhichIsA("Humanoid") if not h then return end
	local s = h.SeatPart
	if not s or not s:IsA("VehicleSeat") then if flightConn then flightConn:Disconnect() flightConn = nil end return end
	local v = GetVehicle(s) if not v or not v:IsA("Model") then return end
	c.Parent = v
	if not v.PrimaryPart then v.PrimaryPart = s.Parent == v and s or v:FindFirstChildWhichIsA("BasePart") end
	local cf = v:GetPrimaryPartCFrame()
	v:SetPrimaryPartCFrame(CFrame.new(cf.Position, cf.Position + workspace.CurrentCamera.CFrame.LookVector) * (UserInputService:GetFocusedTextBox() and CFrame.new() or CFrame.new((UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpd) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -flightSpd) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpd/2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -flightSpd/2) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpd) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -flightSpd) or 0)))
	s.AssemblyLinearVelocity = Vector3.new()
	s.AssemblyAngularVelocity = Vector3.new()
end

local function HandleSpeed()
	local c = LocalPlayer.Character if not c then return end
	local h = c:FindFirstChildWhichIsA("Humanoid") if not h then return end
	local s = h.SeatPart
	if not s or not s:IsA("VehicleSeat") then if speedConn then speedConn:Disconnect() speedConn = nil end return end
	if accelOn then s.AssemblyLinearVelocity *= Vector3.new(1+accelMult, 1, 1+accelMult)
	elseif brakeOn then s.AssemblyLinearVelocity *= Vector3.new(1-brakeMult, 1, 1-brakeMult) end
end

local function UpdateFlight()
	if flightOn then if not flightConn then flightConn = RunService.Heartbeat:Connect(HandleFlight) end
	else if flightConn then flightConn:Disconnect() flightConn = nil end local c = LocalPlayer.Character if c then c.Parent = defParent or c.Parent defParent = c.Parent end end
end

local function UpdateSpeed()
	if accelOn or brakeOn then if not speedConn then speedConn = RunService.Heartbeat:Connect(HandleSpeed) end
	else if speedConn then speedConn:Disconnect() speedConn = nil end end
end

Tabs.Flight:AddToggle("FlightEnabled", {Title = "Flight Enabled", Default = false, Callback = function(v) flightOn = v UpdateFlight() end})
Tabs.Flight:AddSlider("FlightSpeed", {Title = "Flight Speed", Default = 100, Min = 0, Max = 800, Rounding = 1, Callback = function(v) flightSpd = v/100 end})

UserInputService.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == accelKey then accelOn = true UpdateSpeed()
	elseif i.KeyCode == brakeKey then brakeOn = true UpdateSpeed()
	elseif i.KeyCode == stopKey then local c = LocalPlayer.Character if c then local h = c:FindFirstChildWhichIsA("Humanoid") if h then local s = h.SeatPart if s and s:IsA("VehicleSeat") then s.AssemblyLinearVelocity = Vector3.new() s.AssemblyAngularVelocity = Vector3.new() end end end end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode == accelKey then accelOn = false UpdateSpeed()
	elseif i.KeyCode == brakeKey then brakeOn = false UpdateSpeed() end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("CarSpeedChanger")
SaveManager:SetFolder("CarSpeedChanger/Universal")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({Title = "Car Speed Changer", Content = "Script loaded successfully.", Duration = 5})
SaveManager:LoadAutoloadConfig()
