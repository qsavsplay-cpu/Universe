--[[ Universe Hub | клиентское меню: Fly, Noclip, ESP, WallHop, InfJump, Speed, AntiAFK ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

local parent = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function() if parent:FindFirstChild("UniverseHub") then parent.UniverseHub:Destroy() end end)

local State = {Fly=false, Noclip=false, ESP=false, WallHop=false, InfJump=false, AntiAFK=false, FlySpeed=60, WalkSpeed=16}
local conns = {}

local function char() return LP.Character or LP.CharacterAdded:Wait() end
local function hum() local c = char(); return c:FindFirstChildOfClass("Humanoid") end
local function root() local c = char(); return c:FindFirstChild("HumanoidRootPart") end

-------------------------------------------------- UI
local Gui = Instance.new("ScreenGui")
Gui.Name = "UniverseHub"; Gui.ResetOnSpawn = false; Gui.Parent = parent

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(420, 300)
Main.Position = UDim2.new(0.5, -210, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(18, 16, 32)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(140, 90, 255); stroke.Thickness = 1.5

local grad = Instance.new("UIGradient", Main)
grad.Color = ColorSequence.new(Color3.fromRGB(26, 20, 52), Color3.fromRGB(12, 12, 24))
grad.Rotation = 90

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "✦ UNIVERSE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(200, 170, 255)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.fromOffset(28, 28); Close.Position = UDim2.new(1, -36, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(60, 30, 80); Close.Text = "×"
Close.TextColor3 = Color3.new(1,1,1); Close.Font = Enum.Font.GothamBold; Close.TextSize = 18
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

-- перетаскивание
do
	local dragging, start, startPos
	Title.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, start, startPos = true, i.Position, Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

-- RightShift скрывает/показывает меню
UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Position = UDim2.new(0, 12, 0, 46); Scroll.Size = UDim2.new(1, -24, 1, -58)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3; Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", Scroll); layout.Padding = UDim.new(0, 8)

local function Toggle(name, key, onChange)
	local B = Instance.new("TextButton", Scroll)
	B.Size = UDim2.new(1, -6, 0, 38)
	B.BackgroundColor3 = Color3.fromRGB(32, 28, 58)
	B.Font = Enum.Font.GothamMedium; B.TextSize = 14
	B.TextColor3 = Color3.fromRGB(230, 225, 255); B.TextXAlignment = Enum.TextXAlignment.Left
	B.AutoButtonColor = false
	Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
	Instance.new("UIPadding", B).PaddingLeft = UDim.new(0, 14)

	local dot = Instance.new("Frame", B)
	dot.Size = UDim2.fromOffset(40, 20); dot.Position = UDim2.new(1, -54, 0.5, -10)
	dot.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	local knob = Instance.new("Frame", dot)
	knob.Size = UDim2.fromOffset(16, 16); knob.Position = UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local function render()
		local on = State[key]
		B.Text = name
		TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(70, 60, 100)}):Play()
		TweenService:Create(knob, TweenInfo.new(0.2), {Position = on and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
	end
	B.MouseButton1Click:Connect(function()
		State[key] = not State[key]; render()
		if onChange then onChange(State[key]) end
	end)
	render()
end

local function Slider(name, key, min, max, onChange)
	local F = Instance.new("Frame", Scroll)
	F.Size = UDim2.new(1, -6, 0, 52); F.BackgroundColor3 = Color3.fromRGB(32, 28, 58)
	Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
	local L = Instance.new("TextLabel", F)
	L.BackgroundTransparency = 1; L.Size = UDim2.new(1, -28, 0, 22); L.Position = UDim2.fromOffset(14, 4)
	L.Font = Enum.Font.GothamMedium; L.TextSize = 14; L.TextColor3 = Color3.fromRGB(230,225,255)
	L.TextXAlignment = Enum.TextXAlignment.Left
	local bar = Instance.new("Frame", F)
	bar.Size = UDim2.new(1, -28, 0, 6); bar.Position = UDim2.new(0, 14, 0, 34)
	bar.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame", bar)
	fill.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local function set(v)
		v = math.clamp(math.floor(v), min, max)
		State[key] = v
		L.Text = name .. ": " .. v
		fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
		if onChange then onChange(v) end
	end
	set(State[key])

	local drag = false
	local function upd(x) set(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)) end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i.Position.X) end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
	end)
end

-------------------------------------------------- Fly
local flyBV, flyBG
local function stopFly()
	if conns.fly then conns.fly:Disconnect(); conns.fly = nil end
	if flyBV then flyBV:Destroy() end
	if flyBG then flyBG:Destroy() end
	local h = hum(); if h then h.PlatformStand = false end
end
local function startFly()
	local r, h = root(), hum()
	if not (r and h) then return end
	h.PlatformStand = true
	flyBV = Instance.new("BodyVelocity", r); flyBV.MaxForce = Vector3.new(1e9,1e9,1e9); flyBV.Velocity = Vector3.zero
	flyBG = Instance.new("BodyGyro", r); flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); flyBG.P = 9e4
	conns.fly = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
		flyBG.CFrame = cam.CFrame
	end)
end

