if getgenv().Bloomware then
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local cloneref = cloneref or function(Reference: Instance): Instance
    return Reference
end

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local Players: Players = cloneref(game:GetService("Players"))

local LocalPlayer: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera

local BaseGit: string = "https://github.com/null-wtf/Bloomware"
local BloomwareInit: {[any]: any} = getgenv().BloomwareInit or {}
local Bloomware = {
    Version = "3.17",
    BaseGit = BaseGit,
    Scale = 0.8,
    Keybind = Enum.KeyCode.RightShift,
    Game = game.PlaceId,
    Mobile = false,
    Init = BloomwareInit,
    Connections = {},
    CurrentConfig = {},
    IgnoreConfigs = {"8560631822", "8444591321"},
    OnUninject = Instance.new("BindableEvent"),
    FailedToLoad = false,
    Load = {
        Start = os.clock(),
        Time = 0,
        Loaded = false,
        LoadTips = {
            "Join our Discord discord.gg/PYVuXbZ7bV to chat, report bugs & give suggestions.",
            "Always use alts, moderators can ban you at any time!",
            "You can use LCTRL + scroll to zoom in & out.",
            "Modules not working properly? Try switching executors or reporting a bug here: discord discord.gg/PYVuXbZ7bV.",
            "Enjoy Bloomware — all included features are free.",
            "Losing to another script in a fair fight? Tell us its name in here discord.gg/PYVuXbZ7bV and we'll improve.",
            "Share Bloomware with your friends and send us feedback!",
            "Check out Bloomware updates in our community."
        }
    },
    Directories = {
        "Bloomware",
        "Bloomware/Configs",
        "Bloomware/Assets",
        "Bloomware/Assets/Fonts",
        "Bloomware/Assets/Icons"
    }
}

getgenv().Bloomware = Bloomware
table.insert(Bloomware.Directories, "Bloomware/Configs/"..tostring(Bloomware.Game))
for i,v: string in Bloomware.Directories do
    if not isfolder(v) then
        makefolder(v)
    end
end

for i,v in BloomwareInit do
    Bloomware[i] = v
end

if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
    Bloomware.Mobile = true
    if Camera then
        if 0.4 >= (Camera.ViewportSize.X / 1000) - 0.1 then
            Bloomware.Scale = 0.4
        else
            Bloomware.Scale = (Camera.ViewportSize.X / 1000) - 0.2
        end
    else
        Bloomware.Scale = 0.5
    end
end

local function DownloadAsset(DownloadPath: string, Path: string): boolean
    if writefile then
        local Suc: boolean, Resp: string = pcall(game.HttpGet, game, DownloadPath)
        if Suc and Resp then
            return pcall(writefile, Path, Resp)
        end
    end

    return false
end

local function DownloadDirectory(DirectoryLink: string, SavePath: string): boolean
    if writefile and makefolder and isfile and isfolder then
        if not isfolder(SavePath) then
            makefolder(SavePath)
        end

        local Suc: boolean, DirData: string = pcall(game.HttpGet, game, DirectoryLink)
        if Suc and DirData and typeof(DirData) == "string" then
            local Suc2: boolean, Body = pcall(HttpService.JSONDecode, HttpService, DirData)
            if Suc2 and typeof(Body) == "table" then
                for i,v in Body do
                    if v.type == "dir" and v.url then
                        if isfolder and not isfolder(`{SavePath}/{v.name}`) then
                            DownloadDirectory(v.url, `{SavePath}/{v.name}`)
                        else
							delfolder(`{SavePath}/{v.name}`)
							DownloadDirectory(v.url, `{SavePath}/{v.name}`)
						end
                    elseif v.type == "file" and v.download_url then
                        if not isfile(`{SavePath}/{v.name}`) then
                            DownloadAsset(v.download_url, `{SavePath}/{v.name}`)
                        end
                    end
                end

                return true
            end
        end
    end
    return false
end

