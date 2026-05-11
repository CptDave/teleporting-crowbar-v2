include("shared.lua")

if CLIENT then
  net.Receive("TC_ClearMessage", function()
    chat.AddText(Color(221, 234, 79), "Saved teleportation spot has been cleared.")
    --surface.PlaySound("buttons/button15.wav")
  end)

  -- net.Receive("TC_Debug", function()
  --   chat.AddText(Color(221, 234, 79), "It Worked!")
  -- end)
end