-------------------------------------------------- Noclip
local function setNoclip(on)
	if conns.noclip then conns.noclip:Disconnect(); conns.noclip = nil end
	if on then
		conns.noclip = RunService.Stepped:Connect(function()
			local c = LP.Character
			if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
		end)
	end
end

-------------------------------------------------- ESP
local espObjs = {}
local function clearESP()
	for _, o in pairs(espObjs) do pcall(function() o:Destroy() end) end
	espObjs = {}
end
local function addESP(plr)
	if plr == LP or not plr.Character then return end
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(140, 90, 255); h.OutlineColor = Color3.new(1,1,1)
	h.FillTransparency = 0.6; h.Adornee = plr.Character; h.Parent = Gui
	local head = plr.Character:FindFirstChild("Head")
	if head then
		local bb = Instance.new("BillboardGui", Gui)
		bb.Adornee = head; bb.Size = UDim2.fromOffset(120, 20); bb.StudsOffset = Vector3.new(0, 2, 0); bb.AlwaysOnTop = true
		local t = Instance.new("TextLabel", bb)
		t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = plr.DisplayName
		t.TextColor3 = Color3.new(1,1,1); t.TextStrokeTransparency = 0; t.Font = Enum.Font.GothamBold; t.TextSize = 13
		table.insert(espObjs, bb)
	end
	table.insert(espObjs, h)
end
local function setESP(on)
	clearESP()
	if conns.esp then conns.esp:Disconnect(); conns.esp = nil end
	if on then
		for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
		conns.esp = RunService.Heartbeat:Connect(function() end)
		conns.espAdd = Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); if State.ESP then addESP(p) end end) end)
	end
end

-------------------------------------------------- WallHop (авто)
local function setWallHop(on)
	if conns.wall then conns.wall:Disconnect(); conns.wall = nil end
	if not on then return end
	local last = 0
	conns.wall = RunService.Heartbeat:Connect(function()
		local r, h = root(), hum()
		if not (r and h) or not UIS:IsKeyDown(Enum.KeyCode.Space) then return end
		if h.FloorMaterial ~= Enum.Material.Air or tick() - last < 0.25 then return end
		local params = RaycastParams.new(); params.FilterDescendantsInstances = {LP.Character}
		local look = r.CFrame.LookVector
		local hit = workspace:Raycast(r.Position, look * 2.5, params)
		if hit then
			last = tick()
			r.AssemblyLinearVelocity = Vector3.new(-look.X * 18, 50, -look.Z * 18)
			r.CFrame = CFrame.new(r.Position, r.Position + hit.Normal)
		end
	end)
end

-------------------------------------------------- Inf jump / AntiAFK / Speed
UIS.JumpRequest:Connect(function()
	if State.InfJump then local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
LP.Idled:Connect(function()
	if State.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero) end
end)
RunService.Heartbeat:Connect(function()
	local h = hum(); if h and State.WalkSpeed ~= 16 then h.WalkSpeed = State.WalkSpeed end
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	if State.Fly then stopFly(); startFly() end
end)

-------------------------------------------------- Menu
Toggle("✈  Полёт (WASD / Space / Ctrl)", "Fly", function(on) if on then startFly() else stopFly() end end)
Slider("Скорость полёта", "FlySpeed", 20, 200)
Toggle("👻  Noclip", "Noclip", setNoclip)
Toggle("👁  ESP игроков", "ESP", setESP)
Toggle("🧗  Авто-валлхоп (зажми Space у стены)", "WallHop", setWallHop)
Toggle("🦘  Бесконечный прыжок", "InfJump")
Slider("Скорость ходьбы", "WalkSpeed", 16, 150)
Toggle("💤  Anti-AFK", "AntiAFK")

-------------------------------------------------- Extra helpers
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Mouse = LP:GetMouse()

local function Notify(text)
	pcall(function() StarterGui:SetCore("SendNotification", {Title = "Universe", Text = text, Duration = 3}) end)
end

local function Section(text)
	local L = Instance.new("TextLabel", Scroll)
	L.Size = UDim2.new(1, -6, 0, 24); L.BackgroundTransparency = 1
	L.Text = "— " .. text .. " —"; L.Font = Enum.Font.GothamBold; L.TextSize = 13
	L.TextColor3 = Color3.fromRGB(160, 120, 255)
end

local function Button(name, callback)
	local B = Instance.new("TextButton", Scroll)
	B.Size = UDim2.new(1, -6, 0, 38); B.BackgroundColor3 = Color3.fromRGB(60, 40, 110)
	B.Font = Enum.Font.GothamMedium; B.TextSize = 14; B.Text = name
	B.TextColor3 = Color3.fromRGB(240, 235, 255); B.AutoButtonColor = true
	Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
	B.MouseButton1Click:Connect(function() pcall(callback, B) end)
	return B
end

-- радужная обводка меню
task.spawn(function()
	local h = 0
	while Gui.Parent do h = (h + 0.004) % 1; stroke.Color = Color3.fromHSV(h, 0.6, 1); task.wait() end
end)

