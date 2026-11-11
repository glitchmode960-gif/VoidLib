
--[[
    VoidLib
    Icons Library
    Version 1.0
]]

local Icons = {}

Icons.List = {
    Home = "rbxassetid://0",
    Settings = "rbxassetid://0",
    User = "rbxassetid://0",
    Search = "rbxassetid://0",

    Visuals = "rbxassetid://0",
    Misc = "rbxassetid://0",

    Play = "rbxassetid://0",
    Pause = "rbxassetid://0",
    Close = "rbxassetid://0",

    Check = "rbxassetid://0",
    Menu = "rbxassetid://0",
    Info = "rbxassetid://0",
    Warning = "rbxassetid://0",

    Volume = "rbxassetid://0",
    Music = "rbxassetid://0",
    Bell = "rbxassetid://0"
}

function Icons:Get(name)
    return self.List[name]
end

function Icons:Add(name, imageId)
    self.List[name] = imageId
end

return Icons
