local Bloomware = getgenv().Bloomware
local Tabs = {
    Combat = Bloomware:CreateTab({
        Name = "Combat",
        Flag = "Combat",
        Icon = "Combat"
    }),
    Movement = Bloomware:CreateTab({
        Name = "Movement",
        Flag = "Movement",
        Icon = "Movement"
    }),
    Render = Bloomware:CreateTab({
        Name = "Render",
        Flag = "Render",
        Icon = "Render"
    }),
    Utility = Bloomware:CreateTab({
        Name = "Utility",
        Flag = "Utility",
        Icon = "Utility"
    })
}

local Players: Players = Bloomware.cloneref(game:GetService("Players"))
local VirtualUser: VirtualUser = Bloomware.cloneref(game:GetService("VirtualUser"))
local RunService: RunService = Bloomware.cloneref(game:GetService("RunService"))
local Lighting: Lighting = Bloomware.cloneref(game:GetService("Lighting"))
local HttpService: HttpService = Bloomware.cloneref(game:GetService("HttpService"))
local UserInputService: UserInputService = Bloomware.cloneref(game:GetService("UserInputService"))
local TweenService: TweenService = Bloomware.cloneref(game:GetService("TweenService"))
local VirtualInputManager: VirtualInputManager = Bloomware.cloneref(game:GetService("VirtualInputManager"))

local LocalPlayer = Players.LocalPlayer :: Player
local CurrentCamera: Camera = workspace.CurrentCamera
local Terrain: Terrain = workspace:FindFirstChildOfClass("Terrain")
local MainRequest = http and http.request or request

local Materials = {}
for _, Material: Enum.Material in next, Enum.Material:GetEnumItems() do
    table.insert(Materials, Material.Name)
end

pcall(setthreadidentity, 8);
(function()
    local SpeedData = {
        Settings = {
            Speed = 50,
            PulseDelay = 0,
            PulseTime = 2,
            JumpDelay = 2,
            Mode = "Velocity",
            AutoJump = false,
            Pulse = false,
            WallCheck = false,
            IgnoreTerrain = false
        },
        Data = {
            LastGroundTouch = os.clock(),
            RayPram = RaycastParams.new()
        },
        OldData = {
            Walkspeed = nil
        }
    }

    local Speed = Tabs.Movement:CreateModule({
        Name = "Speed",
        Flag = "UniversalSpeed",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Bloomware:IsAlive(LocalPlayer) then
                    SpeedData.OldData.Walkspeed = LocalPlayer.Character.Humanoid.WalkSpeed    
                end

                repeat
                    local Fly = Tabs.Movement.Modules.UniversalFly
                    if Bloomware:IsAlive(LocalPlayer) and (Fly and not Fly.Enabled or not Fly) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        if Humanoid.MoveDirection.Magnitude > 0 then
                            if SpeedData.Settings.WallCheck then
                                SpeedData.Data.RayPram.FilterType = Enum.RaycastFilterType.Exclude
                                SpeedData.Data.RayPram.FilterDescendantsInstances = {LocalPlayer.Character}

                                local Ray: RaycastResult? = workspace:Raycast(Root.Position, Humanoid.MoveDirection * 5, SpeedData.Data.RayPram)
                                if Ray and (SpeedData.Settings.IgnoreTerrain and Ray.Instance ~= workspace.Terrain or not SpeedData.Settings.IgnoreTerrain) then
                                    task.wait()
                                    continue
                                end
                            end

                            if SpeedData.Settings.AutoJump then
                                if Humanoid.FloorMaterial ~= Enum.Material.Air then
                                    if (os.clock() - SpeedData.Data.LastGroundTouch) >= SpeedData.Settings.JumpDelay then
                                        SpeedData.Data.LastGroundTouch = os.clock()
                                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                end
                            end

                            local IndexVal: number = 1
                            if SpeedData.Settings.Pulse then
                                IndexVal = (SpeedData.Settings.PulseTime * 80)
                                if 0 >= IndexVal then
                                    IndexVal = 1
                                end
                            end

                            local Speed: number = SpeedData.Settings.Speed
                            if SpeedData.Settings.Mode == "Velocity" then
                                local CurrentVelocity: Vector3 = Vector3.zero
                                for i = 1, IndexVal do
                                    if not self.Enabled then
                                        break
                                    end

                                    CurrentVelocity = Root.AssemblyLinearVelocity
                                    Root.AssemblyLinearVelocity = Vector3.new(Humanoid.MoveDirection.X * Speed, CurrentVelocity.Y, Humanoid.MoveDirection.Z * Speed) 
                                    if SpeedData.Settings.Pulse then
                                        task.wait(0.01)
                                    end
                                end
                            elseif SpeedData.Settings.Mode == "CFrame" then
                                for i = 1, IndexVal do
                                    Speed = (SpeedData.Settings.Speed/150)
                                    Root.CFrame += Vector3.new(Humanoid.MoveDirection.X * Speed, 0, Humanoid.MoveDirection.Z * Speed)
                                    if SpeedData.Settings.Pulse then
                                        task.wait(0.01)
                                    end
                                end
                            elseif SpeedData.Settings.Mode == "TP" then
                                for i = 1, math.clamp(IndexVal/10, 1, math.huge) do
                                    Speed = (SpeedData.Settings.Speed/60)
                                    Root.CFrame += Vector3.new(Humanoid.MoveDirection.X * Speed, 0, Humanoid.MoveDirection.Z * Speed)
                                    task.wait(0.1)
                                end
                            else
                                Humanoid.WalkSpeed = Speed
                            end

                            if SpeedData.Settings.Pulse then
                                task.wait(SpeedData.Settings.PulseDelay)
                            end
                        end
                    end
                    task.wait()
                until not self.Enabled
            else
                if Bloomware:IsAlive(LocalPlayer) and SpeedData.OldData.Walkspeed then
                    LocalPlayer.Character.Humanoid.WalkSpeed = SpeedData.OldData.Walkspeed
                end
            end
        end
    })

    Speed:Dropdown({
        Name = "Mode",
        Flag = "UniversalSpeedMode",
        Default = "Velocity",
        Options = {"Velocity", "CFrame", "TP", "Walkspeed"},
        CallingFunction = function(self, Value: string)
            SpeedData.Settings.Mode = Value
        end
    })

    Speed:Slider({
        Name = "Speed",
        Flag = "UniversalSpeedValue",
        Default = 50,
        Min = 0,
        Max = 100,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.Speed = value
        end
    })

    local PulseDelay = Speed:Slider({
        Name = "Pulse Delay",
        Flag = "UniversalPulseDelay",
        Default = 2,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.PulseDelay = value
        end
    })

    local PulseTime = Speed:Slider({
        Name = "Pulse Time",
        Flag = "UniversalPulseTime",
        Default = 2,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.PulseTime = value
        end
    })

    local JumpDelay = Speed:Slider({
        Name = "Jump Delay",
        Flag = "UniversalSpeedAutoJumpDelay",
        Default = 0,
        Min = 0,
        Max = 5,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.JumpDelay = value
        end
    })
    
    Speed:MiniToggle({
        Name = "Auto Jump",
        Flag = "UniversalSpeedAutoJump",
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.AutoJump = value
            JumpDelay:SetVisiblity(value)
        end
    })

    Speed:MiniToggle({
        Name = "Pulse",
        Flag = "UniversalSpeedPulse",
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.Pulse = value

            PulseDelay:SetVisiblity(value)
            PulseTime:SetVisiblity(value)
        end
    })

    local IgnoreTerrain = Speed:MiniToggle({
        Name = "Ignore Terrain",
        Flag = "UniversalSpeedWallCheckIgnoreTerrain",
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.IgnoreTerrain = value
        end
    })

    Speed:MiniToggle({
        Name = "Wall Check",
        Flag = "UniveralSpeedWallCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.WallCheck = value
            IgnoreTerrain:SetVisiblity(value)
        end
    })
end)();

(function()
    local FlyData = {
        Settings = {
            Speed = 50,
            VerticalSpeed = 80,
            PulseDelay = 2,
            PulseTime = 2,
            SpeedMode = "Velocity",
            Pulse = false
        },
        Data = {
            Vertical = 0,
            LastBoosted = os.clock()
        }
    }

    local Fly = Tabs.Movement:CreateModule({
        Name = "Fly",
        Flag = "UniversalFly",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(RunService.PreAnimation:Connect(function(Delta: number)
                    if Bloomware:IsAlive(LocalPlayer) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        local IndexVal: number = 1
                        if FlyData.Settings.Pulse then
                            IndexVal = (FlyData.Settings.PulseTime * 60)
                            if 0 >= IndexVal then
                                IndexVal = 1
                            end
                        end

                        if FlyData.Settings.SpeedMode == "TP" then
                            IndexVal = math.clamp(IndexVal/10, 1, math.huge)
                        end

                        for i = 1, IndexVal do
                            local YValue: number = 0
                            local Speed: number = FlyData.Settings.Speed
                            local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                            local SpeedVelocity: Vector3 = CurrentVelocity

                            if FlyData.Data.Vertical ~= 0 then
                                if FlyData.Data.Vertical == 1 then
                                    YValue = FlyData.Settings.VerticalSpeed
                                elseif FlyData.Data.Vertical == -1 then
                                    YValue = -FlyData.Settings.VerticalSpeed
                                end
                            end

                            if ((os.clock() - FlyData.Data.LastBoosted) >= FlyData.Settings.PulseDelay or not FlyData.Settings.Pulse) then
                                if FlyData.Settings.SpeedMode == "Velocity" then
                                    SpeedVelocity = Vector3.new(Humanoid.MoveDirection.X * Speed, 0, Humanoid.MoveDirection.Z * Speed) 
                                elseif FlyData.Settings.SpeedMode == "CFrame" then
                                    Speed /= 150
                                    Root.CFrame += Vector3.new(Humanoid.MoveDirection.X * Speed, 0, Humanoid.MoveDirection.Z * Speed)
                                elseif FlyData.Settings.SpeedMode == "TP" then
                                    task.delay(Random.new():NextNumber(0.1, 0.3), function()
                                        Speed /= 60
                                        Root.CFrame += Vector3.new(Humanoid.MoveDirection.X * Speed, 0, Humanoid.MoveDirection.Z * Speed)
                                    end)
                                end
                            end

                            if Humanoid.MoveDirection.Magnitude <= 0 then
                                SpeedVelocity = Vector3.zero
                            end

                            Root.AssemblyLinearVelocity = Vector3.new(
                                SpeedVelocity.X,
                                YValue + (CurrentVelocity.Y > 0 and 1 or -CurrentVelocity.Y),
                                SpeedVelocity.Z
                            )

                            if FlyData.Settings.Pulse and (os.clock() - FlyData.Data.LastBoosted) >= FlyData.Settings.PulseDelay then
                                task.wait(0.01)
                            end
                        end

                        if (os.clock() - FlyData.Data.LastBoosted) >= FlyData.Settings.PulseDelay then
                            FlyData.Data.LastBoosted = os.clock()
                        end
                    end
                end))
            end
        end
    })

    Fly.Functions:KeyBind({
        Name = "Fly Up",
        MobileText = "Fly Up",
        Flag = "UniversalFlyUpKyebind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.Space,
        Events = {
            Began = function()
                FlyData.Data.Vertical = 1
            end,
            Ended = function()
                FlyData.Data.Vertical = 0
            end
        }
    })

    Fly.Functions:KeyBind({
        Name = "Fly Down",
        MobileText = "Fly Down",
        Flag = "UniversalFlyDownKyebind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.LeftControl,
        Events = {
            Began = function()
                FlyData.Data.Vertical = -1
            end,
            Ended = function()
                FlyData.Data.Vertical = 0
            end
        }
    })

    Fly:Slider({
        Name = "Speed",
        Flag = "UniversalFlySpeed",
        Default = 50,
        Min = 0,
        Max = 100,
        CallingFunction = function(self, value: number)
            FlyData.Settings.Speed = value
        end
    })

    Fly:Slider({
        Name = "Vertical Speed",
        Flag = "UniversalVerticalFlySpeed",
        Default = 70,
        Min = 0,
        Max = 130,
        CallingFunction = function(self, value: number)
            FlyData.Settings.VerticalSpeed = value
        end
    })

    local FlyPulseDelay = Fly:Slider({
        Name = "Pulse Delay",
        Flag = "UniversaFlylPulseDelay",
        Default = 2,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            FlyData.Settings.PulseDelay = value
        end
    })

    local FlyPulseTime = Fly:Slider({
        Name = "Pulse Time",
        Flag = "UniversalFlyPulseTime",
        Default = 2,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            FlyData.Settings.PulseTime = value
        end
    })

    Fly:Dropdown({
        Name = "Speed Mode",
        Flag = "UniversalFlySpeedMode",
        Default = "Velocity",
        Options = {"Velocity", "CFrame", "TP"},
        CallingFunction = function(self, Value: string)
            FlyData.Settings.SpeedMode = Value
        end
    })

    Fly:MiniToggle({
        Name = "Pulse",
        Flag = "UniversalFlySpeedPulse",
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.Pulse = value

            FlyPulseDelay:SetVisiblity(value)
            FlyPulseTime:SetVisiblity(value)
        end
    })
end)();

(function()
    local OldFov: number?, NewFov: number = nil, 120
    local FovChanger = Tabs.Render:CreateModule({
        Name = "FOV",
        Flag = "UniversalFOVChanger",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if CurrentCamera then
                    OldFov = CurrentCamera.FieldOfView
                    CurrentCamera.FieldOfView = NewFov
                    self:Connection(CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                        CurrentCamera.FieldOfView = NewFov
                    end))
                end
            else
                if OldFov then
                    CurrentCamera.FieldOfView = OldFov
                end
            end
        end
    })
    
    FovChanger:Slider({
        Name = "FOV",
        Flag = "UniversalFOVValue",
        Default = 120,
        Min = 0,
        Max = 120,
        CallingFunction = function(self, value: number)
            NewFov = value
            if FovChanger.Enabled and CurrentCamera then
                CurrentCamera.FieldOfView = NewFov
            end
        end
    })
end)();

(function()
    Tabs.Utility:CreateModule({
        Name = "Anti AFK",
        Flag = "UniversalAntiAFK",
        CallingFunction = function(self, enabled: boolean)
            if getconnections then
                local Cons: {{Disable: () -> (), Enable: () -> ()}} = getconnections(LocalPlayer.Idled)
                for i,v in Cons do
                    if enabled then
                        v:Disable()
                    else
                        v:Enable()
                    end
                end
            else
                self:Connection(LocalPlayer.Idled:Connect(function()
                    VirtualUser:ClickButton2(Vector2.zero)
                end))
            end
        end
    })
end)();

