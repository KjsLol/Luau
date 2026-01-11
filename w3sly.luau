xpcall(function()
local G,P,LP=game,game:GetService("Players"),game:GetService("Players").LocalPlayer
local fake="W1sley_09"
local fakeid=P:GetUserIdFromNameAsync(fake)
local desc=P:GetHumanoidDescriptionFromUserId(fakeid)
local thumb="rbxthumb://type=Avatar&id="..fakeid.."&w=420&h=420"
local vid=LP.UserId
local vn=LP.Name
local dn=LP.DisplayName
local function applyMorph(c)
task.spawn(function()
local h=c:WaitForChild("Humanoid",2)
if not h then return end
local tool=h:FindFirstChildOfClass("Tool")
for _,v in c:GetChildren()do
if v:IsA("Accessory")or v:IsA("Shirt")or v:IsA("Pants")or v:IsA("ShirtGraphic")or v:IsA("CharacterMesh")or v:IsA("BodyColors")then
v:Destroy()
end
end
local hd=c:FindFirstChild("Head")
if hd then
local ms=hd:FindFirstChildOfClass("SpecialMesh")
if ms then ms.MeshId=""ms.TextureId=""end
end
h:ApplyDescriptionClientServer(desc)
h.DisplayName=fake
if tool then h:EquipTool(tool)end
end)
end
local function updateUI(obj)
if obj:IsA("TextLabel")or obj:IsA("TextButton")or obj:IsA("TextBox")then
if obj.Text:find(vn)or obj.Text:find(dn)then
obj.Text=obj.Text:gsub(vn,fake):gsub(dn,fake)
end
obj:GetPropertyChangedSignal("Text"):Connect(function()
obj.Text=obj.Text:gsub(vn,fake):gsub(dn,fake)
end)
elseif obj:IsA("ImageLabel")or obj:IsA("ImageButton")then
if obj.Image:find(tostring(vid))then obj.Image=thumb end
obj:GetPropertyChangedSignal("Image"):Connect(function()
if obj.Image:find(tostring(vid))then obj.Image=thumb end
end)
end
end
if LP.Character then applyMorph(LP.Character)end
LP.CharacterAdded:Connect(applyMorph)
for _,v in G:GetDescendants()do updateUI(v)end
G.DescendantAdded:Connect(updateUI)
end,function()end)