-------------------------------------------------- Fullbright
local origLight = {Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient}
local function setFullbright(on)
	if conns.fb then conns.fb:Disconnect(); conns.fb = nil end
	if on then
		conns.fb = RunService.RenderStepped:Connect(function()
			Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e6
			Lighting.GlobalShadows = false; Lighting.Ambient = Color3.new(1,1,1)
		end)
	else
		for k, v in pairs(origLight) do Lighting[k] = v end
	end
end

-------------------------------------------------- FOV / Gravity / JumpPower
State.FOV = 70; State.Gravity = 196; State.JumpPower = 50
local origGravity = workspace.Gravity
RunService.RenderStepped:Connect(function()
	if State.FOV ~= 70 then workspace.CurrentCamera.FieldOfView = State.FOV end
end)

-------------------------------------------------- Click TP (Ctrl + ЛКМ)
State.ClickTP = false
Mouse.Button1Down:Connect(function()
	if State.ClickTP and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and Mouse.Hit then
		local r = root(); if r then r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
	end
end)

-------------------------------------------------- X-Ray
local xrayParts = {}
local function setXray(on)
	if on then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("BasePart") and not p:IsDescendantOf(LP.Character or Instance.new("Folder"))
				and not Players:GetPlayerFromCharacter(p.Parent) and p.Transparency < 0.5 then
				xrayParts[p] = p.Transparency; p.Transparency = 0.6
			end
		end
	else
		for p, t in pairs(xrayParts) do if p.Parent then p.Transparency = t end end
		xrayParts = {}
	end
end

-------------------------------------------------- Spin
local function setSpin(on)
	if conns.spin then conns.spin:Disconnect(); conns.spin = nil end
	if on then
		conns.spin = RunService.Heartbeat:Connect(function()
			local r = root(); if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(20), 0) end
		end)
	end
end

-------------------------------------------------- No fall damage / Anti-void
State.AntiVoid = false
RunService.Heartbeat:Connect(function()
	local r = root()
	if State.AntiVoid and r and r.Position.Y < workspace.FallenPartsDestroyHeight + 60 then
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = CFrame.new(r.Position.X, workspace.FallenPartsDestroyHeight + 150, r.Position.Z)
		Notify("Anti-Void спас тебя!")
	end
end)

-------------------------------------------------- Игроки: TP / Spectate
local playerIndex = 0
local function nextPlayer()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(list, p) end end
	if #list == 0 then return nil end
	playerIndex = playerIndex % #list + 1
	return list[playerIndex]
end

local spectating = false
local function stopSpectate()
	spectating = false
	local h = hum(); if h then workspace.CurrentCamera.CameraSubject = h end
end

-------------------------------------------------- FPS Booster
local function boostFPS()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
	end
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end
	end
	Notify("FPS Booster применён")
end

-------------------------------------------------- Меню (расширение)
Section("ПЕРЕДВИЖЕНИЕ")
Slider("Сила прыжка", "JumpPower", 50, 300, function(v)
	local h = hum(); if h then h.UseJumpPower = true; h.JumpPower = v end
end)
Slider("Гравитация", "Gravity", 0, 196, function(v) workspace.Gravity = v end)
Toggle("🖱  Click TP (Ctrl + ЛКМ)", "ClickTP")
Toggle("🌀  Вращение (Spin)", "Spin", setSpin) State.Spin = false
Toggle("🛟  Anti-Void (не падать за карту)", "AntiVoid")

Section("ВИЗУАЛ")
Toggle("☀  Fullbright", "Fullbright", setFullbright) State.Fullbright = false
Toggle("🔍  X-Ray (прозрачные стены)", "Xray", setXray) State.Xray = false
Slider("Поле зрения (FOV)", "FOV", 40, 120)

Section("ИГРОКИ")
Button("📍  ТП к следующему игроку", function()
	local p = nextPlayer(); local r = root()
	if p and r then r.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3); Notify("ТП к " .. p.DisplayName) end
end)
Button("🎥  Наблюдать за игроком / стоп", function()
	if spectating then stopSpectate() return end
	local p = nextPlayer()
	if p then spectating = true; workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid"); Notify("Наблюдаешь за " .. p.DisplayName) end
end)

Section("СЕРВЕР / ПРОЧЕЕ")
Button("⚡  FPS Booster", boostFPS)
Button("🔁  Перезайти на сервер", function() TeleportService:Teleport(game.PlaceId, LP) end)
Button("📋  Скопировать PlaceId", function()
	if setclipboard then setclipboard(tostring(game.PlaceId)); Notify("PlaceId скопирован") end
end)
Button("🗑  Выгрузить Universe", function()
	for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
	stopFly(); setESP(false); setXray(false); setFullbright(false)
	workspace.Gravity = origGravity
	Gui:Destroy()
end)

Notify("Universe загружен! RightShift — меню")

local hint = Instance.new("TextLabel", Scroll)
hint.Size = UDim2.new(1, 0, 0, 20); hint.BackgroundTransparency = 1
hint.Text = "RightShift — скрыть / показать меню"
hint.Font = Enum.Font.Gotham; hint.TextSize = 12; hint.TextColor3 = Color3.fromRGB(140, 130, 180)
