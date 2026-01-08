xpcall(function()
local G,P,LP,ENV=game,game:GetService("Players"),game:GetService("Players").LocalPlayer,getgenv and getgenv() or _G
local lk=false

local function getrandomrobloxuser()
	local randomid=math.random(1,8000)
	local s,e=pcall(function() return P:GetNameFromUserIdAsync(randomid) end)
	if s and e and e~="" then return e,randomid end
	return getrandomrobloxuser()
end

local function applyMorph(c,dat)
	task.spawn(function()
		task.wait(0.05)
		local h=c:FindFirstChildOfClass("Humanoid")
		if not h then return end
		for _,v in c:GetDescendants() do
			if v:IsA("Accessory") or v:IsA("Hat") then v:Destroy() end
		end
		for _,v in c:GetChildren() do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then v:Destroy() end
		end
		local bc=h:FindFirstChildOfClass("BodyColors") if bc then bc:Destroy() end
		local hd=c:FindFirstChild("Head")
		if hd then local ms=hd:FindFirstChildOfClass("SpecialMesh") if ms then ms.MeshId="" ms.TextureId="" end end
		h:ApplyDescriptionClientServer(dat.desc)
		h.DisplayName=dat.fn
	end)
end

local function morphPlayer(victimName)
	local fake,fakeid=getrandomrobloxuser()
	local vid=assert(P:GetUserIdFromNameAsync(victimName))
	local vn=assert(P:GetNameFromUserIdAsync(vid))
	local vp=P:FindFirstChild(vn)
	if not vp then return end
	local desc=assert(P:GetHumanoidDescriptionFromUserId(fakeid))
	local thumb="rbxthumb://type=Avatar&id="..fakeid.."&w=420&h=420"

	local dat={vn=vn,dn=vp.DisplayName,fn=fake,fid=fakeid,vid=vid,desc=desc,thumb=thumb}
	ENV.LAST_MORPH=vn.."_"..fake
	ENV.MORPH_DATA=dat

	local function updateUI(obj)
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			obj:GetPropertyChangedSignal("Text"):Connect(function()
				if lk then return end lk=true
				obj.Text=obj.Text:gsub(dat.vn,dat.fn):gsub(dat.dn,dat.fn)
				lk=false
			end)
			obj.Text=obj.Text:gsub(dat.vn,dat.fn):gsub(dat.dn,dat.fn)
		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			obj:GetPropertyChangedSignal("Image"):Connect(function()
				if lk then return end
				if obj.Image~="" and (obj.Image:find(tostring(dat.vid)) or obj.Image:find("userid="..dat.vid)) then
					lk=true obj.Image=dat.thumb lk=false
				end
			end)
			if obj.Image~="" and (obj.Image:find(tostring(dat.vid)) or obj.Image:find("userid="..dat.vid)) then
				lk=true obj.Image=dat.thumb lk=false
			end
		end
	end

	for _,v in pairs(G:GetDescendants()) do updateUI(v) end
	G.DescendantAdded:Connect(updateUI)

	if vp.Character then applyMorph(vp.Character,dat) end
	vp.CharacterAdded:Connect(function(c)
		applyMorph(c,dat)
		task.wait(0.05)
		for _,v in pairs(G:GetDescendants()) do updateUI(v) end
	end)
end

morphPlayer(LP.Name)
LP.CharacterAdded:Connect(function() morphPlayer(LP.Name) end)
end,function()end)