DownloadDirectory("https://api.github.com/repos/null-wtf/Bloomware/contents/Assets", "Bloomware/Assets")
writefile("Bloomware/Assets/UpdatedIcons.txt", "")
if Bloomware.Dev and isfile("Bloomware/Library/Main.luau") then
    loadstring(readfile("Bloomware/Library/Main.luau"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/null-wtf/Bloomware/refs/heads/main/Library/Main.luau"))()
end

if not Bloomware.Assets or Bloomware.Assets and (not Bloomware.Assets.Connections or not Bloomware.Assets.Functions) then
    warn("Failed to load assets")
    getgenv().Bloomware = nil
    table.clear(Bloomware)

    return
end

Bloomware.Assets.Functions.DownloadDirectory = DownloadDirectory
Bloomware.Assets.Functions.DownloadAsset = DownloadAsset

Bloomware:LoadFile("Universal", false)
Bloomware:LoadFile(Bloomware.Game)

if queue_on_teleport then
    Bloomware.Assets.Connections:Add(LocalPlayer.OnTeleport:Connect(function(State: Enum.TeleportState)
        if State == Enum.TeleportState.InProgress then
            local Data = string.format("getgenv().BloomwareInit = {")
            local Wrote = false
            for i,v in Bloomware.Init do
				local Item: string = tostring(i).." = "..tostring(v)
				if typeof(v) == "string" then
					Item = tostring(i).." = '"..tostring(v) .. "'"
				end

                if Wrote then
                    Data = Data..", "..Item
                else
                    Data = Data..Item
                end

                Wrote = true
            end

            queue_on_teleport(Data .. [[}
                if BloomwareInit.Dev and isfile("Bloomware/Loader.luau") then
                    loadstring(readfile("Bloomware/Loader.luau"))()
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/null-wtf/Bloomware/refs/heads/main/Loader.luau"))()
                end
            ]])
        end
    end))
end

if isfile then
    local Updated: boolean = false
    if not isfile("Bloomware/Version.dat") then
        writefile("Bloomware/Version.dat", Bloomware.Version)
        Updated = true
    else
        if readfile then
            local UserVersion: string = readfile("Bloomware/Version.dat")
            if UserVersion ~= Bloomware.Version then
                writefile("Bloomware/Version.dat", Bloomware.Version)
                Updated = true
            end
        end
    end

    if Updated then
        local Keybind = Bloomware.Keybind
        if typeof(Keybind) == "EnumItem" then
            Keybind = Keybind.Name
        end

        task.delay(0.2, Bloomware.CreateNotification, Bloomware, {
            Title = "Updated to V"..Bloomware.Version,
            Description = string.format("Press %s to toggle the GUI", Keybind),
            Duration = 5
        })

        task.delay(0.3, Bloomware.CreateNotification, Bloomware, {
            Title = "Join our discord!",
            Description = "Join our discord: discord.gg/PYVuXbZ7bV",
            Duration = 5
        })

        setclipboard("discord.gg/PYVuXbZ7bV")
        for i = 1,2 do
            task.spawn(function()
                (request or http and http.request or function() end)({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        Origin = "https://discord.com"
                    },
                    Body = HttpService:JSONEncode({
                        nonce = HttpService:GenerateGUID(false),
                        args = {
                            invite = {code = "PYVuXbZ7bV"},
                            code = "PYVuXbZ7bV"
                        },
                        cmd = "INVITE_BROWSER"
                    })
                })
            end)
        end
    end
end

Bloomware.Load.Loaded = true
Bloomware.Load.Time = os.clock() - Bloomware.Load.Start
local LoadTime: string = string.format("%.1fs", Bloomware.Load.Time)
Bloomware:CreateNotification({
    Title = "Bloomware Loaded in " .. LoadTime,
    Description = Bloomware.Load.LoadTips[math.random(1, #Bloomware.Load.LoadTips)],
    Duration = 3
})