(function()
    local AimbotData = {
        Settings = {
            Smoothness = 0,
            CircleSize = 80,
            Distance = 50,
            CircleEnabled = true,
            Mode = "Smooth",
            Prediction = false,
            PredictionAmount = 0.12,
            Jitter = false,
            JitterAmount = 0,
            Deadzone = 0,
            TeamCheck = false,
            TriggerDistance = false,
            WallCheck = false,
            UseTriggerButton = false,
            TargetPart = "HumanoidRootPart",
            CircleColor = Color3.fromRGB(255, 0, 0)
        },
        Data = {
            RayParams = RaycastParams.new(),
            Circle = nil,
            HoldingTrigger = false,
        }
    }

    local AimRandom = Random.new()

    local function GetAimPosition(TargetPart: BasePart): Vector3
        local Position = TargetPart.Position

        if AimbotData.Settings.Prediction then
            Position += TargetPart.AssemblyLinearVelocity * AimbotData.Settings.PredictionAmount
        end

        if AimbotData.Settings.Jitter and AimbotData.Settings.JitterAmount > 0 then
            local Amount = AimbotData.Settings.JitterAmount / 100
            local Right = CurrentCamera.CFrame.RightVector * AimRandom:NextNumber(-Amount, Amount)
            local Up = CurrentCamera.CFrame.UpVector * AimRandom:NextNumber(-Amount, Amount)
            Position += Right + Up
        end

        return Position
    end

    local function AimAt(Position: Vector3, Delta: number)
        local NewCF = CFrame.new(CurrentCamera.CFrame.Position, Position)

        if AimbotData.Settings.Mode == "Snap" or AimbotData.Settings.Smoothness >= 100 then
            CurrentCamera.CFrame = NewCF
        elseif AimbotData.Settings.Mode == "Humanized" then
            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(NewCF, math.clamp((AimbotData.Settings.Smoothness * Delta) * 0.65, 0, 1))
        else
            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(NewCF, math.clamp(AimbotData.Settings.Smoothness * Delta, 0, 1))
        end
    end

    local function IsPathClear(target, TargetPart: Part?): boolean
        if not AimbotData.Settings.WallCheck then
            return true 
        end

        local Excluded: {Model} = {LocalPlayer.Character}
        for i,v in Players:GetPlayers() do
            if v ~= LocalPlayer and Bloomware:IsAlive(v) then
                table.insert(Excluded, v.Character)
            end
        end

        AimbotData.Data.RayParams.FilterType = Enum.RaycastFilterType.Exclude
        AimbotData.Data.RayParams.FilterDescendantsInstances = Excluded

        local Start: Vector3 = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * 1
        if TargetPart then
            local Direction: Vector3 = (TargetPart.Position - Start)
            local Distance: number = Direction.Magnitude
            Direction = Direction.Unit * math.min(Distance, 1000)
            local Ray: RaycastResult? = workspace:Raycast(Start, Direction, AimbotData.Data.RayParams)
            
            if not Ray or (Ray.Instance and Ray.Instance:IsDescendantOf(target)) then
                table.clear(Excluded)
                return true
            end
        end

        table.clear(Excluded)
        return false
    end

    local Aimbot = Tabs.Combat:CreateModule({
        Name = "Aimbot",
        Flag = "UniversalAimbot",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if AimbotData.Settings.CircleEnabled and not AimbotData.Data.Circle then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = true
                    Circle.Color = AimbotData.Settings.CircleColor
                    Circle.Radius = AimbotData.Settings.CircleSize
                    Circle.Thickness = 2
                    Circle.Filled = false
                    Circle.Transparency = 0.8
                    AimbotData.Data.Circle = Circle
                end

                self:Connection(RunService.PreRender:Connect(function(Delta: number)
                    if not Bloomware:IsAlive(LocalPlayer) then 
                        return 
                    end

                    if AimbotData.Data.Circle then
                        AimbotData.Data.Circle.Position = UserInputService:GetMouseLocation()
                    end

                    if not AimbotData.Data.HoldingTrigger and AimbotData.Settings.UseTriggerButton then return end

                    local NearestToMouse: {DistanceFromMouse: number, DistanceFromPlayer: number, Player: Player?, Character: Model?} = Bloomware:GetNerestPlayerToMouse({
                        TeamCheck = AimbotData.Settings.TeamCheck,
                        Exclude = {LocalPlayer},
                    })

                    if NearestToMouse.Player and NearestToMouse.Character then
                        local Target = NearestToMouse.Character
                        local TargetPart = Target:FindFirstChild(AimbotData.Settings.TargetPart) or (Target.PrimaryPart or Target:FindFirstChild("HumanoidRootPart"))
                        if TargetPart then
                            local Pos, OnScreen = CurrentCamera:WorldToViewportPoint(TargetPart.Position)
                            local MousePos = UserInputService:GetMouseLocation()
                            local DistToMouse = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude

                            if OnScreen and (DistToMouse <= AimbotData.Settings.CircleSize or not AimbotData.Settings.CircleEnabled) then
                                if AimbotData.Settings.Deadzone > 0 and DistToMouse <= AimbotData.Settings.Deadzone then
                                    return
                                end

                                if AimbotData.Settings.TriggerDistance and NearestToMouse.DistanceFromPlayer >= AimbotData.Settings.Distance then
                                    return
                                end
                                
                                if not IsPathClear(Target, TargetPart) then 
                                    return 
                                end

                                AimAt(GetAimPosition(TargetPart), Delta)
                            end
                        end
                    end
                end))
            else
                if AimbotData.Data.Circle then
                    AimbotData.Data.Circle:Destroy()
                    AimbotData.Data.Circle = nil
                end
            end
        end
    })

    local KeyTrigger = Aimbot.Functions:KeyBind({
        Name = "Trigger",
        MobileText = "Trigger",
        Flag = "UniversalAimbotTrigger",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.UserInputType.MouseButton2,
        Events = {
            Began = function()
                AimbotData.Data.HoldingTrigger = true
            end,
            Ended = function()
                AimbotData.Data.HoldingTrigger = false
            end
        }
    })

    local AimParts: {string} = {"HumanoidRootPart", "Head"}
    if LocalPlayer.Character then
        for i,v in LocalPlayer.Character:GetChildren() do
            if (v:IsA("Part") or v:IsA("MeshPart")) and not table.find(AimParts, v.Name) then
                table.insert(AimParts, v.name)
            end
        end
    end

    Aimbot:Dropdown({
        Name = "Part",
        Flag = "AimbotPart",
        Default = "Head",
        Options = AimParts,
        CallingFunction = function(self, Value: string)
            AimbotData.Settings.TargetPart = Value
        end
    })

    Aimbot:Dropdown({
        Name = "Mode",
        Flag = "AimbotMode",
        Default = "Smooth",
        Options = {"Smooth", "Snap", "Humanized"},
        CallingFunction = function(self, value: string)
            AimbotData.Settings.Mode = value
        end
    })

    Aimbot:Slider({
        Name = "Aim Speed",
        Flag = "AimbotSpeed",
        Default = 50,
        Min = 1,
        Max = 50,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Smoothness = value
        end
    })

    Aimbot:Slider({
        Name = "Deadzone",
        Flag = "AimbotDeadzone",
        Default = 20,
        Min = 0,
        Max = 50,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Deadzone = value
        end
    })

    Aimbot:Slider({
        Name = "Prediction",
        Flag = "AimbotPredictionAmount",
        Default = 0.12,
        Min = 0,
        Max = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.PredictionAmount = value
        end
    })

    Aimbot:Slider({
        Name = "Jitter",
        Flag = "AimbotJitterAmount",
        Default = 5,
        Min = 1,
        Max = 20,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.JitterAmount = value
        end
    })

    local FovSize = Aimbot:Slider({
        Name = "FOV Size",
        Flag = "AimbotFOVSize",
        Default = 80,
        Min = 1,
        Max = 450,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.CircleSize = value
            if AimbotData.Data.Circle then
                AimbotData.Data.Circle.Radius = value
            end
        end
    })

    Aimbot:Slider({
        Name = "Distance",
        Flag = "AimbotDistance",
        Default = 50,
        Min = 1,
        Max = 100,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Distance = value
        end
    })

    local FovColor = Aimbot:ColorSlider({
        Name = "FOV Color",
        Flag = "AimbotFOVCircleColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, Color: Color3)
            AimbotData.Settings.CircleColor = Color
            if AimbotData.Data.Circle then
                AimbotData.Data.Circle.Color = Color
            end
        end
    })

    Aimbot:MiniToggle({
        Name = "FOV",
        Flag = "AimbotFOV",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.CircleEnabled = value

            FovColor:SetVisiblity(value)
            FovSize:SetVisiblity(value)
            if not AimbotData.Data.Circle then
                if Aimbot.Enabled then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = true
                    Circle.Color = AimbotData.Settings.CircleColor
                    Circle.Radius = AimbotData.Settings.CircleSize
                    Circle.Thickness = 2
                    Circle.Filled = false
                    Circle.Transparency = 0.8
                    AimbotData.Data.Circle = Circle
                end
            else
                if not value then
                    AimbotData.Data.Circle:Destroy()
                    AimbotData.Data.Circle = nil
                end
            end
        end
    })

    Aimbot:MiniToggle({
        Name = "Team Check",
        Flag = "AimbotTeamCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.TeamCheck = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Distance Check",
        Flag = "AimbotDistanceCheck",
        CallingFunction = function(self, value: number)
            AimbotData.Settings.TriggerDistance = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Wall Check",
        Flag = "AimbotWallCheck",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.WallCheck = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Prediction",
        Flag = "AimbotPrediction",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.Prediction = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Jitter",
        Flag = "AimbotJitter",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.Jitter = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Trigger Button",
        Flag = "UniversalAimbotTriggerButton",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.UseTriggerButton = value
            KeyTrigger:SetVisiblity(value)
        end
    })
end)();

(function()
    local OldTime = Lighting.ClockTime
    Tabs.Render:CreateModule({
        Name = "Bloomware",
        Flag = "UniversalBloomware",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                OldTime = Lighting.ClockTime
                Lighting.ClockTime = 0
                self:Connection(Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
                    Lighting.ClockTime = 0
                end))
            else
                Lighting.ClockTime = OldTime
            end
        end
    })
end)();

