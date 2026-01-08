xpcall(function()

local G=game
local P=G:GetService("Players")
local LP=P.LocalPlayer
local ENV=getgenv and getgenv() or _G

local function getrandomrobloxuser()
	local tried={}
	for i=1,1000 do
		local id
		repeat
			id=math.random(1,1e9)
		until not tried[id]
		tried[id]=true
		local ok,name=pcall(P.GetNameFromUserIdAsync,P,id)
		if ok and name and name~="" then
			return name,id
		end
	end
	return LP.Name,LP.UserId
end

local fake,fakeid=getrandomrobloxuser()
local victim=LP.Name
local KEY=victim.."_"..fake

if ENV.LAST_MORPH==KEY then return end
ENV.LAST_MORPH=KEY

if ENV.MORPH_CONN then
	for _,c in ENV.MORPH_CONN do pcall(c.Disconnect,c) end
end
ENV.MORPH_CONN={}

local vp=P:FindFirstChild(victim)
if not vp then return end

local desc=P:GetHumanoidDescriptionFromUserId(fakeid)
local thumb=("rbxthumb://type=Avatar&id=%d&w=420&h=420"):format(fakeid)

local DATA={
	vn=victim,
	dn=vp.DisplayName,
	fn=fake,
	vid=vp.UserId,
	desc=desc,
	thumb=thumb
}

ENV.MORPH_DATA=DATA

local function morph(char)
	task.spawn(function()
		local h=char:WaitForChild("Humanoid",5)
		if not h then return end
		for _,v in char:GetDescendants() do
			if v:IsA("Accessory") or v:IsA("Hat") then v:Destroy() end
		end
		for _,v in char:GetChildren() do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
				v:Destroy()
			end
		end
		local bc=h:FindFirstChildOfClass("BodyColors")
		if bc then bc:Destroy() end
		h:ApplyDescriptionClientServer(DATA.desc)
		h.DisplayName=DATA.fn
	end)
end

if vp.Character then morph(vp.Character) end
table.insert(ENV.MORPH_CONN,vp.CharacterAdded:Connect(morph))

local processed={}
local lock=false

local function spoof(v)
	if processed[v] then return end
	processed[v]=true
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		local function f()
			if lock then return end
			lock=true
			v.Text=v.Text:gsub(DATA.vn,DATA.fn):gsub(DATA.dn,DATA.fn)
			lock=false
		end
		f()
		v:GetPropertyChangedSignal("Text"):Connect(f)
	elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
		local function f()
			if lock then return end
			if v.Image~="" and (v.Image:find(tostring(DATA.vid)) or v.Image:find("userid="..DATA.vid)) then
				lock=true
				v.Image=DATA.thumb
				lock=false
			end
		end
		f()
		v:GetPropertyChangedSignal("Image"):Connect(f)
	end
end

local pg=LP:WaitForChild("PlayerGui")
for _,v in pg:GetDescendants() do spoof(v) end
table.insert(ENV.MORPH_CONN,pg.DescendantAdded:Connect(spoof))

end,function()end)
