local MaruLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/Setting/refs/heads/main/427daa95-6994-4738-805e-c1c4c5b577c7.txt"))()
local A = MaruLib:AddWindows()
local T1 = A:T({ Name = "Tab 1", })
local T2 = A:T({ Name = "Tab 2", })
local T3 = A:T({ Name = "Tab 3", })
local T4 = A:T({ Name = "Tab 4", })
local T5 = A:T({ Name = "Tab 5", })
local T6 = A:T({ Name = "Tab 6", })
local T7 = A:T({ Name = "Tab 7", })
local T8 = A:T({ Name = "Tab 8", })

local I = T1:AddSection("Left", {
    Name = ""
})

I:AddToggle({
    Name = "Toggle",
    Callback = function()

    end
})

I:AddButton({
  Name = "Button",
  Callback = function()

  end
})

I:AddSlider({
  Name = "Slider",
  Min = 1,
  Max = 100,
  Increase = 1,
  Default = 16,
  Callback = function(Value)

  end
})

I:AddDropdown({
  Name = "Dropdown",
  Options = {"one", "two", "three"},
  Default = "Dropdown",
  Flag = "Dropdown",
  Callback = function()

  end
})

local I1 = T1:AddSection("Right", {
    Name = "Status Server"
})