(function()
    local ESP
    local ESPData = {
        Settings = {
            TeamCheck = false,
            TeamColor = false,
            FillBoxes = false,
            Boxes = false,
            Health = false,
            Name = false,
            BoxMode = "Box",
            ESPMode = "Dynamic",
            Color = Color3.fromRGB(255, 0, 0),
            FillColor = Color3.fromRGB(0, 0, 0),
        },
        Data = {
            BoxOutline = nil,
            BoxFill = nil,
            HealthBarOutline = nil,
            HealthBar = nil,
            NameTag = nil,
            UpdateConnection = nil,
            SkeletonLines = {},
            Instances = {}
        }
    }

    local DrawPairs = {
        {"Head", "UpperTorso", "Head", "Torso", nil, CFrame.new(0, -0.2, 0)},
        {"UpperTorso", "LowerTorso", "Torso", "Torso", CFrame.new(0, 0.5, 0), CFrame.new(0, -0.5, 0)},
        {"UpperTorso", "LeftUpperArm", "Torso", "Left Arm", CFrame.new(0, 0.5, 0), CFrame.new(0, 0.5, 0)},
        {"LeftUpperArm", "LeftLowerArm", "Left Arm", "Left Arm", CFrame.new(0, 0.5, 0), CFrame.new(0, -0.5, 0)},
        {"LeftLowerArm", "LeftHand", "Left Arm", "Left Arm", nil, nil},
        {"UpperTorso", "RightUpperArm", "Torso", "Right Arm", CFrame.new(0, 0.5, 0), CFrame.new(0, 0.5, 0)},
        {"RightUpperArm", "RightLowerArm", "Right Arm", "Right Arm", CFrame.new(0, 0.5, 0), CFrame.new(0, -0.5, 0)},
        {"RightLowerArm", "RightHand", "Right Arm", "Right Arm", nil, nil},
        {"LowerTorso", "LeftUpperLeg", "Torso", "Left Leg", CFrame.new(0, -0.5, 0), CFrame.new(0, 0.5, 0)},
        {"LowerTorso", "RightUpperLeg", "Torso", "Right Leg", CFrame.new(0, -0.5, 0), CFrame.new(0, 0.5, 0)},
        {"LeftUpperLeg", "LeftLowerLeg", "Left Leg", "Left Leg", CFrame.new(0, 0.5, 0), CFrame.new(0, -0.5, 0)},
        {"RightUpperLeg", "RightLowerLeg", "Right Leg", "Right Leg", CFrame.new(0, 0.5, 0), CFrame.new(0, -0.5, 0)},
        {"LeftLowerLeg", "LeftFoot", "Left Leg", "Left Leg", nil, nil},
        {"RightLowerLeg", "RightFoot", "Right Leg", "Right Leg", nil, nil}
    }

    local function CreateESP(Target: Player)
        local BoxOutline = Drawing.new("Quad")
        BoxOutline.Visible = false
        BoxOutline.Thickness = 1
        BoxOutline.Transparency = 0.7
        BoxOutline.Filled = false
        BoxOutline.Color = ESPData.Settings.Color

        local BoxFill = Drawing.new("Quad")
        BoxFill.Visible = false
        BoxFill.Transparency = 0.5
        BoxFill.Filled = true
        BoxFill.Color = ESPData.Settings.FillColor

        local HealthBarOutline = Drawing.new("Line")
        HealthBarOutline.Visible = false
        HealthBarOutline.Thickness = 3
        HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)

        local HealthBar = Drawing.new("Line")
        HealthBar.Visible = false
        HealthBar.Thickness = 1.5

        local NameTag = Drawing.new("Text")
        NameTag.Visible = false
        NameTag.Center = true
        NameTag.Outline = true
        NameTag.Size = 14
        NameTag.Color = ESPData.Settings.Color

        local SkeletonLines = {}
        local function CreateBone()
            local Line = Drawing.new("Line")
            Line.Visible = false
            Line.Thickness = 2
            Line.Transparency = 1
            Line.Color = ESPData.Settings.Color
            table.insert(SkeletonLines, Line)

            return Line
        end

        for _ = 1, #DrawPairs do
            CreateBone()
        end

        local function DrawCorneredBox(topLeft, topRight, bottomLeft, bottomRight, color)
            if ESPData.Settings.Boxes then
                local cornerLength = 15
                local width = math.abs(tonumber(topRight.X - topLeft.X))
                local height = math.abs(tonumber(bottomLeft.Y - topLeft.Y))
                local cornerLengthX = math.min(cornerLength, width * 0.25)
                local cornerLengthY = math.min(cornerLength, height * 0.25)

                local cornerLines = {}
                table.insert(cornerLines, {Vector2.new(topLeft.X + cornerLengthX, topLeft.Y), topLeft})
                table.insert(cornerLines, {Vector2.new(topLeft.X, topLeft.Y - cornerLengthY), topLeft})
                table.insert(cornerLines, {Vector2.new(topRight.X - cornerLengthX, topRight.Y), topRight})
                table.insert(cornerLines, {Vector2.new(topRight.X, topRight.Y - cornerLengthY), topRight})
                table.insert(cornerLines, {Vector2.new(bottomLeft.X + cornerLengthX, bottomLeft.Y), bottomLeft})
                table.insert(cornerLines, {Vector2.new(bottomLeft.X, bottomLeft.Y + cornerLengthY), bottomLeft})
                table.insert(cornerLines, {Vector2.new(bottomRight.X - cornerLengthX, bottomRight.Y), bottomRight})
                table.insert(cornerLines, {Vector2.new(bottomRight.X, bottomRight.Y + cornerLengthY), bottomRight})

                for i = 1, math.min(8, #cornerLines) do
                    local Line = SkeletonLines[i]
                    if Line then
                        local from, to = cornerLines[i][1], cornerLines[i][2]
                        Line.From = from
                        Line.To = to
                        Line.Color = color
                        Line.Visible = true
                    end
                end

                for i = 9, #SkeletonLines do
                    SkeletonLines[i].Visible = false
                end
            else
                BoxOutline.Visible = false
                for _, L in next, SkeletonLines do 
                    L.Visible = false 
                end
            end
        end

        local function Update()
            if not ESPData.Data.Instances[Target] then 
                return 
            end

            if Bloomware:IsAlive(Target) then
                local Humanoid: Humanoid = Target.Character:FindFirstChildOfClass("Humanoid")
                local Root: BasePart = Target.Character.PrimaryPart or Target.Character:FindFirstChild("HumanoidRootPart")
                local _, OnScreen = CurrentCamera:WorldToViewportPoint(Root.Position)
                if ESPData.Settings.TeamCheck and Target.Team and LocalPlayer.Team and Target.Team == LocalPlayer.Team or not OnScreen then
                    BoxOutline.Visible = false
                    BoxFill.Visible = false
                    HealthBar.Visible = false
                    HealthBarOutline.Visible = false
                    NameTag.Visible = false
                    for _, L in next, SkeletonLines do 
                        L.Visible = false 
                    end

                    return
                end

                if OnScreen then
                    if ESPData.Settings.ESPMode == "Dynamic" then
                        local Coords = {}
                        for _, Part in next, Target.Character:GetChildren() do
                            if Part:IsA("BasePart") then
                                local Adjusted = Part.CFrame
                                if Part.Name == "Head" then
                                    Adjusted = Part.CFrame * CFrame.new(0, Part.Size.Y / 2, 0)
                                elseif Part == Root then
                                    Adjusted = Part.CFrame * CFrame.new(0, 0, -Part.Size.Z)
                                elseif string.find(tostring(Part.Name), "Left") then
                                    Adjusted = Part.CFrame * CFrame.new(-Part.Size.X / 2, 0, 0)
                                elseif string.find(tostring(Part.Name), "Right") then
                                    Adjusted = Part.CFrame * CFrame.new(Part.Size.X / 2, 0, 0)
                                end
                                local Screen, Visible = CurrentCamera:WorldToViewportPoint(Adjusted.Position)
                                if Visible then
                                    table.insert(Coords, Screen)
                                end
                            end
                        end

                        if #Coords > 0 then
                            local MinX, MaxX, MinY, MaxY = math.huge, -math.huge, math.huge, -math.huge
                            for _, Pos in next, Coords do
                                if Pos.X < MinX then MinX = Pos.X end
                                if Pos.X > MaxX then MaxX = Pos.X end
                                if Pos.Y < MinY then MinY = Pos.Y end
                                if Pos.Y > MaxY then MaxY = Pos.Y end
                            end

                            local BoxColor = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                            if ESPData.Settings.BoxMode == "Box" then
                                BoxOutline.PointA = Vector2.new(MaxX + 5, MinY - 10)
                                BoxOutline.PointB = Vector2.new(MinX - 5, MinY - 10)
                                BoxOutline.PointC = Vector2.new(MinX - 5, MaxY + 10)
                                BoxOutline.PointD = Vector2.new(MaxX + 5, MaxY + 10)
                                BoxOutline.Visible = ESPData.Settings.Boxes
                                BoxOutline.Color = BoxColor

                                BoxFill.PointA = Vector2.new(MaxX + 5 - 1, MinY - 10 + 1)
                                BoxFill.PointB = Vector2.new(MinX - 5 + 1, MinY - 10 + 1)
                                BoxFill.PointC = Vector2.new(MinX - 5 + 1, MaxY + 10 - 1)
                                BoxFill.PointD = Vector2.new(MaxX + 5 - 1, MaxY + 10 - 1)
                                BoxFill.Visible = ESPData.Settings.FillBoxes
                                BoxFill.Color = ESPData.Settings.FillColor

                                for _, L in next, SkeletonLines do L.Visible = false end
                            elseif ESPData.Settings.BoxMode == "Cornered" then
                                DrawCorneredBox(Vector2.new(MinX - 5, MaxY + 10), Vector2.new(MaxX + 5, MaxY + 10), Vector2.new(MinX - 5, MinY - 10), Vector2.new(MaxX + 5, MinY - 10), BoxColor)
                                BoxOutline.Visible = false
                                BoxFill.Visible = false
                            end

                            if ESPData.Settings.Health then
                                HealthBarOutline.From = Vector2.new(MinX - 9, MinY - 10)
                                HealthBarOutline.To = Vector2.new(MinX - 9, MaxY + 10)
                                HealthBarOutline.Visible = true
                                local HealthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
                                HealthBar.From = Vector2.new(MinX - 9, MaxY + 10)
                                HealthBar.To = Vector2.new(MinX - 9, MaxY + 10 - (MaxY + 10 - (MinY - 10)) * HealthPercent)
                                HealthBar.Color = Color3.fromRGB(255 - (255 * HealthPercent), 255 * HealthPercent, 0)
                                HealthBar.Visible = true
                            else
                                HealthBar.Visible = false
                                HealthBarOutline.Visible = false
                            end

                            if ESPData.Settings.Name then
                                local namePos = Vector2.new((MinX + MaxX) / 2, MinY - 30)
                                NameTag.Position = namePos
                                NameTag.Text = Target.Name
                                NameTag.Visible = true
                                NameTag.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                            else
                                NameTag.Visible = false
                            end
                        else
                            BoxOutline.Visible = false
                            BoxFill.Visible = false
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                            NameTag.Visible = false
                            for _, L in next, SkeletonLines do L.Visible = false end
                        end
                    elseif ESPData.Settings.ESPMode == "Classic" then
                        local hrpPos = Root.Position - Vector3.new(0, 0.2, 0)
                        local boxSize = Vector3.new(4, 7.5, 0)

                        local topRight2D, trVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (CurrentCamera.CFrame.RightVector * (boxSize.X / 2)) + (-CurrentCamera.CFrame.UpVector * (boxSize.Y / 2)))
                        local topLeft2D, tlVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (CurrentCamera.CFrame.RightVector * -(boxSize.X / 2)) + (-CurrentCamera.CFrame.UpVector * (boxSize.Y / 2)))
                        local bottomRight2D, brVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (CurrentCamera.CFrame.RightVector * (boxSize.X / 2)) + (-CurrentCamera.CFrame.UpVector * -(boxSize.Y / 2)))
                        local bottomLeft2D, blVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (CurrentCamera.CFrame.RightVector * -(boxSize.X / 2)) + (-CurrentCamera.CFrame.UpVector * -(boxSize.Y / 2)))

                        local isVisible = trVisible or tlVisible or brVisible or blVisible
                        if isVisible then
                            local tl2D = Vector2.new(topLeft2D.X, topLeft2D.Y)
                            local tr2D = Vector2.new(topRight2D.X, topRight2D.Y)
                            local bl2D = Vector2.new(bottomLeft2D.X, bottomLeft2D.Y)
                            local br2D = Vector2.new(bottomRight2D.X, bottomRight2D.Y)
                            local boxColor = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                            if ESPData.Settings.Boxes then
                                if ESPData.Settings.BoxMode == "Box" then
                                    BoxOutline.PointA = tr2D
                                    BoxOutline.PointB = tl2D
                                    BoxOutline.PointC = bl2D
                                    BoxOutline.PointD = br2D
                                    BoxOutline.Visible = ESPData.Settings.Boxes
                                    BoxOutline.Color = boxColor

                                    BoxFill.PointA = Vector2.new(tr2D.X - 1, tr2D.Y + 1)
                                    BoxFill.PointB = Vector2.new(tl2D.X + 1, tl2D.Y + 1)
                                    BoxFill.PointC = Vector2.new(bl2D.X + 1, bl2D.Y - 1)
                                    BoxFill.PointD = Vector2.new(br2D.X - 1, br2D.Y - 1)
                                    BoxFill.Visible = ESPData.Settings.FillBoxes
                                    BoxFill.Color = ESPData.Settings.FillColor

                                    for _, L in next, SkeletonLines do L.Visible = false end
                                elseif ESPData.Settings.BoxMode == "Cornered" then
                                    DrawCorneredBox(tl2D, tr2D, bl2D, br2D, boxColor)
                                    BoxOutline.Visible = false
                                    BoxFill.Visible = false
                                end
                            else
                                BoxOutline.Visible = false
                                for _, L in next, SkeletonLines do L.Visible = false end
                            end

                            if ESPData.Settings.Health then
                                HealthBarOutline.From = Vector2.new(topLeft2D.X - 4, topLeft2D.Y)
                                HealthBarOutline.To = Vector2.new(topLeft2D.X - 4, bottomLeft2D.Y)
                                HealthBarOutline.Visible = true
                                
                                local HealthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
                                HealthBar.From = Vector2.new(topLeft2D.X - 4, topLeft2D.Y)
                                HealthBar.To = Vector2.new(topLeft2D.X - 4, topLeft2D.Y + (bottomLeft2D.Y - topLeft2D.Y) * HealthPercent)
                                HealthBar.Color = Color3.fromRGB(255 - (255 * HealthPercent), 255 * HealthPercent, 0)
                                HealthBar.Visible = true
                            else
                                HealthBar.Visible = false
                                HealthBarOutline.Visible = false
                            end
                            if ESPData.Settings.Name then
                                local namePos = Vector2.new((topLeft2D.X + topRight2D.X) / 2, math.min(topLeft2D.Y, bottomLeft2D.Y, topRight2D.Y, bottomRight2D.Y) - 30)
                                NameTag.Position = namePos
                                NameTag.Text = Target.Name
                                NameTag.Visible = true
                                NameTag.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                            else
                                NameTag.Visible = false
                            end
                        else
                            BoxOutline.Visible = false
                            BoxFill.Visible = false
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                            NameTag.Visible = false
                            for _, L in next, SkeletonLines do L.Visible = false end
                        end
                    elseif ESPData.Settings.ESPMode == "Locked" then
                        local hrpPos = Root.Position - Vector3.new(0, 0.2, 0)
                        local boxSize = Vector3.new(4.5, 6.5, 0)

                        local topRight2D, trVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (Root.CFrame.RightVector * boxSize.X / 2) + (Root.CFrame.UpVector * boxSize.Y / 2))
                        local topLeft2D, tlVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (Root.CFrame.RightVector * -(boxSize.X / 2)) + (Root.CFrame.UpVector * boxSize.Y / 2))
                        local bottomRight2D, brVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (Root.CFrame.RightVector * boxSize.X / 2) + (Root.CFrame.UpVector * -(boxSize.Y / 2)))
                        local bottomLeft2D, blVisible = CurrentCamera:WorldToViewportPoint(hrpPos + (Root.CFrame.RightVector * -(boxSize.X / 2)) + (Root.CFrame.UpVector * -(boxSize.Y / 2)))

                        if trVisible or tlVisible or brVisible or blVisible then
                            local tl2D = Vector2.new(topLeft2D.X, topLeft2D.Y)
                            local tr2D = Vector2.new(topRight2D.X, topRight2D.Y)
                            local bl2D = Vector2.new(bottomLeft2D.X, bottomLeft2D.Y)
                            local br2D = Vector2.new(bottomRight2D.X, bottomRight2D.Y)
                            local BoxColor = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color

                            if ESPData.Settings.Boxes then
                                if ESPData.Settings.BoxMode == "Box" then
                                    BoxOutline.PointA = tr2D
                                    BoxOutline.PointB = tl2D
                                    BoxOutline.PointC = bl2D
                                    BoxOutline.PointD = br2D
                                    BoxOutline.Visible = ESPData.Settings.Boxes
                                    BoxOutline.Color = BoxColor

                                    BoxFill.PointA = Vector2.new(tr2D.X - 1, tr2D.Y + 1)
                                    BoxFill.PointB = Vector2.new(tl2D.X + 1, tl2D.Y + 1)
                                    BoxFill.PointC = Vector2.new(bl2D.X + 1, bl2D.Y - 1)
                                    BoxFill.PointD = Vector2.new(br2D.X - 1, br2D.Y - 1)
                                    BoxFill.Visible = ESPData.Settings.FillBoxes
                                    BoxFill.Color = ESPData.Settings.FillColor

                                    for _, L in next, SkeletonLines do L.Visible = false end
                                elseif ESPData.Settings.BoxMode == "Cornered" then
                                    local Flip = (tl2D.X > tr2D.X) or (bl2D.X > br2D.X)
                                    if Flip then
                                        DrawCorneredBox(br2D, bl2D, tr2D, tl2D, BoxColor)
                                    else
                                        DrawCorneredBox(bl2D, br2D, tl2D, tr2D, BoxColor)
                                    end
                                    BoxOutline.Visible = false
                                    BoxFill.Visible = false
                                end
                            else
                                BoxOutline.Visible = false
                                for _, L in next, SkeletonLines do L.Visible = false end
                            end

                            if ESPData.Settings.Name then
                                local namePos = Vector2.new((topLeft2D.X + topRight2D.X) / 2, math.min(topLeft2D.Y, bottomLeft2D.Y, topRight2D.Y, bottomRight2D.Y) - 30)
                                NameTag.Position = namePos
                                NameTag.Text = Target.Name
                                NameTag.Visible = true
                                NameTag.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                            else
                                NameTag.Visible = false
                            end
                        else
                            BoxOutline.Visible = false
                            BoxFill.Visible = false
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                            NameTag.Visible = false
                            for _, L in next, SkeletonLines do L.Visible = false end
                        end
                    elseif ESPData.Settings.ESPMode == "Skeleton" then
                        local screenCoords = {}
                        local isVisible = false
                        local isR6 = Humanoid.RigType == Enum.HumanoidRigType.R6
                        for i, pair in next, DrawPairs do
                            local Line = SkeletonLines[i]
                            local Part1, Part2
                            if isR6 then
                                Part1 = Target.Character:FindFirstChild(pair[3])
                                Part2 = Target.Character:FindFirstChild(pair[4])
                            else
                                Part1 = Target.Character:FindFirstChild(pair[1])
                                Part2 = Target.Character:FindFirstChild(pair[2])
                            end
                            if Part1 and Part2 then
                                local pos1 = Part1.Position
                                local pos2 = Part2.Position

                                if isR6 and pair[5] then
                                    pos1 = (Part1.CFrame * pair[5]).p
                                elseif not isR6 and pair[1] == "Head" then
                                    pos1 = (Part1.CFrame * CFrame.new(0, -0.2, 0)).p
                                end

                                if isR6 and pair[6] then
                                    pos2 = (Part2.CFrame * pair[6]).p
                                elseif not isR6 and pair[2] == "UpperTorso" and pair[1] ~= "Head" then
                                    pos2 = (Part2.CFrame * CFrame.new(0, 0.5, 0)).p
                                elseif not isR6 and pair[2] == "LowerTorso" then
                                    pos2 = Part2.Position
                                end

                                local P1, Vis1 = CurrentCamera:WorldToViewportPoint(pos1)
                                local P2, Vis2 = CurrentCamera:WorldToViewportPoint(pos2)
                                screenCoords[pair[1]] = screenCoords[pair[1]] or { Pos = P1, Visible = Vis1 }
                                screenCoords[pair[2]] = screenCoords[pair[2]] or { Pos = P2, Visible = Vis2 }

                                if Vis1 and Vis2 then
                                    Line.From = Vector2.new(P1.X, P1.Y)
                                    Line.To = Vector2.new(P2.X, P2.Y)
                                    Line.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                                    Line.Visible = true
                                    isVisible = true
                                else
                                    Line.Visible = false
                                end
                            else
                                Line.Visible = false
                            end
                        end

                        HealthBar.Visible = false
                        HealthBarOutline.Visible = false

                        if ESPData.Settings.Name and screenCoords.Head and screenCoords.Head.Visible then
                            local namePos = Vector2.new(screenCoords.Head.Pos.X, screenCoords.Head.Pos.Y - 30)
                            NameTag.Position = namePos
                            NameTag.Text = Target.Name
                            NameTag.Visible = true
                            NameTag.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                        else
                            NameTag.Visible = false
                        end

                        BoxOutline.Visible = false
                        BoxFill.Visible = false
                        if not isVisible then
                            NameTag.Visible = false
                            for _, L in next, SkeletonLines do L.Visible = false end
                        end
                    elseif ESPData.Settings.ESPMode == "3D Box" then
                        local isVisible = false
                        local boxSize = Vector3.new(4, 6, 4)
                        local hrpPos = Root.Position - Vector3.new(0, 0.25, 0)

                        local corners = {
                            hrpPos + Vector3.new(boxSize.X / 2, boxSize.Y / 2, boxSize.X / 2),
                            hrpPos + Vector3.new(-(boxSize.X / 2), boxSize.Y / 2, boxSize.X / 2),
                            hrpPos + Vector3.new(-(boxSize.X / 2), boxSize.Y / 2, -(boxSize.X / 2)),
                            hrpPos + Vector3.new(boxSize.X / 2, boxSize.Y / 2, -(boxSize.X / 2)),
                            hrpPos + Vector3.new(boxSize.X / 2, -(boxSize.Y / 2), boxSize.X / 2),
                            hrpPos + Vector3.new(-(boxSize.X / 2), -(boxSize.Y / 2), boxSize.X / 2),
                            hrpPos + Vector3.new(-(boxSize.X / 2), -(boxSize.Y / 2), -(boxSize.X / 2)),
                            hrpPos + Vector3.new(boxSize.X / 2, -(boxSize.Y / 2), -(boxSize.X / 2))
                        }

                        local screenPos = {}
                        for i, corner in next, corners do
                            local pos, vis = CurrentCamera:WorldToViewportPoint(corner)
                            screenPos[i] = { Pos = pos, Visible = vis }
                            if vis then isVisible = true end
                        end

                        local edges = {
                            {1, 2}, {2, 3}, {3, 4}, {4, 1},
                            {5, 6}, {6, 7}, {7, 8}, {8, 5},
                            {1, 5}, {2, 6}, {3, 7}, {4, 8}
                        }

                        for i, edge in next, edges do
                            local Line = SkeletonLines[i]
                            local p1, p2 = screenPos[edge[1]], screenPos[edge[2]]
                            if p1.Visible and p2.Visible then
                                Line.From = Vector2.new(p1.Pos.X, p1.Pos.Y)
                                Line.To = Vector2.new(p2.Pos.X, p2.Pos.Y)
                                Line.Color = (ESPData.Settings.TeamColor and Target.Team) and Target.TeamColor.Color or ESPData.Settings.Color
                                Line.Visible = true
                            else
                                Line.Visible = false
                            end
                        end

                        for i = #edges + 1, #SkeletonLines do
                            SkeletonLines[i].Visible = false
                        end

                        NameTag.Visible = false
                        HealthBar.Visible = false
                        HealthBarOutline.Visible = false
                        BoxOutline.Visible = false
                        BoxFill.Visible = false

                        if not isVisible or not ESPData.Settings.Boxes then
                            for _, L in next, SkeletonLines do L.Visible = false end
                        end
                    end
                end
            else
                BoxOutline.Visible = false
                BoxFill.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
                NameTag.Visible = false
                for _, L in next, SkeletonLines do L.Visible = false end
            end
        end

        ESP:Connection(RunService.PreSimulation:Connect(Update))
        ESPData.Data.Instances[Target] = {
            BoxOutline = BoxOutline,
            BoxFill = BoxFill,
            HealthBarOutline = HealthBarOutline,
            HealthBar = HealthBar,
            NameTag = NameTag,
            SkeletonLines = SkeletonLines,
        }

        return ESPData.Data
    end

    local function DestroyESP()
        for player, espData in next, ESPData.Data.Instances do
            if espData.BoxOutline then espData.BoxOutline:Destroy() end
            if espData.BoxFill then espData.BoxFill:Destroy() end
            if espData.HealthBarOutline then espData.HealthBarOutline:Destroy() end
            if espData.HealthBar then espData.HealthBar:Destroy() end
            if espData.NameTag then espData.NameTag:Destroy() end

            for _, line in next, espData.SkeletonLines do
                if line then line:Destroy() end
            end

            ESPData.Data.Instances[player] = nil
        end
        
        table.clear(ESPData.Data.Instances)
    end
 
    ESP = Tabs.Render:CreateModule({
        Name = "ESP",
        Flag = "UniversalESP",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, Player in next, Players:GetPlayers() do
                    if Player ~= LocalPlayer then
                        CreateESP(Player)
                    end
                end
                
                self:Connection(Players.PlayerAdded:Connect(function(NewPlayer)
                    if NewPlayer ~= LocalPlayer then
                        CreateESP(NewPlayer)
                    end
                end))
            else
                DestroyESP()
            end
        end
    })

    local Fill, FillColor, Healthbar, Name, Box
    ESP:Dropdown({
        Name = "Mode",
        Flag = "ESPMode",
        Default = "Dynamic",
        Options = {"Dynamic", "Classic", "Locked", "Skeleton", "3D Box"},
        CallingFunction = function(self, value: string)
            ESPData.Settings.ESPMode = value

            if value == "Dynamic" or value == "Classic" or value == "Locked" then
                Fill:SetVisiblity(true)
                FillColor:SetVisiblity(Fill.Enabled)
                Box:SetVisiblity(true)
            else
                Fill:SetVisiblity(false)
                FillColor:SetVisiblity(not Fill.Enabled)
                Box:SetVisiblity(false)
            end

            Healthbar:SetVisiblity(value == "Dynamic" or value == "Classic")
            Name:SetVisiblity(value ~= "3D Box")
        end
    })

    ESP:Dropdown({
        Name = "Box Type",
        Flag = "ESPBoxType",
        Default = "Box",
        Options = {"Box", "Cornered"},
        CallingFunction = function(self, value: string)
            ESPData.Settings.BoxMode = value
        end
    })

    ESP:ColorSlider({
        Name = "Color",
        Flag = "ESPColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, color: Color3)
            ESPData.Settings.Color = color
        end
    })

    FillColor = ESP:ColorSlider({
        Name = "Fill Color",
        Flag = "ESPFillColor",
        Default = Color3.fromRGB(0, 0, 0),
        CallingFunction = function(self, color: Color3)
            ESPData.Settings.FillColor = color
        end
    })

    ESP:MiniToggle({
        Name = "Team Color",
        Flag = "ESPTeamColor",
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.TeamColor = value
        end
    })

    ESP:MiniToggle({
        Name = "Team Check",
        Flag = "ESPTeamCheck",
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.TeamCheck = value
        end
    })

    Box = ESP:MiniToggle({
        Name = "Box",
        Flag = "ESPBox",
        Default = true,
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.Boxes = value
        end
    })

    Fill = ESP:MiniToggle({
        Name = "Fill",
        Flag = "ESPFill",
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.FillBoxes = value
            FillColor:SetVisiblity(value)
        end
    })

    Healthbar = ESP:MiniToggle({
        Name = "Healthbar",
        Flag = "ESPHealthbar",
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.Health = value
        end
    })

    Name = ESP:MiniToggle({
        Name = "Name",
        Flag = "ESPName",
        CallingFunction = function(self, value: boolean)
            ESPData.Settings.Name = value
        end
    })
end)();

(function()
    local SpinBotData = {
        Settings = {
            Mode = "CFrame",
            Speed = 30
        },
        Data = {Body = nil}
    }
    local SpinBot = Tabs.Movement:CreateModule({
        Name = "Spin Bot",
        Flag = "UniversalSpinBot",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Bloomware:IsAlive(LocalPlayer) then
                    local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if SpinBotData.Settings.Mode == "CFrame" then
                        self:Connection(RunService.RenderStepped:Connect(function()
                            PrimaryPart.CFrame *= CFrame.Angles(0, math.rad(SpinBotData.Settings.Speed / 5), 0)
                        end))
                    elseif SpinBotData.Settings.Mode == "Angular" then
                        SpinBotData.Data.Body = Instance.new("BodyAngularVelocity", PrimaryPart)
                        SpinBotData.Data.Body.AngularVelocity = Vector3.new(0, SpinBotData.Settings.Speed, 0)
                        SpinBotData.Data.Body.MaxTorque = Vector3.new(0, math.huge, 0)
                        SpinBotData.Data.Body.P = 10000
                        self:Connection(RunService.RenderStepped:Connect(function()
                            SpinBotData.Data.Body.AngularVelocity = Vector3.new(0, SpinBotData.Settings.Speed, 0)
                        end))
                    end
                end
            else
                if SpinBotData.Data.Body then
                    SpinBotData.Data.Body:Destroy()
                    SpinBotData.Data.Body = nil
                end
            end
        end
    })

    SpinBot:Dropdown({
        Name = "Mode",
        Flag = "SpinBotMode",
        Default = "CFrame",
        Options = {"CFrame", "Angular"},
        CallingFunction = function(self, Value)
            SpinBotData.Settings.Mode = Value

            local WasEnabled: boolean = SpinBot.Enabled
            SpinBot:SetValue(false, false, false)
            if WasEnabled then
                task.delay(0.1, SpinBot.SetValue, SpinBot, true, false, false)
            end
        end
    })

    SpinBot:Slider({
        Name = "Speed",
        Flag = "SpinBotSpeed",
        Default = 30,
        Min = 1,
        Max = 100,
        CallingFunction = function(self, value: number)
            SpinBotData.Settings.Speed = value
        end
    })
end)();

