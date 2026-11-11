
-- VoidLib Icons
-- Lucide icon collection

local Icons = {}

Icons.List = {
    Home = "rbxassetid://7733960981",
    Settings = "rbxassetid://7734053495",
    Search = "rbxassetid://7734052925",
    Image = "rbxassetid://7733964126",

    Alert = "rbxassetid://7733658504",
    Play = "rbxassetid://7734037784",
    Pause = "rbxassetid://7734021827",
    Close = "rbxassetid://7733765224",

    Volume = "rbxassetid://7743877250",
    Music = "rbxassetid://7734020554",
    Bell = "rbxassetid://7733675107",

    Eye = "rbxassetid://7733774602",
    Sliders = "rbxassetid://7734058803",
    Mouse = "rbxassetid://7743870392",
    User = "rbxassetid://7743875629",

    Star = "rbxassetid://7734068321",
    Download = "rbxassetid://7733770755",
    Save = "rbxassetid://7734052335",
    Info = "rbxassetid://7733956210"
}

function Icons:Get(name)
    return self.List[name]
end

function Icons:Add(name, imageId)
    self.List[name] = imageId
end

return Icons