(function()
    local MouseTPData = {
        Settings = {
            Mode = "Instant",
            LerpSpeed = 10,
            TweenSpeed = 8
        }
    }

    local Modes = {
        CFrame = function(target: CFrame)
            (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")).CFrame = target
        end,
        Lerp = function(target: CFrame)
            local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local Start: CFrame = PrimaryPart.CFrame
            local Alpha: number = 0
            while Alpha < 1 do
                Alpha += RunService.PreSimulation:Wait() * MouseTPData.Settings.LerpSpeed
                PrimaryPart.CFrame = Start:Lerp(target, math.clamp(Alpha, 0, 1))
            end
        end,
        Tween = function(target: CFrame)
            local Tween = TweenService:Create(
                (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")),
                TweenInfo.new(1 - MouseTPData.Settings.TweenSpeed / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {CFrame = target}
            )
            Tween:Play()
            Tween.Completed:Wait()
        end
    }

    local MouseTP = Tabs.Movement:CreateModule({
        Name = "Mouse TP",
        Flag = "UniversalMouseTP",
        Button = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local Mouse: Mouse? = LocalPlayer:GetMouse()
                if Mouse and Bloomware:IsAlive(LocalPlayer) then
                    Modes[MouseTPData.Settings.Mode](Mouse.Hit)
                end
            end
        end
    })

    local LerpSpeed, TweenSpeed
    MouseTP:Dropdown({
        Name = "Mode",
        Flag = "MouseTPMode",
        Default = "CFrame",
        Options = {"CFrame", "Lerp", "Tween"},
        CallingFunction = function(self, value: string)
            MouseTPData.Settings.Mode = value
            LerpSpeed:SetVisiblity(value == "Lerp")
            TweenSpeed:SetVisiblity(value == "Tween")
        end
    })

    LerpSpeed = MouseTP:Slider({
        Name = "Speed",
        Flag = "MouseTPLerpSpeed",
        Default = 10,
        Min = 1,
        Max = 20,
        Increment = 1,
        CallingFunction = function(self, value: number)
            MouseTPData.Settings.LerpSpeed = value
        end
    })

    TweenSpeed = MouseTP:Slider({
        Name = "Speed",
        Flag = "MouseTPTweenSpeed",
        Default = 8,
        Min = 1,
        Max = 10,
        Increment = 1,
        CallingFunction = function(self, value: number)
            MouseTPData.Settings.TweenSpeed = value
        end
    })
end)();

(function()
    local Speed, Distance = 60, 5
    local Param = RaycastParams.new()
    Param.FilterType = Enum.RaycastFilterType.Exclude
    Param.RespectCanCollide = true
    Param.IgnoreWater = true

    local WallClimb = Tabs.Movement:CreateModule({
        Name = "Wall Climb",
        Flag = "UniversalWallClimb",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if Bloomware:IsAlive(LocalPlayer) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        local FilterDescendants = {}
                        for _, Player in next, Players:GetPlayers() do
                            if Player.Character then
                                table.insert(FilterDescendants, Player.Character)
                            end
                        end

                        Param.FilterDescendantsInstances = FilterDescendants
                        local Ray: RaycastResult? = workspace:Raycast(Root.Position, Humanoid.MoveDirection * Distance, Param)
                        if Ray and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                            Root.AssemblyLinearVelocity = Vector3.new(CurrentVelocity.X, Speed, CurrentVelocity.Z)
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })
    
    WallClimb:Slider({
        Name = "Speed",
        Flag = "UniversalWallClimbSpeed",
        Min = 1,
        Max = 120,
        Default = 60,
        CallingFunction = function(self, value: number)
            Speed = value
        end
    })

    WallClimb:Slider({
        Name = "Distance",
        Flag = "UniversalWallClimbDistance",
        Min = 1,
        Max = 10,
        Default = 5,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })
end)();

(function()
    local NoClipData = {
        Settings = {
            Mode = "Teleport",
            Distance = 2,
            Studs = 5,
            Speed = 0.1
        },
        Data = {
            Tweening = false,
            Restore = {}
        }
    }

    local Param = RaycastParams.new()
    Param.FilterType = Enum.RaycastFilterType.Exclude

    local function Teleport(Character: Model, Direction: Vector3)
        local Torso: BasePart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
        if not Torso then
            Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
        end
        if not Torso then return end

        if NoClipData.Settings.Mode == "Teleport" then
            Torso.CFrame = Torso.CFrame + Direction * NoClipData.Settings.Studs
        elseif NoClipData.Settings.Mode == "Slide" and not NoClipData.Data.Tweening then
            NoClipData.Data.Tweening = true
            local Tween = TweenService:Create(Torso, TweenInfo.new(NoClipData.Settings.Speed, Enum.EasingStyle.Linear), {
                CFrame = Torso.CFrame + Direction * NoClipData.Settings.Studs
            })
            Tween:Play()
            Tween.Completed:Connect(function()
                NoClipData.Data.Tweening = false
            end)
        end
    end

    local NoClip = Tabs.Movement:CreateModule({
        Name = "No Clip",
        Flag = "UniversalNoClip",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(RunService.PreSimulation:Connect(function()
                    if not Bloomware:IsAlive(LocalPlayer) then return end

                    local Character = LocalPlayer.Character
                    local Humanoid: Humanoid = Character:FindFirstChildOfClass("Humanoid")

                    if NoClipData.Settings.Mode == "Collide" then
                        repeat
                            for _, v in Character:GetChildren() do
                                if (v:IsA("MeshPart") or v:IsA("Part")) and v.CanCollide then
                                    v.CanCollide = false
                                    if not table.find(NoClipData.Data.Restore, v) then
                                        table.insert(NoClipData.Data.Restore, v)
                                    end
                                end
                            end
                            task.wait(0.5)
                        until not self.Enabled or NoClipData.Settings.Mode ~= "Collide"
                    end

                    if NoClipData.Settings.Mode == "Teleport" or NoClipData.Settings.Mode == "Slide" then
                        local Filter: {Instance} = {CurrentCamera}
                        for _, Player in next, Players:GetPlayers() do
                            if Player.Character then
                                table.insert(Filter, Player.Character)
                            end
                        end
                        Param.FilterDescendantsInstances = Filter

                        local Ray: RaycastResult? = workspace:Raycast((Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")).Position, Humanoid.MoveDirection * NoClipData.Settings.Distance, Param)
                        if Ray then
                            Teleport(Character, Humanoid.MoveDirection)
                        end
                    end
                end))
            else
                for _, v in NoClipData.Data.Restore do
                    if v then v.CanCollide = true end
                end
                table.clear(NoClipData.Data.Restore)
            end
        end
    })

    local Studs, Slide
    NoClip:Dropdown({
        Name = "Mode",
        Flag = "NoClipMode",
        Default = "Teleport",
        Options = {"Teleport", "Slide", "Collide"},
        CallingFunction = function(self, value: string)
            NoClipData.Settings.Mode = value
            Studs:SetVisiblity(value == "Teleport")
            Slide:SetVisiblity(value == "Slide")
        end
    })

    NoClip:Slider({
        Name = "Distance",
        Flag = "UniversalNoClipDistance",
        Min = 1,
        Max = 5,
        Default = 2,
        CallingFunction = function(self, value: number)
            NoClipData.Settings.Distance = value
        end
    })

    Studs = NoClip:Slider({
        Name = "TP Studs",
        Flag = "UniversalNoClipStuds",
        Min = 1,
        Max = 10,
        Default = 5,
        CallingFunction = function(self, value: number)
            NoClipData.Settings.Studs = value
        end
    })

    Slide = NoClip:Slider({
        Name = "Slide Speed",
        Flag = "UniversalNoClipSlideSpeed",
        Min = 0.01,
        Max = 0.5,
        Default = 0.1,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            NoClipData.Settings.Speed = value
        end
    })
end)();

(function()
    local OldReqs, IP = {}, "127.0.0.1"
    local AntiIPLogger = Tabs.Utility:CreateModule({
        Name = "Anti IP Logger",
        Flag = "UniversalAntiIPLogger",
        Default = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if hookfunction then
                    xpcall(function()
                        if MainRequest then
                            local OldMain; OldMain = hookfunction(http.request, Bloomware.newcclosure(function(Data, ...)
                                if typeof(Data) == "table" then
                                    local Url: string = tostring(Data.Url):lower()
                                    if Url:find("ipify") or (Url:find("api") and Url:find("ip")) then
                                        Bloomware:CreateNotification({
                                            Title = "Anti IP Logger",
                                            Description = "Bloomware has blocked a script attempting to run an IP logger to grab your IP address.",
                                            Duration = 20
                                        })

                                        return {
                                            StatusMessage = "OK",
                                            Success = 200,
                                            StatusCode = 200,
                                            Headers = {},
                                            Body = IP
                                        }
                                    end

                                    local Ret = OldMain(Data, ...)
                                    if Ret and typeof(Ret) == "table" then
                                        local Body: string | {} = Ret.Body
                                        if typeof(Body) == "string" then
                                            local Suc, Json = pcall(function()
                                                return HttpService:JSONDecode(Body)
                                            end)

                                            if Suc then
                                                Body = Json
                                            end
                                        end

                                        if typeof(Body) == "table" then
                                            local Results = Bloomware:SearchTable(Body, "ip")
                                            if #Results == 0 then
                                                Results = Bloomware:SearchTable(Body, "origin")
                                            end

                                            if #Results > 0 then
                                                local ShouldTrigger: boolean = false
                                                for i,v in Results do
                                                    if tostring(v):lower() == "ip" or tostring(v):lower():find("ip add") or tostring(v) == "origin" then
                                                        ShouldTrigger = true
                                                    end
                                                end

                                                if ShouldTrigger then
                                                    Bloomware:CreateNotification({
                                                        Title = "Anti IP Logger",
                                                        Description = "Bloomware has blocked a script attempting to run an IP logger to grab your IP address.",
                                                        Duration = 20
                                                    })

                                                    return {
                                                        StatusMessage = "OK",
                                                        Success = 200,
                                                        StatusCode = 200,
                                                        Headers = {},
                                                        Body = '{"ip": "'..IP..'"}'
                                                    }
                                                end
                                            end
                                        else
                                            if tostring(Body):lower():find("ip address") or tostring(Body):lower() == "ip" then
                                                Bloomware:CreateNotification({
                                                    Title = "Anti IP Logger",
                                                    Description = "Bloomware has blocked a script attempting to run an IP logger to grab your IP address.",
                                                    Duration = 20
                                                })

                                                return {
                                                    StatusMessage = "OK",
                                                    Success = 200,
                                                    StatusCode = 200,
                                                    Headers = {},
                                                    Body = IP
                                                }
                                            end
                                        end
                                    end
                                end
                                return OldMain(Data, ...)
                            end))

                            OldReqs[MainRequest] = OldMain
                            if request and MainRequest ~= request then
                                OldReqs[request] = hookfunction(request, MainRequest)
                            end
                        end
                    end, function(err: string)
                        task.delay(0.1, self.SetValue, self, false)
                        Bloomware:CreateNotification({
                            Title = "Anti IP Logger",
                            Description = "An error occurred "..err..".",
                            Duration = 10
                        })  
                    end)
                else
                    task.delay(0.1, self.SetValue, self, false)
                    Bloomware:CreateNotification({
                        Title = "Anti IP Logger",
                        Description = "Your executor does not support this module.",
                        Duration = 10
                    })  
                end 
            else
                for i,v in OldReqs do
                    hookfunction(i, v)
                end
            end
        end
    })

    AntiIPLogger:TextBox({
        Name = "IP",
        Flag = "AntiIPLoggerIPValue",
        Default = "127.0.0.1",
        CallingFunction = function(self, value: string)
            IP = value
        end
    })
end)();

(function()
    local Power, Mode = 100, "Button"
    local HighJump = Tabs.Movement:CreateModule({
        Name = "High Jump",
        Flag = "UniversalHighJump",
        Button = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Mode == "Button" then
                    if Bloomware:IsAlive(LocalPlayer) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                        Root.AssemblyLinearVelocity = Vector3.new(CurrentVelocity.X, Power, CurrentVelocity.Z)
                    end
                else
                    self:Connection(UserInputService.JumpRequest:Connect(function()
                        if Bloomware:IsAlive(LocalPlayer) then
                            local Root: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                            Root.AssemblyLinearVelocity = Vector3.new(CurrentVelocity.X, Power, CurrentVelocity.Z)
                        end
                    end))
                end
            end
        end
    })
    
    HighJump:Slider({
        Name = "Power",
        Flag = "UniversalHighJumpPower",
        Min = 10,
        Max = 400,
        Default = 200,
        CallingFunction = function(self, value: number)
            Power = value
        end
    })

    HighJump:Dropdown({
        Name = "Mode",
        Flag = "HighJumpMode",
        Default = "Button",
        Options = {"Button", "Jump"},
        CallingFunction = function(self, value: string)
            Mode = value
            HighJump.Data.Button = (value == "Button")

            if HighJump.Enabled and value == "Button" then
                HighJump:SetValue(false)
            end
        end
    })
end)();

(function()
    local IdentityChangerData = {
        Settings = {
            Username = false,
            DisplayName = false,
            UsernameText = "Bloomware.gg",
            DisplayNameText = "Bloomware.gg"
        },
        Data = {
            Name = LocalPlayer.Name,
            DisplayName = LocalPlayer.DisplayName,
            HumanoidDisplay = nil
        },
        Connections = {}
    }

    local IdentityChanger = Tabs.Utility:CreateModule({
        Name = "Identity Changer",
        Flag = "UniverslIdentityChanger",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                LocalPlayer.Name = IdentityChangerData.Settings.Username and IdentityChangerData.Settings.UsernameText or LocalPlayer.Name
                LocalPlayer.DisplayName = IdentityChangerData.Settings.DisplayName and IdentityChangerData.Settings.DisplayNameText or LocalPlayer.DisplayName
                if Bloomware:IsAlive(LocalPlayer) then
                    local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                    IdentityChangerData.Data.HumanoidDisplay = Humanoid.DisplayName
                    Humanoid.DisplayName = IdentityChangerData.Settings.DisplayName and IdentityChangerData.Settings.DisplayNameText or Humanoid.DisplayName
                end

                self:Connection(LocalPlayer.CharacterAdded:Connect(function(Character: Model)  
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    repeat task.wait() until Humanoid

                    IdentityChangerData.Data.HumanoidDisplay = Humanoid.DisplayName
                    Humanoid.DisplayName = IdentityChangerData.Settings.DisplayName and IdentityChangerData.Settings.DisplayNameText or LocalPlayer.DisplayName
                end), {IdentityChangerData.Connections})
            else
                LocalPlayer.Name = IdentityChangerData.Data.Name
                LocalPlayer.DisplayName = IdentityChangerData.Data.DisplayName
                if IdentityChangerData.Data.HumanoidDisplay and Bloomware:IsAlive(LocalPlayer) then
                    LocalPlayer.Character.Humanoid.DisplayName = IdentityChangerData.Data.HumanoidDisplay
                end
            end
        end
    })

    local UsernameTextBox = IdentityChanger:TextBox({
        Name = "Username",
        Flag = "IdentityChangerUsernameValue",
        Default = "Bloomware.gg",
        CallingFunction = function(self, value: string)
            IdentityChangerData.Settings.UsernameText = value

            if IdentityChangerData.Settings.Username then
                LocalPlayer.Name = value
            end
        end
    })

    local DisplayNameTextBox = IdentityChanger:TextBox({
        Name = "Display Name",
        Flag = "IdentityChangerDisplayNameValue",
        Default = "Bloomware.gg",
        CallingFunction = function(self, value: string)
            IdentityChangerData.Settings.DisplayNameText = value

            if IdentityChangerData.Settings.DisplayName then
                LocalPlayer.DisplayName = value
                if Bloomware:IsAlive(LocalPlayer) then
                    local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                    Humanoid.DisplayName = value
                end
            end
        end
    })

    IdentityChanger:MiniToggle({
        Name = "Username",
        Flag = "IdentityChangerUsernameEnabled",
        Default = true,
        CallingFunction = function(self, value: boolean)
            IdentityChangerData.Settings.Username = value
            UsernameTextBox:SetVisiblity(value)

            if not value then
                LocalPlayer.Name = IdentityChangerData.Data.Name
            else
                LocalPlayer.Name = IdentityChangerData.Settings.UsernameText
            end
        end
    })

    IdentityChanger:MiniToggle({
        Name = "Display Name",
        Flag = "IdentityChangerDisplayNameEnabled",
        Default = true,
        CallingFunction = function(self, value: boolean)
            IdentityChangerData.Settings.DisplayName = value
            DisplayNameTextBox:SetVisiblity(value)
            
            if not value then
                for i,v in IdentityChangerData.Connections do
                    v:Disconnect()
                end
                table.clear(IdentityChangerData.Connections)

                LocalPlayer.DisplayName = IdentityChangerData.Data.DisplayName
                if Bloomware:IsAlive(LocalPlayer) then
                    local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                    Humanoid.DisplayName = IdentityChanger.Data.HumanoidDisplay
                end
            else
                if Bloomware:IsAlive(LocalPlayer) then
                    local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                    IdentityChangerData.Data.HumanoidDisplay = Humanoid.DisplayName
                    Humanoid.DisplayName = IdentityChangerData.Settings.DisplayName and IdentityChangerData.Settings.DisplayNameText or Humanoid.DisplayName
                end

                IdentityChanger:Connection(LocalPlayer.CharacterAdded:Connect(function(Character: Model)  
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    repeat task.wait() until Humanoid

                    IdentityChangerData.Data.HumanoidDisplay = Humanoid.DisplayName
                    Humanoid.DisplayName = IdentityChangerData.Settings.DisplayName and IdentityChangerData.Settings.DisplayNameText or LocalPlayer.DisplayName
                end), {IdentityChangerData.Connections})
            end
        end
    })
end)();

(function()
    local Trails
    local TrailsData = {
        Settings = {
            Shape = "Trail",
            Lifetime = 3,
            Width = 3,
            Size = 2,
            SpawnSpeed = 0.15,
            Color = Color3.fromRGB(255, 0, 0)
        },
        Data = {
            Parts = {},
            Trail = nil,
            Atts = {}
        },
        Connections = {}
    }

    local function MakePart(CF: CFrame)
        local Part, Offset: CFrame = nil, CFrame.new()
        if TrailsData.Settings.Shape == "Plate" then
            Part = Instance.new("Part")
            Part.Size = Vector3.new(TrailsData.Settings.Size, 0.2, TrailsData.Settings.Size)
        elseif TrailsData.Settings.Shape == "Cube" then
            Part = Instance.new("Part")
            Part.Size = Vector3.new(TrailsData.Settings.Size, TrailsData.Settings.Size, TrailsData.Settings.Size)
        elseif TrailsData.Settings.Shape == "Sphere" then
            Part = Instance.new("Part")
            Part.Shape = Enum.PartType.Ball
            Part.Size = Vector3.new(TrailsData.Settings.Size, TrailsData.Settings.Size, TrailsData.Settings.Size)
        elseif TrailsData.Settings.Shape == "Circle" then
            Part = Instance.new("Part")
            Part.Size = Vector3.new(TrailsData.Settings.Size * 2, 0.2, TrailsData.Settings.Size * 2)
            local Mesh = Instance.new("CylinderMesh")
            Mesh.Parent = Part
            Offset = CFrame.Angles(math.rad(90), 0, 0)
        elseif TrailsData.Settings.Shape == "Triangle" then
            Part = Instance.new("WedgePart")
            Part.Size = Vector3.new(TrailsData.Settings.Size, TrailsData.Settings.Size, TrailsData.Settings.Size)
        else
            Part = Instance.new("Part")
            Part.Size = Vector3.new(TrailsData.Settings.Size, 0.2, TrailsData.Settings.Size)
        end

        Part.Anchored = true
        Part.CanCollide = false
        Part.Color = TrailsData.Settings.Color
        Part.Material = Enum.Material.Neon
        Part.CFrame = CF * Offset
        Part.Parent = workspace
        table.insert(TrailsData.Data.Parts, Part)

        local Tween: Tween = TweenService:Create(Part, TweenInfo.new(TrailsData.Settings.Lifetime, Enum.EasingStyle.Linear), {
            Transparency = 1,
            Size = Vector3.new(0, 0, 0)
        })

        Tween:Play()
        Trails:Connection(Tween.Completed:Connect(function()
            if Part and Part.Parent then Part:Destroy() end
            local i: number? = table.find(TrailsData.Data.Parts, Part)
            if i then table.remove(TrailsData.Data.Parts, i) end
        end))
    end

    local function MakeTrail()
        if Bloomware:IsAlive(LocalPlayer) then
            local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local Att0: Attachment = Instance.new("Attachment", PrimaryPart)
            Att0.Position = Vector3.new(-(TrailsData.Settings.Width / 6), -2.55, 0)

            local Att1: Attachment = Instance.new("Attachment", PrimaryPart)
            Att1.Position = Vector3.new(TrailsData.Settings.Width / 6, -2.55, 0)

            local Trail: Trail = Instance.new("Trail", PrimaryPart)
            Trail.Attachment0 = Att0
            Trail.Attachment1 = Att1
            Trail.Lifetime = TrailsData.Settings.Lifetime
            Trail.Color = ColorSequence.new(TrailsData.Settings.Color)
            Trail.LightEmission = 10
            Trail.WidthScale = NumberSequence.new(TrailsData.Settings.Width)
            TrailsData.Data.Trail = Trail

            table.insert(TrailsData.Data.Atts, Att0)
            table.insert(TrailsData.Data.Atts, Att1)
        end
    end
    
    local function DestroyTrails()
        for i,v in next, TrailsData.Data.Parts do
            if v and v.Parent then 
                v:Destroy() 
            end
        end

        if TrailsData.Data.Trail then
            TrailsData.Data.Trail:Destroy()
            TrailsData.Data.Trail = nil
        end
        
        for _, att in next, TrailsData.Data.Atts do
            if att and att.Parent then 
                att:Destroy() 
            end
        end

        table.clear(TrailsData.Data.Parts)
        table.clear(TrailsData.Data.Atts)
    end

    local function MainTrail()
        if not Trails.Enabled then
            DestroyTrails()
            return
        end

        if Bloomware:IsAlive(LocalPlayer) and Trails.Enabled then
            local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
            if TrailsData.Settings.Shape == "Trail" then
                MakeTrail()
            else
                local Time = 0
                Trails:Connection(Humanoid.Died:Connect(function()
                    DestroyTrails()
                end))

                Trails:Connection(RunService.PreSimulation:Connect(function(dt)
                    if not Trails.Enabled then
                        DestroyTrails()
                        return
                    end

                    Time += dt
                    if Time >= TrailsData.Settings.SpawnSpeed then
                        Time = 0
                        if Bloomware:IsAlive(LocalPlayer) then
                            MakePart(PrimaryPart.CFrame * CFrame.new(0, -3, 0))
                        end
                    end
                end), {TrailsData.Connections})
            end
        end
    end

    Trails = Tabs.Render:CreateModule({
        Name = "Trails",
        Flag = "UniversalTrails",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                MainTrail()
                self:Connection(LocalPlayer.CharacterAdded:Connect(MainTrail))
            else
                DestroyTrails()
            end
        end
    })

    local Width, Size
    Trails:Dropdown({
        Name = "Shape",
        Flag = "UniversalTrailShape",
        Default = "Trail",
        Options = {"Trail", "Plate", "Sphere", "Cube", "Circle", "Triangle"},
        CallingFunction = function(self, value: string)
            TrailsData.Settings.Shape = value
            Width:SetVisiblity(value == "Trail")
            Size:SetVisiblity(value ~= "Trail")

            for i,v in TrailsData.Connections do
                v:Disconnect()
            end

            table.clear(TrailsData.Connections)
            DestroyTrails()
            MainTrail()
        end
    })

    Trails:Slider({
        Name = "Lifetime",
        Flag = "UniversalTrailLifetime",
        Min = 1,
        Max = 5,
        Default = 3,
        CallingFunction = function(self, value: number)
            TrailsData.Settings.Lifetime = value

            DestroyTrails()
            MainTrail()
        end
    })

    Trails:Slider({
        Name = "Spawn Speed",
        Flag = "UniversalTrailSpawnSpeed",
        Min = 0.01,
        Max = 0.3,
        Default = 0.15,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            TrailsData.Settings.SpawnSpeed = value
        end
    })

    Width = Trails:Slider({
        Name = "Width",
        Flag = "UniversalTrailWidth",
        Min = 1,
        Max = 7,
        Default = 3,
        CallingFunction = function(self, value: number)
            TrailsData.Settings.Width = value

            DestroyTrails()
            MainTrail()
        end
    })

    Size = Trails:Slider({
        Name = "Size",
        Flag = "UniversalTrailSize",
        Min = 1,
        Max = 5,
        Default = 2,
        CallingFunction = function(self, value: number)
            TrailsData.Settings.Size = value

            DestroyTrails()
            MainTrail()
        end
    })

    Trails:ColorSlider({
        Name = "Color",
        Flag = "UniversalTrailColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, value: Color3)
            TrailsData.Settings.Color = value

            DestroyTrails()
            MainTrail()
        end
    })
end)();

(function()
    local ChinaHatData = {
        Settings = {
            Material = "Neon",
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5,
            Size = 3
        },
        Data = {
            Mesh = nil,
            Weld = nil
        }
    }

    local function MakeHat()
        if ChinaHatData.Data.Mesh then
            ChinaHatData.Data.Mesh:Destroy()
        end

        repeat task.wait() until Bloomware:IsAlive(LocalPlayer)
        local Mesh = Instance.new("MeshPart")
        Mesh.Name = "ChinaHat"
        Mesh.MeshId = "http://www.roblox.com/asset/?id=1778999"
        Mesh.Size = Vector3.new(ChinaHatData.Settings.Size, 0.75, ChinaHatData.Settings.Size)
        Mesh.Transparency = ChinaHatData.Settings.Transparency
        Mesh.Color = ChinaHatData.Settings.Color
        Mesh.Material = Enum.Material[ChinaHatData.Settings.Material]
        Mesh.CanCollide = false
        Mesh.Anchored = false

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = Mesh
        pcall(function() Weld.Part1 = LocalPlayer.Character.Head end)
        Weld.Parent = Mesh

        pcall(function() Mesh.CFrame = LocalPlayer.Character.Head.CFrame * CFrame.new(0, 1, 0) end)
        Mesh.Parent = LocalPlayer.Character

        ChinaHatData.Data.Mesh = Mesh
        ChinaHatData.Data.Weld = Weld
    end

    local function UpdateHat()
        local Hat = ChinaHatData.Data.Mesh
        if Hat then
            Hat.Size = Vector3.new(ChinaHatData.Settings.Size, 0.6, ChinaHatData.Settings.Size)
            Hat.Transparency = ChinaHatData.Settings.Transparency
            Hat.Color = ChinaHatData.Settings.Color
            Hat.Material = Enum.Material[ChinaHatData.Settings.Material]
        end
    end

    local ChinaHat = Tabs.Render:CreateModule({
        Name = "China Hat",
        Flag = "UniversalChinaHat",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(LocalPlayer.CharacterAdded:Connect(MakeHat))
                self:Connection(RunService.PreSimulation:Connect(function()
                    if Bloomware:IsAlive(LocalPlayer) and (not ChinaHatData.Data.Mesh or not ChinaHatData.Data.Mesh.Parent) then
                        MakeHat()
                    end
                end))
            else
                if ChinaHatData.Data.Mesh then
                    ChinaHatData.Data.Mesh:Destroy()
                end
                ChinaHatData.Data.Mesh = nil
                ChinaHatData.Data.Weld = nil
            end
        end
    })
    
    ChinaHat:Dropdown({
        Name = "Material",
        Flag = "UniversalChinaHatMaterial",
        Default = "Neon",
        Options = Materials,
        CallingFunction = function(self, value: string)
            ChinaHatData.Settings.Material = value
            UpdateHat()
        end
    })

    ChinaHat:ColorSlider({
        Name = "Color",
        Flag = "UniversalChinaHatColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, value: Color3)
            ChinaHatData.Settings.Color = value
            UpdateHat()
        end
    })

    ChinaHat:Slider({
        Name = "Size",
        Flag = "UniversalChinaHatSize",
        Min = 1,
        Max = 5,
        Default = 3,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            ChinaHatData.Settings.Size = value
            UpdateHat()
        end
    })

    ChinaHat:Slider({
        Name = "Transparency",
        Flag = "UniversalChinaHatTransparency",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            ChinaHatData.Settings.Transparency = value
            UpdateHat()
        end
    })
end)();

(function()
    local CapeData = {
        Settings = {
            Color = Color3.fromRGB(15, 15, 15),
            Material = "SmoothPlastic",
            Length = 7,
            Width = 2,
            Transparency = 0,
            WindStrength = 0.3,
            PhysicsStrength = 0.5
        },
        Data = {
            Segments = {},
            Velocities = {},
            Connection = nil
        }
    }

    local function DestroyCape()
        for _, Seg in next, CapeData.Data.Segments do
            if Seg and Seg.Parent then
                Seg:Destroy()
            end
        end
        CapeData.Data.Segments = {}
        CapeData.Data.Velocities = {}
    end

    local function MakeCape()
        DestroyCape()
        repeat task.wait() until Bloomware:IsAlive(LocalPlayer)

        local Character = LocalPlayer.Character
        local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
        if not Torso then return end

        local SegHeight = CapeData.Settings.Length / 12
        local Segments = {}
        local Velocities = {}

        for I = 1, 12 do
            local Part = Instance.new("Part")
            Part.Size = Vector3.new(CapeData.Settings.Width, SegHeight * 1.35, 0.08)
            Part.Color = CapeData.Settings.Color
            Part.Material = Enum.Material[CapeData.Settings.Material]
            Part.Transparency = CapeData.Settings.Transparency
            Part.CanCollide = false
            Part.Anchored = true
            Part.CastShadow = false
            Part.Parent = Character

            Segments[I] = Part
            Velocities[I] = Vector3.zero
        end

        CapeData.Data.Segments = Segments
        CapeData.Data.Velocities = Velocities
    end

    local function UpdateCapeVisuals()
        for I, Seg in next, CapeData.Data.Segments do
            if Seg and Seg.Parent then
                Seg.Color = CapeData.Settings.Color
                Seg.Material = Enum.Material[CapeData.Settings.Material]
                Seg.Transparency = CapeData.Settings.Transparency
                local SegHeight = CapeData.Settings.Length / 12
                Seg.Size = Vector3.new(CapeData.Settings.Width, SegHeight * 1.35, 0.08)
            end
        end
    end

    local function SimulateCape(DT: number)
        local Segments = CapeData.Data.Segments
        local Velocities = CapeData.Data.Velocities
        if #Segments == 0 then return end
        if not Bloomware:IsAlive(LocalPlayer) then return end

        local Character = LocalPlayer.Character
        local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
        if not Torso then return end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local CharVelocity = Vector3.zero
        if HumanoidRootPart then
            CharVelocity = HumanoidRootPart.AssemblyLinearVelocity
        end

        local TorsoCF = Torso.CFrame
        local SegHeight = CapeData.Settings.Length / 12
        local PhysStr = CapeData.Settings.PhysicsStrength
        local WindStr = CapeData.Settings.WindStrength

        local AttachCF = TorsoCF * CFrame.new(0, Torso.Size.Y * 0.45, Torso.Size.Z * 0.5)
        local Gravity = Vector3.new(0, -15 * PhysStr, 0)

        local T = os.clock()
        local Wind = TorsoCF.RightVector * (math.sin(T * 2.1) * 0.15 + math.sin(T * 3.7) * 0.1) * WindStr + TorsoCF.LookVector * (math.sin(T * 1.3) * 0.3) * WindStr

        local MoveForce = Vector3.zero
        if CharVelocity.Magnitude > 1 then
            local LocalVel = TorsoCF:VectorToObjectSpace(CharVelocity)
            LocalVel = Vector3.new(LocalVel.X * 0.15, LocalVel.Y, LocalVel.Z)
            MoveForce = TorsoCF:VectorToWorldSpace(LocalVel) * -0.1 * PhysStr
        end

        local Damping = math.clamp(1 - 8 * DT, 0, 1)
        local PrevPos = AttachCF.Position

        for I = 1, 12 do
            local Seg = Segments[I]
            if not Seg or not Seg.Parent then return end

            local TargetPos = PrevPos - TorsoCF.UpVector * SegHeight

            local Influence = I / 12
            local Forces = Gravity + Wind * Influence + MoveForce * Influence

            Velocities[I] = (Velocities[I] + Forces * DT) * Damping

            local CurrentCenter = Seg.CFrame.Position
            local NewPos = CurrentCenter + Velocities[I] * DT

            local Offset = NewPos - PrevPos
            local Dist = Offset.Magnitude
            local MaxDist = SegHeight * 1.02
            if Dist > MaxDist then
                NewPos = PrevPos + Offset.Unit * MaxDist
            end

            local RestPos = TargetPos
            NewPos = NewPos:Lerp(RestPos, math.clamp(5 * DT, 0, 0.4))

            local LocalOffset = TorsoCF:PointToObjectSpace(NewPos)
            LocalOffset = Vector3.new(LocalOffset.X * 0.7, LocalOffset.Y, LocalOffset.Z)
            NewPos = TorsoCF:PointToWorldSpace(LocalOffset)

            local Dir = (NewPos - PrevPos)
            if Dir.Magnitude < 0.001 then
                Dir = -TorsoCF.UpVector
            end

            local Center = PrevPos + Dir.Unit * (SegHeight * 0.5)
            local CF = CFrame.lookAt(Center, Center + Dir.Unit, TorsoCF.LookVector) * CFrame.Angles(math.rad(90), 0, 0)

            Seg.CFrame = CF
            PrevPos = NewPos
        end

        CapeData.Data.Velocities = Velocities
    end

    local Cape = Tabs.Render:CreateModule({
        Name = "Cape",
        Flag = "UniversalCape",
        CallingFunction = function(Self, Enabled: boolean)
            if Enabled then
                MakeCape()
                Self:Connection(LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    MakeCape()
                end))

                Self:Connection(RunService.PreSimulation:Connect(function()
                    if Bloomware:IsAlive(LocalPlayer) and #CapeData.Data.Segments == 0 then
                        MakeCape()
                    end
                end))

                Self:Connection(RunService.Heartbeat:Connect(function(DT)
                    SimulateCape(DT)
                end))
            else
                DestroyCape()
            end
        end
    })

    Cape:Dropdown({
        Name = "Material",
        Flag = "UniversalCapeMaterial",
        Default = "SmoothPlastic",
        Options = Materials,
        CallingFunction = function(Self, Value: string)
            CapeData.Settings.Material = Value
            UpdateCapeVisuals()
        end
    })

    Cape:ColorSlider({
        Name = "Color",
        Flag = "UniversalCapeColor",
        Default = Color3.fromRGB(15, 15, 15),
        CallingFunction = function(Self, Value: Color3)
            CapeData.Settings.Color = Value
            UpdateCapeVisuals()
        end
    })

    Cape:Slider({
        Name = "Length",
        Flag = "UniversalCapeLength",
        Min = 2,
        Max = 10,
        Default = 7,
        Increment = 0.5,
        CallingFunction = function(Self, Value: number)
            CapeData.Settings.Length = Value
            UpdateCapeVisuals()
        end
    })

    Cape:Slider({
        Name = "Width",
        Flag = "UniversalCapeWidth",
        Min = 1,
        Max = 5,
        Default = 2,
        Increment = 0.5,
        CallingFunction = function(Self, Value: number)
            CapeData.Settings.Width = Value
            UpdateCapeVisuals()
        end
    })

    Cape:Slider({
        Name = "Transparency",
        Flag = "UniversalCapeTransparency",
        Min = 0,
        Max = 1,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(Self, Value: number)
            CapeData.Settings.Transparency = Value
            UpdateCapeVisuals()
        end
    })

    Cape:Slider({
        Name = "Physics Strength",
        Flag = "UniversalCapePhysics",
        Min = 0.1,
        Max = 1,
        Default = 0.5,
        Increment = 0.1,
        CallingFunction = function(Self, Value: number)
            CapeData.Settings.PhysicsStrength = Value
        end
    })

    Cape:Slider({
        Name = "Wind Strength",
        Flag = "UniversalCapeWind",
        Min = 0,
        Max = 1,
        Default = 0.3,
        Increment = 0.1,
        CallingFunction = function(Self, Value: number)
            CapeData.Settings.WindStrength = Value
        end
    })
end)();

(function()
    local InfiniteJumpData = {
        Settings = {
            Mode = "Hold",
            Delay = 0
        },
        Data = {
            Jump = 0,
            Holding = false
        }
    }
    
    local InfiniteJump = Tabs.Movement:CreateModule({
        Name = "Infinite Jump",
        Flag = "UniversalInfiniteJump",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(UserInputService.JumpRequest:Connect(function()  
                    local LastJumped: number = (os.clock() - InfiniteJumpData.Data.Jump)
                    if LastJumped >= InfiniteJumpData.Settings.Delay and Bloomware:IsAlive(LocalPlayer) then
                        if InfiniteJumpData.Settings.Mode ~= "Hold" and 0.1 > LastJumped then
                            return
                        end

                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        InfiniteJumpData.Data.Jump = os.clock()
                    end
                end))
            end
        end
    })

    local Delay
    InfiniteJump:Dropdown({
        Name = "Mode",
        Flag = "UniversalInfiniteJumpMode",
        Default = "Hold",
        Options = {"Hold", "Tap"},
        CallingFunction = function(self, value: string)
            InfiniteJumpData.Settings.Mode = value
            Delay:SetVisiblity(value == "Hold")
        end
    })

    Delay = InfiniteJump:Slider({
        Name = "Jump Delay",
        Flag = "UniversalInfiniteJumpDelay",
        Min = 0,
        Max = 0.5,
        Default = 0,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            InfiniteJumpData.Settings.Delay = value
        end
    })
end)();

(function()
    local AutoClickerData = {
        ClickType = "Left",
        CPS = 10
    }

    local AutoClicker = Tabs.Combat:CreateModule({
        Name = "Auto Clicker",
        Flag = "UniversalAutoClicker",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    local Mouse: Mouse? = LocalPlayer:GetMouse()
                    VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y + 8, AutoClickerData.ClickType == "Left" and 0 or 1, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y + 8, AutoClickerData.ClickType == "Left" and 0 or 1, false, game, 1)
                    task.wait(1 / AutoClickerData.CPS)
                until not self.Enabled
            end
        end
    })

    AutoClicker:Dropdown({
        Name = "Click Type",
        Flag = "UniversalAutoClickerClickType",
        Default = "Left",
        Options = {"Left", "Right"},
        CallingFunction = function(self, value: string)
            AutoClickerData.ClickType = value
        end
    })

    AutoClicker:Slider({
        Name = "CPS",
        Flag = "UniversalAutoClickerCPS",
        Min = 1,
        Max = 20,
        Default = 10,
        Increment = 1,
        CallingFunction = function(self, value: number)
            AutoClickerData.CPS = value
        end
    })
end)();

(function()
    local TeamCheck = false
    local Distance = 30

    local TargetHud = Tabs.Render:CreateModule({
        Name = "Target HUD",
        Flag = "TargetHUD",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local Health = {
                    Current = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Health")) or 0,
                    Max = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("MaxHealth")) or 0
                }

                if Bloomware:IsAlive(LocalPlayer) then
                    local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                    Health = {
                        Current = LocalPlayer.Character:GetAttribute("Health") or Humanoid.Health,
                        Max = LocalPlayer.Character:GetAttribute("MaxHealth") or Humanoid.MaxHealth
                    }
                end

                Bloomware:GetTargetHud(true, {Player = LocalPlayer, Health = Health})
                repeat
                    local Nearest: { Distance: number, Player: Player? } = Bloomware:GetClosestPlayer({
                        TeamCheck = TeamCheck
                    })

                    if Nearest.Player and Distance >= Nearest.Distance then
                        Health = {
                            Current = Nearest.Player.Character:GetAttribute("Health") or 0,
                            Max = Nearest.Player.Character:GetAttribute("MaxHealth") or 0
                        }

                        if Bloomware:IsAlive(Nearest.Player) then
                            local Humanoid: Humanoid = Nearest.Player.Character.Humanoid
                            Health = {
                                Current = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Health")) or Humanoid.Health,
                                Max = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("MaxHealth")) or Humanoid.MaxHealth
                            }
                        end

                        Bloomware:GetTargetHud():Update({
                            Player = Nearest.Player,
                            Health = Health,
                            Visible = true
                        })
                    else
                        Health = {
                                Current = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Health")) or 0,
                                Max = (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("MaxHealth")) or 0
                        }

                        if Bloomware:IsAlive(LocalPlayer) then
                            local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                            Health = {
                                Current = LocalPlayer.Character:GetAttribute("Health") or Humanoid.Health,
                                Max = LocalPlayer.Character:GetAttribute("MaxHealth") or Humanoid.MaxHealth
                            }
                        end

                        Bloomware:GetTargetHud():Update({
                            Player = LocalPlayer,
                            Health = Health,
                            Visible = Bloomware.UIData.UIOpen
                        })
                    end
                    task.wait(9.5)
                until not self.Enabled
            else
                Bloomware:DestroyTargetHud()
            end
        end
    })

    TargetHud:Slider({
        Name = "Distance",
        Flag = "TargetHUDDistance",
        Min = 1,
        Max = 100,
        Default = 30,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    TargetHud:MiniToggle({
        Name = "Team Check",
        Flag = "TargetHUDTeamCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            TeamCheck = value
        end
    })
end)();

(function()
    local FPSBoostData = {
        RemoveParticles = false,
        RemoveTrails = false,
        RemoveSmoke = false,
        RemoveFire = false,
        RemoveSparkles = false,
        RemoveBeams = false,
        RemoveTextures = false,
        RemoveSurfaceAppearance = false,
        RemoveCharacterMeshes = false,
        SimplifyParts = false,
        LowerLighting = false,
        RemoveTerrainEffects = false,
        AutoClean = false
    }

    local function RemoveMaterials(inst)
        if not inst then return end
        if FPSBoostData.RemoveParticles and inst:IsA("ParticleEmitter") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveTrails and inst:IsA("Trail") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveSmoke and inst:IsA("Smoke") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveFire and inst:IsA("Fire") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveSparkles and inst:IsA("Sparkles") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveBeams and inst:IsA("Beam") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveTextures and (inst:IsA("Decal") or inst:IsA("Texture")) then
            pcall(function() inst.Transparency = 1 end)
            pcall(function() inst.Texture = "" end)
        elseif FPSBoostData.RemoveSurfaceAppearance and inst:IsA("SurfaceAppearance") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.RemoveCharacterMeshes and inst:IsA("CharacterMesh") then
            pcall(function() inst:Destroy() end)
        elseif FPSBoostData.SimplifyParts and inst:IsA("BasePart") then
            pcall(function() inst.CastShadow = false end)
            pcall(function() inst.Material = Enum.Material.SmoothPlastic end)
            pcall(function() inst.Reflectance = 0 end)
            if inst:IsA("MeshPart") then
                pcall(function() inst.TextureID = "" end)
            end
        end
    end

    local FPSBoost = Tabs.Render:CreateModule({
        Name = "FPS Boost",
        Flag = "FPSBoost",
        CallingFunction = function(self, enabled: boolean)
            self.OldENV = self.OldENV or {}
            if enabled then
                self.OldENV = {
                    GlobalShadows = Lighting.GlobalShadows,
                    Brightness = Lighting.Brightness,
                    OutdoorAmbient = Lighting.OutdoorAmbient,
                    Ambient = Lighting.Ambient,
                    FogStart = Lighting.FogStart,
                    FogEnd = Lighting.FogEnd,
                    Effects = {},
                    QualityLevel = settings().Rendering.QualityLevel,
                    Terrain = Terrain and {
                        WaterWaveSize = Terrain.WaterWaveSize,
                        WaterWaveSpeed = Terrain.WaterWaveSpeed,
                        WaterReflectance = Terrain.WaterReflectance,
                        WaterTransparency = Terrain.WaterTransparency
                    } or nil
                }

                for _, obj in next, Lighting:GetChildren() do
                    if obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                        self.OldENV.Effects[obj] = obj.Enabled
                    end
                    if obj:IsA("Atmosphere") or obj:IsA("Sky") then
                        obj:Destroy()
                    end
                end

                for _, v in next, workspace:GetDescendants() do
                    RemoveMaterials(v)
                end

                if FPSBoostData.AutoClean then
                    workspace.DescendantAdded:Connect(RemoveMaterials)
                end

                if FPSBoostData.LowerLighting then
                    pcall(function()
                        Lighting.GlobalShadows = false
                        Lighting.Brightness = 1
                        Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
                        Lighting.Ambient = Color3.fromRGB(120, 120, 120)
                        Lighting.FogStart = 1
                        Lighting.FogEnd = 100000
                        for _, obj in next, Lighting:GetChildren() do
                            if obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                                obj.Enabled = false
                            end
                        end
                    end)
                end

                if FPSBoostData.RemoveTerrainEffects and Terrain then
                    pcall(function()
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.WaterTransparency = 1
                    end)
                end

                pcall(function()
                    settings().Rendering.QualityLevel = 1
                end)
            else
                local env = self.OldENV
                if not env then return end

                pcall(function()
                    Lighting.GlobalShadows = env.GlobalShadows
                    Lighting.Brightness = env.Brightness or 0
                    Lighting.OutdoorAmbient = env.OutdoorAmbient
                    Lighting.Ambient = env.Ambient
                    Lighting.FogStart = env.FogStart
                    Lighting.FogEnd = env.FogEnd
                    for obj, enabled in next, env.Effects do
                        if obj and obj:IsDescendantOf(Lighting) then
                            obj.Enabled = enabled
                        end
                    end
                end)

                if Terrain and env.Terrain then
                    pcall(function()
                        Terrain.WaterWaveSize = env.Terrain.WaterWaveSize
                        Terrain.WaterWaveSpeed = env.Terrain.WaterWaveSpeed
                        Terrain.WaterReflectance = env.Terrain.WaterReflectance
                        Terrain.WaterTransparency = env.Terrain.WaterTransparency
                    end)
                end

                pcall(function()
                    settings().Rendering.QualityLevel = env.QualityLevel
                end)
            end
        end
    })

    FPSBoost:MiniToggle({
        Name = "Particles",
        Flag = "FPSBoostRemoveParticles",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveParticles = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Trails",
        Flag = "FPSBoostRemoveTrails",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveTrails = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Smoke",
        Flag = "FPSBoostRemoveSmoke",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveSmoke = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Fire",
        Flag = "FPSBoostRemoveFire",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveFire = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Sparkles",
        Flag = "FPSBoostRemoveSparkles",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveSparkles = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Beams",
        Flag = "FPSBoostRemoveBeams",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveBeams = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Textures",
        Flag = "FPSBoostRemoveTextures",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveTextures = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Surface Appearance",
        Flag = "FPSBoostRemoveSurfaceAppearance",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveSurfaceAppearance = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Character Meshes",
        Flag = "FPSBoostRemoveCharacterMeshes",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveCharacterMeshes = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Simplify Parts",
        Flag = "FPSBoostSimplifyParts",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.SimplifyParts = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Lower Lighting",
        Flag = "FPSBoostLowerLighting",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.LowerLighting = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Terrain Effects",
        Flag = "FPSBoostRemoveTerrainEffects",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.RemoveTerrainEffects = value
        end
    })

    FPSBoost:MiniToggle({
        Name = "Auto Clean",
        Flag = "FPSBoostAutoClean",
        Default = true,
        CallingFunction = function(self, value)
            FPSBoostData.AutoClean = value
        end
    })
end)();

(function()
    local TriggerBotData = {
        ClickType = "Left",
        CPS = 20,
        Range = 30,
        DistanceCheck = false,
        TeamCheck = false
    }

    local TriggerBot
    TriggerBot = Tabs.Combat:CreateModule({
        Name = "Trigger Bot",
        Flag = "TriggerBot",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local Mouse: Mouse? = LocalPlayer:GetMouse()
                if mouse1press and mouse2press then
                    repeat
                        if Bloomware:IsAlive(LocalPlayer) and Mouse and Mouse.Target and Mouse.Target.Parent and Mouse.Target.Parent:FindFirstChild("Humanoid") and Mouse.Target.Parent.Name ~= LocalPlayer.Name then
                            local TargetRoot: BasePart? = Mouse.Target.Parent:FindFirstChild("HumanoidRootPart")
                            local PlayerRoot: BasePart? = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                            if TargetRoot and PlayerRoot then
                                if TriggerBotData.TeamCheck then
                                    local TargetPlayer: Player? = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
                                    if TargetPlayer and TargetPlayer.Team == LocalPlayer.Team then
                                        continue
                                    end
                                end

                                local Dist: number = (TargetRoot.Position - PlayerRoot.Position).Magnitude
                                if TriggerBotData.DistanceCheck and Dist <= TriggerBotData.Range or not TriggerBotData.DistanceCheck then
                                    if TriggerBotData.ClickType == "Left" then
                                        mouse1press()
                                    else
                                        mouse2press()
                                    end
                                end
                            end
                        end
                        task.wait(1 / TriggerBotData.CPS)
                    until not self.Enabled
                else
                    Bloomware:CreateNotification({
                        Title = "Trigger Bot",
                        Description = "Your executor doesn't support click functions.",
                        Duration = 10
                    })
                    TriggerBot:SetValue(false, false, false)
                end
            end
        end
    })

    TriggerBot:Dropdown({
        Name = "Click Type",
        Flag = "TriggerBotClickType",
        Default = "Left",
        Options = {"Left", "Right"},
        CallingFunction = function(self, value: string)
            TriggerBotData.ClickType = value
        end
    })

    TriggerBot:Slider({
        Name = "CPS",
        Flag = "TriggerBotCPS",
        Min = 1,
        Max = 50,
        Default = 10,
        Increment = 1,
        CallingFunction = function(self, value: number)
            TriggerBotData.CPS = value
        end
    })

    TriggerBot:MiniToggle({
        Name = "Team Check",
        Flag = "TriggerBotTeamCheck",
        CallingFunction = function(self, value: boolean)
            TriggerBotData.TeamCheck = value
        end
    })

    local TriggerRange
    TriggerBot:MiniToggle({
        Name = "Distance Check",
        Flag = "TriggerBotCheck",
        CallingFunction = function(self, value: boolean)
            TriggerBotData.DistanceCheck = value
            TriggerRange:SetVisiblity(value)
        end
    })

    TriggerRange = TriggerBot:Slider({
        Name = "Range",
        Flag = "TriggerBotRange",
        Min = 1,
        Max = 100,
        Default = 30,
        Increment = 1,
        CallingFunction = function(self, value: number)
            TriggerBotData.Range = value
        end
    })
end)();

(function()
    local Mode: string = "Comet"

    local LightingProps = {
        "Ambient",
        "Brightness",
        "EnvironmentDiffuseScale",
        "EnvironmentSpecularScale",
        "GlobalShadows",
        "OutdoorAmbient",
        "ClockTime",
        "GeographicLatitude",
        "ExposureCompensation",
        "FogColor",
        "FogEnd",
        "FogStart"
    }
    local OldLighting = {}
    local OldChildren = {}

    local Settings = {
        AmbientColor = Color3.fromRGB(100, 100, 100),
        Brightness = 1.5,
        Time = 14,
        Density = 0.5,
        CCColor = Color3.fromRGB(255, 255, 255),
        CCBrightness = 0.15,
        CCContrast = 0.03,
        CCSaturation = -0.3,
        SkyboxBk = "Skybox Back ID",
        SkyboxDn = "Skybox Down ID",
        SkyboxFt = "Skybox Front ID",
        SkyboxLf = "Skybox Left ID",
        SkyboxRt = "Skybox Right ID",
        SkyboxUp = "Skybox Up ID"
    }

    local function SaveLighting()
        table.clear(OldLighting)
        table.clear(OldChildren)

        for _, Prop in LightingProps do
            pcall(function()
                OldLighting[Prop] = Lighting[Prop]
            end)
        end

        for _, Child in Lighting:GetChildren() do
            local Success, Clone = pcall(function()
                return Child:Clone()
            end)
            if Success and Clone then
                table.insert(OldChildren, Clone)
            end
        end
    end

    local function RestoreLighting()
        for _, Child in Lighting:GetChildren() do
            Child:Destroy()
        end

        for _, Child in OldChildren do
            local Success, Clone = pcall(function()
                return Child:Clone()
            end)
            if Success and Clone then
                Clone.Parent = Lighting
            end
        end

        for Prop, Value in OldLighting do
            pcall(function()
                Lighting[Prop] = Value
            end)
        end
    end

    local GameAtmosphere = Tabs.Render:CreateModule({
        Name = "Atmosphere",
        Flag = "Atmosphere",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                SaveLighting()

                for _, v in next, Lighting:GetChildren() do
                    if v then
                        v:Destroy()
                    end
                end

                local Atmosphere = Instance.new("Atmosphere", Lighting)
                local Sky = Instance.new("Sky", Lighting)
                local Color = Instance.new("ColorCorrectionEffect", Lighting)

                if Mode == "Winter" then
                    Lighting.Ambient = Color3.fromRGB(110, 110, 110)
                    Lighting.Brightness = 1.8
                    Lighting.EnvironmentDiffuseScale = 0.3
                    Lighting.EnvironmentSpecularScale = 0.1
                    Lighting.GlobalShadows = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
                    Lighting.ClockTime = 15
                    Lighting.GeographicLatitude = 40
                    Lighting.ExposureCompensation = 0.65

                    Atmosphere.Density = 0.3
                    Atmosphere.Offset = 0.25
                    Atmosphere.Color = Color3.fromRGB(255, 255, 255)

                    Sky.SkyboxBk = "http://www.roblox.com/asset/?id=8139677359"
                    Sky.SkyboxDn = "http://www.roblox.com/asset/?id=8139677253"
                    Sky.SkyboxFt = "http://www.roblox.com/asset/?id=8139677111"
                    Sky.SkyboxLf = "http://www.roblox.com/asset/?id=8139676988"
                    Sky.SkyboxRt = "http://www.roblox.com/asset/?id=8139676842"
                    Sky.SkyboxUp = "http://www.roblox.com/asset/?id=8139676647"
                    Sky.SunAngularSize = 10

                    Color.Brightness = 0.13
                    Color.Contrast = 0.05
                    Color.Saturation = -0.35
                    Color.TintColor = Color3.fromRGB(105, 75, 170)
                elseif Mode == "Comet" then
                    Lighting.Ambient = Color3.fromRGB(110, 110, 110)
                    Lighting.Brightness = 1.6
                    Lighting.EnvironmentDiffuseScale = 0.4
                    Lighting.EnvironmentSpecularScale = 0.7
                    Lighting.GlobalShadows = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
                    Lighting.ClockTime = 14
                    Lighting.GeographicLatitude = 35
                    Lighting.ExposureCompensation = 0.45

                    Atmosphere.Density = 0.35
                    Atmosphere.Offset = 0.3
                    Atmosphere.Color = Color3.fromRGB(255, 255, 255)

                    Sky.SkyboxBk = "http://www.roblox.com/asset/?id=16262356578"
                    Sky.SkyboxDn = "http://www.roblox.com/asset/?id=16262358026"
                    Sky.SkyboxFt = "http://www.roblox.com/asset/?id=16262360469"
                    Sky.SkyboxLf = "http://www.roblox.com/asset/?id=16262362003"
                    Sky.SkyboxRt = "http://www.roblox.com/asset/?id=16262363873"
                    Sky.SkyboxUp = "http://www.roblox.com/asset/?id=16262366016"
                    Sky.SunAngularSize = 20

                    Color.Brightness = 0.18
                    Color.Contrast = 0.03
                    Color.Saturation = -0.25
                    Color.TintColor = Color3.fromRGB(110, 80, 180)
                elseif Mode == "Calm" then
                    Lighting.Ambient = Color3.fromRGB(100, 100, 100)
                    Lighting.Brightness = 1.3
                    Lighting.EnvironmentDiffuseScale = 0.3
                    Lighting.EnvironmentSpecularScale = 0.5
                    Lighting.GlobalShadows = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
                    Lighting.ClockTime = 15
                    Lighting.GeographicLatitude = 35
                    Lighting.ExposureCompensation = 0.6

                    Atmosphere.Density = 0.3
                    Atmosphere.Offset = 0.2
                    Atmosphere.Color = Color3.fromRGB(255, 255, 255)

                    Sky.SkyboxBk = "http://www.roblox.com/asset/?id=4495864450"
                    Sky.SkyboxDn = "http://www.roblox.com/asset/?id=4495864887"
                    Sky.SkyboxFt = "http://www.roblox.com/asset/?id=4495865458"
                    Sky.SkyboxLf = "http://www.roblox.com/asset/?id=4495866035"
                    Sky.SkyboxRt = "http://www.roblox.com/asset/?id=4495866584"
                    Sky.SkyboxUp = "http://www.roblox.com/asset/?id=4495867486"
                    Sky.SunAngularSize = 1

                    Color.Brightness = 0.13
                    Color.Contrast = 0.03
                    Color.Saturation = -0.3
                    Color.TintColor = Color3.fromRGB(120, 85, 200)
                elseif Mode == "Ocean" then
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/null-wtf/Bloomware/refs/heads/main/Games/Shaders.luau"))()
                else
                    Lighting.Ambient = Settings.AmbientColor
                    Lighting.Brightness = Settings.Brightness
                    Lighting.ClockTime = Settings.Time

                    Sky.SkyboxBk = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxBk
                    Sky.SkyboxDn = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxDn
                    Sky.SkyboxFt = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxFt
                    Sky.SkyboxLf = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxLf
                    Sky.SkyboxRt = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxRt
                    Sky.SkyboxUp = "http://www.roblox.com/asset/?id=" .. Settings.SkyboxUp

                    Atmosphere.Density = Settings.Density
                    Atmosphere.Color = Color3.fromRGB(255, 255, 255)

                    Color.Brightness = Settings.CCBrightness
                    Color.Contrast = Settings.CCContrast
                    Color.Saturation = -Settings.CCSaturation
                    Color.TintColor = Settings.CCColor
                end
            else
                RestoreLighting()
            end
        end
    })

    local Custom = {}
    GameAtmosphere:Dropdown({
        Name = "Theme",
        Flag = "AtmosphereTheme",
        Default = "Comet",
        Options = {"Winter", "Comet", "Calm", "Ocean", "Custom"},
        CallingFunction = function(self, value: string)
            Mode = value
            for _, v in next, Custom do
                v:SetVisiblity(value == "Custom")
            end
        end
    })

    table.insert(Custom, GameAtmosphere:ColorSlider({
        Name = "Ambient Color",
        Flag = "AtmosphereAmbient",
        Default = Color3.fromRGB(100, 100, 100),
        CallingFunction = function(self, Color: Color3)
            Settings.AmbientColor = Color
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "Brightness",
        Flag = "AtmosphereBrightness",
        Min = 0,
        Max = 5,
        Default = 1.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Settings.Brightness = value
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "Time",
        Flag = "AtmosphereTime",
        Min = 1,
        Max = 24,
        Default = 14,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Settings.Time = value
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "ATMSPH Density",
        Flag = "AtmosphereDensity",
        Min = 0,
        Max = 2,
        Default = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Settings.Density = value
        end
    }))

    table.insert(Custom, GameAtmosphere:ColorSlider({
        Name = "CC Color",
        Flag = "AtmosphereCCColor",
        Default = Color3.fromRGB(255, 255, 255),
        CallingFunction = function(self, Color: Color3)
            Settings.CCColor = Color
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "CC Brightness",
        Flag = "AtmosphereCCBrightness",
        Min = 0,
        Max = 0.5,
        Default = 0.15,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Settings.CCBrightness = value
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "CC Contrast",
        Flag = "AtmosphereCCContrast",
        Min = 1,
        Max = 0.1,
        Default = 0.03,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Settings.CCContrast = value
        end
    }))

    table.insert(Custom, GameAtmosphere:Slider({
        Name = "CC Saturation",
        Flag = "AtmosphereCCSaturation",
        Min = -2,
        Max = 2,
        Default = -0.3,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Settings.CCSaturation = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Back ID",
        Flag = "AtmosphereSkyboxBk",
        Default = "Skybox Back ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxBk = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Down ID",
        Flag = "AtmosphereSkyboxDn",
        Default = "Skybox Down ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxDn = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Front ID",
        Flag = "AtmosphereSkyboxFt",
        Default = "Skybox Front ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxFt = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Left ID",
        Flag = "AtmosphereSkyboxLf",
        Default = "Skybox Left ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxLf = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Right ID",
        Flag = "AtmosphereSkyboxRt",
        Default = "Skybox Right ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxRt = value
        end
    }))

    table.insert(Custom, GameAtmosphere:TextBox({
        Name = "Skybox Up ID",
        Flag = "AtmosphereSkyboxUp",
        Default = "Skybox Up ID",
        CallingFunction = function(self, value: string)
            Settings.SkyboxUp = value
        end
    }))
end)();

(function()
    local Hook = nil
    local Reset = false

    local function Resync()
        if Bloomware:IsAlive(LocalPlayer) then
            LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(math.nan, math.nan, math.nan)
            Warning("Desync", "Resynced", 5)
        end
    end

    local function Buffer(mode)
        if mode == "max_u32" then
            local Floor = math.floor((2 ^ 16) * (2 ^ 16))
            local Abs = math.abs(math.cos(math.pi))
            return Floor - Abs
        elseif mode == "packet_id" then
            local Offset = math.floor(math.sqrt(9))
            return (math.sqrt(9)) * (2 ^ 3) + Offset
        end
        return 0
    end

    local Desync = Tabs.Movement:CreateModule({
        Name = "Desync",
        Flag = "UniversalDesync",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                Hook = function(packet)
                    if type(packet) ~= "table" and type(packet) ~= "userdata" then return end
                    if not packet.AsArray or packet.AsArray[1] ~= Buffer("packet_id") then
                        return
                    end

                    local data = packet.AsBuffer
                    if not data then return end

                    buffer.writeu32(data, 1, Buffer("max_u32"))

                    packet:SetData(data)
                end

                raknet.add_send_hook(Hook)

                if Bloomware:IsAlive(LocalPlayer) and Reset then
                    LocalPlayer.Character.Humanoid.Health = 0
                end
            elseif Hook then
                pcall(function()
                    raknet.remove_send_hook(Hook)
                end)
                Hook = nil
            end
        end
    })

    Desync:KeyBind({
        Name = "Resync",
        Flag = "DesyncResync",
        Default = Enum.KeyCode.L,
        Events = {
            Began = function()
                Resync()
            end,
            Ended = function()
                Resync()
            end
        }
    })

    Desync:MiniToggle({
        Name = "Reset",
        Flag = "DesyncReset",
        CallingFunction = function(self, value: boolean)
            Reset = value
        end
    })
end)();

(function()
    local Moving: boolean = false
    local Keys: {[Enum.KeyCode]: boolean} = {
        [Enum.KeyCode.W] = false,
        [Enum.KeyCode.A] = false,
        [Enum.KeyCode.S] = false,
        [Enum.KeyCode.D] = false,
        [Enum.KeyCode.Up] = false,
        [Enum.KeyCode.Down] = false,
        [Enum.KeyCode.Left] = false,
        [Enum.KeyCode.Right] = false
    }

    local function StopMoving()
        local Root: BasePart = LocalPlayer.Character.HumanoidRootPart
        local Velo: Vector3 = Root.AssemblyLinearVelocity
        Root.AssemblyLinearVelocity = Vector3.new(0, Velo.Y, 0)
        Root.AssemblyAngularVelocity = Vector3.zero
    end

    Tabs.Movement:CreateModule({
        Name = "Fast Stop",
        Flag = "UniversalFastStop",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(UserInputService.InputBegan:Connect(function(Input: InputObject, Event: boolean)
                    if Event then return end
                    if Keys[Input.KeyCode] ~= nil then
                        Keys[Input.KeyCode] = true
                        Moving = true
                    end
                end))

                self:Connection(UserInputService.InputEnded:Connect(function(Input: InputObject, Event: boolean)
                    if Event then return end
                    if Keys[Input.KeyCode] ~= nil then
                        Keys[Input.KeyCode] = false
                        for _, Pressed in next, Keys do
                            if Pressed then
                                return
                            end
                        end
                        Moving = false
                    end
                end))

                self:Connection(RunService.Heartbeat:Connect(function()
                    if not Moving and Bloomware:IsAlive(LocalPlayer) then
                        StopMoving()
                    end
                end))

                if UserInputService.TouchEnabled or UserInputService.GamepadEnabled then
                    local LastPos: Vector3 = Vector3.zero
                    self:Connection(RunService.Heartbeat:Connect(function()
                        if Bloomware:IsAlive(LocalPlayer) then
                            local MoveDir: Vector3 = LocalPlayer.Character.Humanoid.MoveDirection
                            if MoveDir.Magnitude > 0 then
                                LastPos = MoveDir
                                Moving = true
                            else
                                if Moving and LastPos.Magnitude > 0 then
                                    StopMoving()
                                    Moving = false
                                    LastPos = Vector3.zero
                                end
                            end
                        end
                    end))
                end
            end
        end
    })
end)();

(function()
    local FakeLagData = {
        Randomize = true,
        AnchorTime = 0.5,
        UnanchorTime = 0.35,
        Pause = 1,
        Jitter = 0.15,
        BurstChance = 0.25,
        BurstCountMin = 2,
        BurstCountMax = 5,
        BurstSpeedMin = 0.05,
        BurstSpeedMax = 0.12
    }

    local function Random(a: number, b: number): number
        return a + math.random() * (b - a)
    end

    local FakeLag = Tabs.Movement:CreateModule({
        Name = "Fake Lag",
        Flag = "UniversalFakeLag",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    local Root: BasePart? = Bloomware:IsAlive(LocalPlayer) and LocalPlayer.Character.HumanoidRootPart
                    if Root then
                        if math.random() < FakeLagData.BurstChance then
                            local Count: number = math.random(FakeLagData.BurstCountMin, FakeLagData.BurstCountMax)
                            for _ = 1, Count do
                                Root.Anchored = true
                                task.wait(Random(FakeLagData.BurstSpeedMin, FakeLagData.BurstSpeedMax))
                                Root.Anchored = false
                                task.wait(Random(FakeLagData.BurstSpeedMin, FakeLagData.BurstSpeedMax))
                            end
                        else
                            local Anchor: number = FakeLagData.AnchorTime
                            local Unanchor: number = FakeLagData.UnanchorTime
                            local Pause: number = FakeLagData.Pause

                            if FakeLagData.Randomize then
                                Anchor = math.max(0.05, Anchor + Random(-FakeLagData.Jitter, FakeLagData.Jitter))
                                Unanchor = math.max(0.05, Unanchor + Random(-FakeLagData.Jitter, FakeLagData.Jitter))
                                Pause = math.max(0.05, Pause + Random(-FakeLagData.Jitter, FakeLagData.Jitter))
                            end

                            Root.Anchored = true
                            task.wait(Anchor)
                            Root.Anchored = false
                            task.wait(Unanchor + Pause)
                        end
                    else
                        task.wait(0.25)
                    end
                    
                    task.wait()
                until not self.Enabled
            end
        end
    })

    local Jitter
    FakeLag:MiniToggle({
        Name = "Randomize",
        Flag = "FakeLagRandomize",
        Default = true,
        CallingFunction = function(self, value: boolean)
            FakeLagData.Randomize = value
            Jitter:SetVisiblity(value)
        end
    })

    Jitter = FakeLag:Slider({
        Name = "Jitter",
        Flag = "FakeLagJitter",
        Min = 0,
        Max = 1,
        Default = 0.15,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.Jitter = value
        end
    })

    FakeLag:Slider({
        Name = "Anchor Time",
        Flag = "FakeLagAnchorTime",
        Min = 0.01,
        Max = 2,
        Default = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.AnchorTime = value
        end
    })

    FakeLag:Slider({
        Name = "Unanchor Time",
        Flag = "FakeLagUnanchorTime",
        Min = 0.01,
        Max = 2,
        Default = 0.35,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.UnanchorTime = value
        end
    })

    FakeLag:Slider({
        Name = "Pause",
        Flag = "FakeLagPause",
        Min = 0,
        Max = 3,
        Default = 1,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.Pause = value
        end
    })

    FakeLag:Slider({
        Name = "Burst Chance",
        Flag = "FakeLagBurstChance",
        Min = 0,
        Max = 1,
        Default = 0.25,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.BurstChance = value
        end
    })

    FakeLag:Slider({
        Name = "Burst Count Min",
        Flag = "FakeLagBurstCountMin",
        Min = 1,
        Max = 10,
        Default = 2,
        CallingFunction = function(self, value: number)
            FakeLagData.BurstCountMin = value
        end
    })

    FakeLag:Slider({
        Name = "Burst Count Max",
        Flag = "FakeLagBurstCountMax",
        Min = 1,
        Max = 10,
        Default = 5,
        CallingFunction = function(self, value: number)
            FakeLagData.BurstCountMax = value
        end
    })

    FakeLag:Slider({
        Name = "Burst Speed Min",
        Flag = "FakeLagBurstSpeedMin",
        Min = 0.01,
        Max = 0.2,
        Default = 0.05,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.BurstSpeedMin = value
        end
    })

    FakeLag:Slider({
        Name = "Burst Speed Max",
        Flag = "FakeLagBurstSpeedMax",
        Min = 0.01,
        Max = 0.2,
        Default = 0.12,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            FakeLagData.BurstSpeedMax = value
        end
    })
end)();

(function()
    local Gravity: number = 100
    local OldGravity: number?
    local Module = Tabs.Movement:CreateModule({
        Name = "Gravity",
        Flag = "Gravity",
        CallingFunction = function(self, value: boolean)
            if value then
                OldGravity = workspace.Gravity
                workspace.Gravity = Gravity
                self:Connection(workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
                    workspace.Gravity = Gravity
                end))
            else
                if OldGravity then
                    workspace.Gravity = OldGravity
                    OldGravity = nil
                end
            end
        end
    })
    
    Module:Slider({
        Name = "Gravity",
        Flag = "GravityValue",
        Min = 0,
        Max = 192,
        Default = 100,
        CallingFunction = function(self, value: number)
            Gravity = value
            if Module.Enabled then
                workspace.Gravity = value
            end
        end
    })
end)();

(function()
    local RaycastParams: RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

    Tabs.Utility:CreateModule({
        Name = "Safe Walk",
        Flag = "SafeWalk",
        CallingFunction = function(self, value: boolean)
            if value then
                repeat
                    local Fly = Tabs.Movement.Modules.Fly or Tabs.Movement.Modules.UniversalFly
                    if Bloomware:IsAlive(LocalPlayer) then
                        local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                        if (Fly and not Fly.Enabled or not Fly) then
                            local Filter: {Instance} = {CurrentCamera}
                            for i,v in Players:GetPlayers() do
                                if v.Character then
                                    table.insert(Filter, v.Character)
                                end
                            end

                            RaycastParams.FilterDescendantsInstances = Filter
                            local InfrontOfPlayer: Vector3 = (Humanoid.MoveDirection * 20)
                            local Direction: Vector3 = Vector3.new(InfrontOfPlayer.X, -1000, InfrontOfPlayer.Z)
                            local Raycast: RaycastResult = workspace:Raycast(PrimaryPart.Position, Direction, RaycastParams)
                            PrimaryPart.Anchored = (not Raycast or not Raycast.Instance)
                        else
                            PrimaryPart.Anchored = false
                        end
                    end
                    task.wait()
                until not self.Enabled
            else
                if Bloomware:IsAlive(LocalPlayer) then
                    (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")).Anchored = false
                end
            end
        end
    })
end)();

(function()
    local WaterPart

    Tabs.Movement:CreateModule({
        Name = "Swim",
        Flag = "Swim",
        CallingFunction = function(self, value: boolean)
            if value then
                WaterPart = Instance.new("Part")
                WaterPart.Size = Vector3.new(12, 12, 12)
                WaterPart.Material = Enum.Material.Water
                WaterPart.Transparency = 1
                WaterPart.CanCollide = false
                WaterPart.CanQuery = false
                WaterPart.CanTouch = true
                WaterPart.Anchored = true
                WaterPart.Name = "EFN"
                WaterPart.Parent = workspace

                repeat
                    if Bloomware:IsAlive(LocalPlayer) and WaterPart then
                        local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        WaterPart.Size = (Humanoid.MoveDirection ~= Vector3.zero or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and Vector3.new(14, 14, 14) or Vector3.new(6, 4, 6)
                        WaterPart.CFrame = CFrame.new(PrimaryPart.Position - Vector3.new(0, 1, 0))

                        if Humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                        end
                    end
                    task.wait()
                until not self.Enabled

                if WaterPart then
                    WaterPart:Destroy()
                    WaterPart = nil
                end
            else
                if WaterPart then
                    WaterPart:Destroy()
                    WaterPart = nil
                end
                
                if Bloomware:IsAlive(LocalPlayer) then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
    })
end)();

(function()
    local Arrows
    local ArrowsData = {
        Settings = {
            Color = Color3.fromRGB(255, 255, 255),
            Size = 14,
            Radius = 0.2,
            TeamCheck = false
        },
        Data = {
            Instances = {},
        }
    }

    local function CreateArrow(Target: Player)
        if ArrowsData.Data.Instances[Target] then return end

        local Triangle = Drawing.new("Triangle")
        Triangle.Visible = false
        Triangle.Filled = true
        Triangle.Color = ArrowsData.Settings.Color
        Triangle.Thickness = 1

        ArrowsData.Data.Instances[Target] = Triangle
    end

    local function RemoveArrow(Target: Player)
        local Arrow = ArrowsData.Data.Instances[Target]
        if Arrow then
            Arrow:Destroy()
            ArrowsData.Data.Instances[Target] = nil
        end
    end

    local function DestroyArrows()
        for Player, Arrow in next, ArrowsData.Data.Instances do
            Arrow:Destroy()
            ArrowsData.Data.Instances[Player] = nil
        end
        table.clear(ArrowsData.Data.Instances)
    end

    local function Loop()
        if not Bloomware:IsAlive(LocalPlayer) then
            for _, Arrow in next, ArrowsData.Data.Instances do
                Arrow.Visible = false
            end
            return
        end

        local Size = ArrowsData.Settings.Size
        local ScreenSize = CurrentCamera.ViewportSize
        local CenterScreen = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
        local Radius = math.min(ScreenSize.X, ScreenSize.Y) * ArrowsData.Settings.Radius

        for Target, Arrow in next, ArrowsData.Data.Instances do
            if not Bloomware:IsAlive(Target) then
                Arrow.Visible = false
                continue
            end

            if ArrowsData.Settings.TeamCheck and Target.Team and LocalPlayer.Team and Target.Team == LocalPlayer.Team then
                Arrow.Visible = false
                continue
            end

            local Root = Target.Character.PrimaryPart or Target.Character:FindFirstChild("HumanoidRootPart")
            if not Root then
                Arrow.Visible = false
                continue
            end

            local _, OnScreen = CurrentCamera:WorldToScreenPoint(Root.Position)
            if OnScreen then
                Arrow.Visible = false
                continue
            end

            local Dir = CFrame.lookAlong(CurrentCamera.CFrame.Position, CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)):PointToObjectSpace(Root.Position)
            local Angle = math.atan2(Dir.Z, Dir.X)

            local ArrowPos = CenterScreen + Vector2.new(math.cos(Angle), math.sin(Angle)) * Radius

            local Forward = Vector2.new(math.cos(Angle), math.sin(Angle))
            local Right = Vector2.new(-Forward.Y, Forward.X)

            local Tip = ArrowPos + Forward * Size
            local BaseLeft = ArrowPos - Right * (Size * 0.5)
            local BaseRight = ArrowPos + Right * (Size * 0.5)

            Arrow.PointA = Tip
            Arrow.PointB = BaseLeft
            Arrow.PointC = BaseRight
            Arrow.Color = ArrowsData.Settings.Color
            Arrow.Visible = true
        end
    end

    Arrows = Tabs.Render:CreateModule({
        Name = "Arrows",
        Flag = "Arrows",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, Player in next, Players:GetPlayers() do
                    if Player ~= LocalPlayer then
                        CreateArrow(Player)
                    end
                end

                self:Connection(Players.PlayerAdded:Connect(function(NewPlayer)
                    if NewPlayer ~= LocalPlayer then
                        CreateArrow(NewPlayer)
                    end
                end))

                self:Connection(Players.PlayerRemoving:Connect(function(LeavingPlayer)
                    RemoveArrow(LeavingPlayer)
                end))

                self:Connection(RunService.RenderStepped:Connect(Loop))
            else
                DestroyArrows()
            end
        end
    })

    Arrows:Slider({
        Name = "Size",
        Flag = "ArrowsSize",
        Default = 14,
        Min = 6,
        Max = 30,
        CallingFunction = function(self, value: number)
            ArrowsData.Settings.Size = value
        end
    })

    Arrows:Slider({
        Name = "Radius",
        Flag = "ArrowsRadius",
        Default = 0.2,
        Min = 0.1,
        Max = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            ArrowsData.Settings.Radius = value
        end
    })

    Arrows:ColorSlider({
        Name = "Color",
        Flag = "ArrowsColor",
        Default = Color3.fromRGB(255, 255, 255),
        CallingFunction = function(self, value: Color3)
            ArrowsData.Settings.Color = value
        end
    })

    Arrows:MiniToggle({
        Name = "Team Check",
        Flag = "ArrowsTeamCheck",
        Default = false,
        CallingFunction = function(self, value: boolean)
            ArrowsData.Settings.TeamCheck = value
        end
    })
end)();

(function()
    local Chams

    local ChamsData = {
        Settings = {
            OutlineColor = Color3.fromRGB(255, 255, 255),
            FillColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.5,
            OutlineTransparency = 0,
            TeamCheck = false,
        },
        Data = {
            Highlights = {},
        }
    }

    local function ApplyHighlight(Highlight: Highlight)
        Highlight.OutlineColor = ChamsData.Settings.OutlineColor
        Highlight.FillColor = ChamsData.Settings.FillColor
        Highlight.FillTransparency = ChamsData.Settings.FillTransparency
        Highlight.OutlineTransparency = ChamsData.Settings.OutlineTransparency
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    local function ShouldSkip(Player: Player): boolean
        if ChamsData.Settings.TeamCheck and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
            return true
        end
        return false
    end

    local function AddChams(Player: Player)
        if Player == LocalPlayer then return end

        local function OnCharacterAdded(Character: Model)
            local Existing = ChamsData.Data.Highlights[Player]
            if Existing then
                Existing:Destroy()
                ChamsData.Data.Highlights[Player] = nil
            end

            local Highlight = Instance.new("Highlight")
            Highlight.Name = "BloomwareChams"
            Highlight.Adornee = Character
            Highlight.Parent = Bloomware.cloneref(game:GetService("CoreGui"))
            ApplyHighlight(Highlight)

            ChamsData.Data.Highlights[Player] = Highlight
        end

        if Player.Character then
            OnCharacterAdded(Player.Character)
        end

        Player.CharacterAdded:Connect(OnCharacterAdded)
    end

    local function RemoveChams(Player: Player)
        local Highlight = ChamsData.Data.Highlights[Player]
        if Highlight then
            Highlight:Destroy()
            ChamsData.Data.Highlights[Player] = nil
        end
    end

    local function DestroyAll()
        for Player, Highlight in next, ChamsData.Data.Highlights do
            Highlight:Destroy()
        end
        table.clear(ChamsData.Data.Highlights)
    end

    local function UpdateAll()
        for Player, Highlight in next, ChamsData.Data.Highlights do
            if not Player or not Player.Parent or not Bloomware:IsAlive(Player) then
                Highlight.Enabled = false
                continue
            end

            if ShouldSkip(Player) then
                Highlight.Enabled = false
                continue
            end

            Highlight.Enabled = true
            ApplyHighlight(Highlight)
        end
    end

    Chams = Tabs.Render:CreateModule({
        Name = "Chams",
        Flag = "Chams",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, Player in Players:GetPlayers() do
                    if Player ~= LocalPlayer then
                        AddChams(Player)
                    end
                end

                self:Connection(Players.PlayerAdded:Connect(function(NewPlayer)
                    if NewPlayer ~= LocalPlayer then
                        AddChams(NewPlayer)
                    end
                end))

                self:Connection(Players.PlayerRemoving:Connect(function(LeavingPlayer)
                    RemoveChams(LeavingPlayer)
                end))

                self:Connection(RunService.RenderStepped:Connect(UpdateAll))
            else
                DestroyAll()
            end
        end
    })

    Chams:ColorSlider({
        Name = "Outline Color",
        Flag = "ChamsOutlineColor",
        Default = Color3.fromRGB(255, 255, 255),
        CallingFunction = function(self, value: Color3)
            ChamsData.Settings.OutlineColor = value
            for _, Highlight in next, ChamsData.Data.Highlights do
                Highlight.OutlineColor = value
            end
        end
    })

    Chams:ColorSlider({
        Name = "Fill Color",
        Flag = "ChamsFillColor",
        Default = Color3.fromRGB(255, 255, 255),
        CallingFunction = function(self, value: Color3)
            ChamsData.Settings.FillColor = value
            for _, Highlight in next, ChamsData.Data.Highlights do
                Highlight.FillColor = value
            end
        end
    })

    Chams:Slider({
        Name = "Fill Transparency",
        Flag = "ChamsFillTransparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Increment = 0.05,
        CallingFunction = function(self, value: number)
            ChamsData.Settings.FillTransparency = value
            for _, Highlight in next, ChamsData.Data.Highlights do
                Highlight.FillTransparency = value
            end
        end
    })

    Chams:Slider({
        Name = "Outline Transparency",
        Flag = "ChamsOutlineTransparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Increment = 0.05,
        CallingFunction = function(self, value: number)
            ChamsData.Settings.OutlineTransparency = value
            for _, Highlight in next, ChamsData.Data.Highlights do
                Highlight.OutlineTransparency = value
            end
        end
    })

    Chams:MiniToggle({
        Name = "Team Check",
        Flag = "ChamsTeamCheck",
        Default = false,
        CallingFunction = function(self, value: boolean)
            ChamsData.Settings.TeamCheck = value
        end
    })
end)();

(function()
    local Size = 8
    local ExpandedParts = {}

    local function ExpandPlayer(Character)
        local HRP = Character:FindFirstChild("HumanoidRootPart")
        if not HRP or ExpandedParts[Character] then return end

        local Box = Instance.new("Part")
        Box.Size = Vector3.new(Size, Size, Size)
        Box.Transparency = 1
        Box.CanCollide = false
        Box.CanQuery = true
        Box.Massless = true
        Box.Name = "HB"

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = HRP
        Weld.Part1 = Box
        Weld.Parent = Box

        Box.CFrame = HRP.CFrame
        Box.Parent = Character
        ExpandedParts[Character] = Box
    end

    local function Cleanup()
        for _, Part in next, ExpandedParts do
            if Part and Part.Parent then
                Part:Destroy()
            end
        end
        table.clear(ExpandedParts)
    end

    local Hitboxes = Tabs.Combat:CreateModule({
        Name = "Hitboxes",
        Flag = "UniversalHitboxes",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, Player in Players:GetPlayers() do
                    if Player ~= LocalPlayer and Player.Character then
                        ExpandPlayer(Player.Character)
                    end
                end

                self:Connection(Players.PlayerAdded:Connect(function(Player)
                    if Player ~= LocalPlayer then
                        self:Connection(Player.CharacterAdded:Connect(function(Char)
                            task.wait(0.1)
                            ExpandPlayer(Char)
                        end))
                    end
                end))

                for _, Player in Players:GetPlayers() do
                    if Player ~= LocalPlayer then
                        self:Connection(Player.CharacterAdded:Connect(function(Char)
                            task.wait(0.1)
                            ExpandPlayer(Char)
                        end))
                    end
                end
            else
                Cleanup()
            end
        end
    })

    Hitboxes:Slider({
        Name = "Parts Size",
        Flag = "HitboxesPartsSize",
        Min = 2,
        Max = 15,
        Default = 8,
        CallingFunction = function(self, value: number)
            Size = value
        end
    })
end)();

(function()
    local HealthData = {
        Settings = {
            Position = "Bottom Center",
            TextSize = 42,
            ShowMaxHealth = true,
            ShowPercentage = false,
            GlowEnabled = true,
            GlowIntensity = 6,
            GlowTransparency = 0.65,
            PulseOnLow = true,
            PulseThreshold = 25,
            OffsetX = 0,
            OffsetY = -40,
            Prefix = "",
            Suffix = "",
            DecimalPlaces = 0,
            FullHealthColor = Color3.fromRGB(0, 255, 130),
            MidHealthColor = Color3.fromRGB(255, 200, 0),
            LowHealthColor = Color3.fromRGB(255, 50, 50),
            CriticalHealthColor = Color3.fromRGB(200, 0, 0),
            OutlineEnabled = true,
            ShadowEnabled = true,
            ShadowOffset = 2,
            AnimateChanges = true,
            AnimationSpeed = 8
        },
        Data = {
            DisplayedHealth = 0,
            PulsePhase = 0,
            LastHealth = 0
        }
    }

    local HealthText = Drawing.new("Text")
    HealthText.Visible = false
    HealthText.Center = true
    HealthText.Outline = true
    HealthText.Font = Drawing.Fonts.Plex
    HealthText.Size = HealthData.Settings.TextSize

    local GlowText1 = Drawing.new("Text")
    GlowText1.Visible = false
    GlowText1.Center = true
    GlowText1.Outline = false
    GlowText1.Font = Drawing.Fonts.Plex
    GlowText1.Size = HealthData.Settings.TextSize

    local GlowText2 = Drawing.new("Text")
    GlowText2.Visible = false
    GlowText2.Center = true
    GlowText2.Outline = false
    GlowText2.Font = Drawing.Fonts.Plex
    GlowText2.Size = HealthData.Settings.TextSize

    local GlowText3 = Drawing.new("Text")
    GlowText3.Visible = false
    GlowText3.Center = true
    GlowText3.Outline = false
    GlowText3.Font = Drawing.Fonts.Plex
    GlowText3.Size = HealthData.Settings.TextSize

    local GlowText4 = Drawing.new("Text")
    GlowText4.Visible = false
    GlowText4.Center = true
    GlowText4.Outline = false
    GlowText4.Font = Drawing.Fonts.Plex
    GlowText4.Size = HealthData.Settings.TextSize

    local ShadowText = Drawing.new("Text")
    ShadowText.Visible = false
    ShadowText.Center = true
    ShadowText.Outline = false
    ShadowText.Font = Drawing.Fonts.Plex
    ShadowText.Size = HealthData.Settings.TextSize
    ShadowText.Color = Color3.fromRGB(0, 0, 0)

    local AllDrawings = {HealthText, GlowText1, GlowText2, GlowText3, GlowText4, ShadowText}

    local function LerpColor3(a: Color3, b: Color3, t: number): Color3
        return Color3.new(
            a.R + (b.R - a.R) * t,
            a.G + (b.G - a.G) * t,
            a.B + (b.B - a.B) * t
        )
    end

    local function GetHealthColor(percent: number): Color3
        if percent <= 15 then
            return HealthData.Settings.CriticalHealthColor
        elseif percent <= 40 then
            local t = (percent - 15) / 25
            return LerpColor3(HealthData.Settings.LowHealthColor, HealthData.Settings.MidHealthColor, t)
        elseif percent <= 75 then
            local t = (percent - 40) / 35
            return LerpColor3(HealthData.Settings.MidHealthColor, HealthData.Settings.FullHealthColor, t)
        else
            return HealthData.Settings.FullHealthColor
        end
    end

    local function GetPosition(): Vector2
        local ScreenSize = CurrentCamera.ViewportSize
        local Pos = HealthData.Settings.Position
        local OffX = HealthData.Settings.OffsetX
        local OffY = HealthData.Settings.OffsetY

        if Pos == "Bottom Center" then
            return Vector2.new(ScreenSize.X / 2 + OffX, ScreenSize.Y - 80 + OffY)
        elseif Pos == "Top Center" then
            return Vector2.new(ScreenSize.X / 2 + OffX, 40 + OffY)
        elseif Pos == "Center" then
            return Vector2.new(ScreenSize.X / 2 + OffX, ScreenSize.Y / 2 + OffY)
        elseif Pos == "Bottom Left" then
            return Vector2.new(100 + OffX, ScreenSize.Y - 80 + OffY)
        elseif Pos == "Bottom Right" then
            return Vector2.new(ScreenSize.X - 100 + OffX, ScreenSize.Y - 80 + OffY)
        elseif Pos == "Top Left" then
            return Vector2.new(100 + OffX, 40 + OffY)
        elseif Pos == "Top Right" then
            return Vector2.new(ScreenSize.X - 100 + OffX, 40 + OffY)
        end

        return Vector2.new(ScreenSize.X / 2 + OffX, ScreenSize.Y - 80 + OffY)
    end

    local function FormatHealth(current: number, max: number): string
        local fmt = "%." .. HealthData.Settings.DecimalPlaces .. "f"
        local text = HealthData.Settings.Prefix

        if HealthData.Settings.ShowPercentage then
            local pct = max > 0 and (current / max * 100) or 0
            text = text .. string.format(fmt, pct) .. "%"
        elseif HealthData.Settings.ShowMaxHealth then
            text = text .. string.format(fmt, current) .. " / " .. string.format(fmt, max)
        else
            text = text .. string.format(fmt, current)
        end

        text = text .. HealthData.Settings.Suffix
        return text
    end

    local function HideAll()
        for _, d in next, AllDrawings do
            d.Visible = false
        end
    end

    local function Cleanup()
        HideAll()
        HealthData.Data.DisplayedHealth = 0
        HealthData.Data.PulsePhase = 0
        HealthData.Data.LastHealth = 0
    end

    local Health = Tabs.Render:CreateModule({
        Name = "Health",
        Flag = "UniversalHealth",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                HealthData.Data.DisplayedHealth = 0
                HealthData.Data.PulsePhase = 0

                self:Connection(RunService.RenderStepped:Connect(function(dt: number)
                    if not Bloomware:IsAlive(LocalPlayer) then
                        HideAll()
                        return
                    end

                    local Humanoid: Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if not Humanoid then
                        HideAll()
                        return
                    end

                    local CurrentHealth = LocalPlayer.Character:GetAttribute("Health") or Humanoid.Health
                    local MaxHealth = LocalPlayer.Character:GetAttribute("MaxHealth") or Humanoid.MaxHealth

                    if HealthData.Settings.AnimateChanges then
                        local speed = HealthData.Settings.AnimationSpeed
                        HealthData.Data.DisplayedHealth = HealthData.Data.DisplayedHealth + (CurrentHealth - HealthData.Data.DisplayedHealth) * math.min(dt * speed, 1)
                    else
                        HealthData.Data.DisplayedHealth = CurrentHealth
                    end

                    local DisplayHP = HealthData.Data.DisplayedHealth
                    local Percent = MaxHealth > 0 and (DisplayHP / MaxHealth * 100) or 0
                    local HealthColor = GetHealthColor(Percent)
                    local Position = GetPosition()
                    local Text = FormatHealth(DisplayHP, MaxHealth)

                    local PulseAlpha = 1
                    if HealthData.Settings.PulseOnLow and Percent <= HealthData.Settings.PulseThreshold then
                        HealthData.Data.PulsePhase = HealthData.Data.PulsePhase + dt * 4
                        PulseAlpha = 0.55 + 0.45 * math.abs(math.sin(HealthData.Data.PulsePhase))
                    else
                        HealthData.Data.PulsePhase = 0
                        PulseAlpha = 1
                    end

                    local Size = HealthData.Settings.TextSize

                    for _, d in next, AllDrawings do
                        d.Size = Size
                    end

                    if HealthData.Settings.ShadowEnabled then
                        local ShadowOff = HealthData.Settings.ShadowOffset
                        ShadowText.Text = Text
                        ShadowText.Position = Vector2.new(Position.X + ShadowOff, Position.Y + ShadowOff)
                        ShadowText.Transparency = 0.4 * PulseAlpha
                        ShadowText.Color = Color3.fromRGB(0, 0, 0)
                        ShadowText.Visible = true
                    else
                        ShadowText.Visible = false
                    end

                    if HealthData.Settings.GlowEnabled then
                        local Intensity = HealthData.Settings.GlowIntensity
                        local GlowAlpha = HealthData.Settings.GlowTransparency * PulseAlpha

                        GlowText1.Text = Text
                        GlowText1.Position = Vector2.new(Position.X - Intensity, Position.Y)
                        GlowText1.Color = HealthColor
                        GlowText1.Transparency = GlowAlpha
                        GlowText1.Visible = true

                        GlowText2.Text = Text
                        GlowText2.Position = Vector2.new(Position.X + Intensity, Position.Y)
                        GlowText2.Color = HealthColor
                        GlowText2.Transparency = GlowAlpha
                        GlowText2.Visible = true

                        GlowText3.Text = Text
                        GlowText3.Position = Vector2.new(Position.X, Position.Y - Intensity)
                        GlowText3.Color = HealthColor
                        GlowText3.Transparency = GlowAlpha
                        GlowText3.Visible = true

                        GlowText4.Text = Text
                        GlowText4.Position = Vector2.new(Position.X, Position.Y + Intensity)
                        GlowText4.Color = HealthColor
                        GlowText4.Transparency = GlowAlpha
                        GlowText4.Visible = true
                    else
                        GlowText1.Visible = false
                        GlowText2.Visible = false
                        GlowText3.Visible = false
                        GlowText4.Visible = false
                    end

                    HealthText.Text = Text
                    HealthText.Position = Position
                    HealthText.Color = HealthColor
                    HealthText.Outline = HealthData.Settings.OutlineEnabled
                    HealthText.Transparency = PulseAlpha
                    HealthText.Visible = true

                    HealthData.Data.LastHealth = CurrentHealth
                end))
            else
                Cleanup()
            end
        end
    })

    Health:Dropdown({
        Name = "Position",
        Flag = "HealthPosition",
        Default = "Bottom Center",
        Options = {"Bottom Center", "Top Center", "Center", "Bottom Left", "Bottom Right", "Top Left", "Top Right"},
        CallingFunction = function(self, value: string)
            HealthData.Settings.Position = value
        end
    })

    Health:Slider({
        Name = "Text Size",
        Flag = "HealthTextSize",
        Min = 16,
        Max = 80,
        Default = 42,
        CallingFunction = function(self, value: number)
            HealthData.Settings.TextSize = value
            for _, d in next, AllDrawings do
                d.Size = value
            end
        end
    })

    Health:Slider({
        Name = "Offset X",
        Flag = "HealthOffsetX",
        Min = -500,
        Max = 500,
        Default = 0,
        CallingFunction = function(self, value: number)
            HealthData.Settings.OffsetX = value
        end
    })

    Health:Slider({
        Name = "Offset Y",
        Flag = "HealthOffsetY",
        Min = -500,
        Max = 500,
        Default = -40,
        CallingFunction = function(self, value: number)
            HealthData.Settings.OffsetY = value
        end
    })

    Health:MiniToggle({
        Name = "Show Max Health",
        Flag = "HealthShowMax",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.ShowMaxHealth = value
        end
    })

    Health:MiniToggle({
        Name = "Show Percentage",
        Flag = "HealthShowPercent",
        Default = false,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.ShowPercentage = value
        end
    })

    Health:Slider({
        Name = "Decimal Places",
        Flag = "HealthDecimals",
        Min = 0,
        Max = 2,
        Default = 0,
        CallingFunction = function(self, value: number)
            HealthData.Settings.DecimalPlaces = value
        end
    })

    Health:MiniToggle({
        Name = "Glow Effect",
        Flag = "HealthGlow",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.GlowEnabled = value
        end
    })

    Health:Slider({
        Name = "Glow Intensity",
        Flag = "HealthGlowIntensity",
        Min = 1,
        Max = 15,
        Default = 6,
        CallingFunction = function(self, value: number)
            HealthData.Settings.GlowIntensity = value
        end
    })

    Health:Slider({
        Name = "Glow Transparency",
        Flag = "HealthGlowTransparency",
        Min = 10,
        Max = 90,
        Default = 65,
        CallingFunction = function(self, value: number)
            HealthData.Settings.GlowTransparency = value / 100
        end
    })

    Health:MiniToggle({
        Name = "Pulse On Low HP",
        Flag = "HealthPulse",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.PulseOnLow = value
        end
    })

    Health:Slider({
        Name = "Pulse Threshold %",
        Flag = "HealthPulseThreshold",
        Min = 5,
        Max = 50,
        Default = 25,
        CallingFunction = function(self, value: number)
            HealthData.Settings.PulseThreshold = value
        end
    })

    Health:MiniToggle({
        Name = "Text Outline",
        Flag = "HealthOutline",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.OutlineEnabled = value
        end
    })

    Health:MiniToggle({
        Name = "Shadow",
        Flag = "HealthShadow",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.ShadowEnabled = value
        end
    })

    Health:Slider({
        Name = "Shadow Offset",
        Flag = "HealthShadowOffset",
        Min = 1,
        Max = 6,
        Default = 2,
        CallingFunction = function(self, value: number)
            HealthData.Settings.ShadowOffset = value
        end
    })

    Health:MiniToggle({
        Name = "Animate Changes",
        Flag = "HealthAnimate",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthData.Settings.AnimateChanges = value
        end
    })

    Health:Slider({
        Name = "Animation Speed",
        Flag = "HealthAnimSpeed",
        Min = 1,
        Max = 20,
        Default = 8,
        CallingFunction = function(self, value: number)
            HealthData.Settings.AnimationSpeed = value
        end
    })

    Health:ColorSlider({
        Name = "Full HP Color",
        Flag = "HealthFullColor",
        Default = Color3.fromRGB(0, 255, 130),
        CallingFunction = function(self, value: Color3)
            HealthData.Settings.FullHealthColor = value
        end
    })

    Health:ColorSlider({
        Name = "Mid HP Color",
        Flag = "HealthMidColor",
        Default = Color3.fromRGB(255, 200, 0),
        CallingFunction = function(self, value: Color3)
            HealthData.Settings.MidHealthColor = value
        end
    })

    Health:ColorSlider({
        Name = "Low HP Color",
        Flag = "HealthLowColor",
        Default = Color3.fromRGB(255, 50, 50),
        CallingFunction = function(self, value: Color3)
            HealthData.Settings.LowHealthColor = value
        end
    })

    Health:ColorSlider({
        Name = "Critical HP Color",
        Flag = "HealthCritColor",
        Default = Color3.fromRGB(200, 0, 0),
        CallingFunction = function(self, value: Color3)
            HealthData.Settings.CriticalHealthColor = value
        end
    })
end)();
