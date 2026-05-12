--[[
 /$$$$$$$$ /$$$$$$$$ /$$       /$$$$$$$$ /$$$$$$$   /$$$$$$  /$$$$$$$  /$$$$$$$$ /$$$$$$ /$$   /$$  /$$$$$$ 
|__  $$__/| $$_____/| $$      | $$_____/| $$__  $$ /$$__  $$| $$__  $$|__  $$__/|_  $$_/| $$$ | $$ /$$__  $$
   | $$   | $$      | $$      | $$      | $$  \ $$| $$  \ $$| $$  \ $$   | $$     | $$  | $$$$| $$| $$  \__/
   | $$   | $$$$$   | $$      | $$$$$   | $$$$$$$/| $$  | $$| $$$$$$$/   | $$     | $$  | $$ $$ $$| $$ /$$$$
   | $$   | $$__/   | $$      | $$__/   | $$____/ | $$  | $$| $$__  $$   | $$     | $$  | $$  $$$$| $$|_  $$
   | $$   | $$      | $$      | $$      | $$      | $$  | $$| $$  \ $$   | $$     | $$  | $$\  $$$| $$  \ $$
   | $$   | $$$$$$$$| $$$$$$$$| $$$$$$$$| $$      |  $$$$$$/| $$  | $$   | $$    /$$$$$$| $$ \  $$|  $$$$$$/
   |__/   |________/|________/|________/|__/       \______/ |__/  |__/   |__/   |______/|__/  \__/ \______/ 
                                                                                                            
                                                                                                            
                                                                                                            
  /$$$$$$  /$$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$   /$$$$$$  /$$$$$$$        /$$    /$$  /$$$$$$         
 /$$__  $$| $$__  $$ /$$__  $$| $$  /$ | $$| $$__  $$ /$$__  $$| $$__  $$      | $$   | $$ /$$__  $$        
| $$  \__/| $$  \ $$| $$  \ $$| $$ /$$$| $$| $$  \ $$| $$  \ $$| $$  \ $$      | $$   | $$|__/  \ $$        
| $$      | $$$$$$$/| $$  | $$| $$/$$ $$ $$| $$$$$$$ | $$$$$$$$| $$$$$$$/      |  $$ / $$/  /$$$$$$/        
| $$      | $$__  $$| $$  | $$| $$$$_  $$$$| $$__  $$| $$__  $$| $$__  $$       \  $$ $$/  /$$____/         
| $$    $$| $$  \ $$| $$  | $$| $$$/ \  $$$| $$  \ $$| $$  | $$| $$  \ $$        \  $$$/  | $$              
|  $$$$$$/| $$  | $$|  $$$$$$/| $$/   \  $$| $$$$$$$/| $$  | $$| $$  | $$         \  $/   | $$$$$$$$        
 \______/ |__/  |__/ \______/ |__/     \__/|_______/ |__/  |__/|__/  |__/          \_/    |________/        
                        
 File: shared.lua
 Author: Cpt. Dave
 License: MIT

 This project is a successor to my original teleporting crowbar made 13 years ago. V2 has
 many improvments such as better placement when teleporting(not getting stuck in walls)
 and visuals when developer 1 and tcenabledebug 1 is enabled in the console.
                            
 Enjoy!
                                                      
--]]

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "weapon_base"
SWEP.PrintName = "Teleporting Crowbar V2"
SWEP.Author = "Cpt. Dave"
SWEP.Contact = "Steam Workshop"
SWEP.Purpose = "Fast Teleporting and Fun"
SWEP.Instructions = ""
SWEP.ViewModel 	= "models/weapons/v_crowbar.mdl" 
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" 
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 62

if CLIENT then
  SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_teleporting_crowbar_v2_icon.vmt")
end

SWEP.Category = "Teleportation"
SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ShootSound = "WeaponFrag.Throw"
SWEP.Direction = {
  Vector( 1,  0,  0),
  Vector(-1,  0,  0),
  Vector( 0,  1,  0),
  Vector( 0, -1,  0),
}
SWEP.YawRotate = Angle(0, 45, 0)
SWEP.Mute = false 
SWEP.SaveSpot = nil
SWEP.Debug = false

function SWEP:InitialCheckTarget( hit_pos, hullmin, hullmax, owner)
  if self.Debug then print("Starting Initial Check Target.") end
  
  local tr = util.TraceHull({
    start = hit_pos,
    endpos = hit_pos,
    filter = owner,
    mins = hullmin,
    maxs = hullmax,
    mask = MASK_PLAYERSOLID
  })

  if not tr.Hit then
    if self.Debug then
      print("First Initial hit is good! Returning: " .. tostring(hit_pos))
      debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(0, 255, 0, 100))
    end
    return hit_pos
  else
    --debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(245, 34, 34, 193))
    for i = 1, 5 do
      local tr2 = util.TraceHull({
        start = hit_pos + Vector(0, 0, i),
        endpos = hit_pos + Vector(0, 0, i),
        filter = owner,
        mins = hullmin,
        maxs = hullmax,
        mask = MASK_PLAYERSOLID
      })

      if not tr2.Hit then
        if self.Debug then
          print("Found the position in our init extra function. Loops: " .. tostring(i))
          print("Returning: " .. tostring(tr2.HitPos))
          debugoverlay.Box(tr2.HitPos, hullmin, hullmax, 2, Color(0, 255, 0, 100))
        end
        return tr2.HitPos
      end
    end

    if self.Debug then
      print("Could not find position in Initial Check.")
    end
    
    return nil
  end
end

function SWEP:CheckVerticalSpot( hit_pos, hullmin, hullmax, owner )
  if self.Debug then print("STARTING CheckVerticalSpot function.") end

  local midTopHull = hullmin + hullmax
  
  hit_pos = hit_pos + Vector(0, 0, 2) --we check 1-5 in the init func, so start at 6

  local leep = 4
  for i = 1, 12 do
    local tr = util.TraceHull({
      start = hit_pos + Vector(0, 0, i * leep),
      endpos = hit_pos + Vector(0, 0, i * leep),
      mins = hullmin,
      maxs = hullmax,
      filter = owner,
      mask = MASK_PLAYERSOLID
    })

    if not tr.Hit then
      if self.Debug then
        print("A position in Vert hsa been found.")
        print("Returning: " .. tostring(tr.HitPos))

        print("Vert Loops: " .. tostring(i))
        debugoverlay.Box(tr.HitPos, hullmin, hullmax, 2, Color(0, 255, 0, 100))
      end

      return tr.HitPos
    end

  end

  if self.Debug then
    print("Could not find position in Vert. Returning nil.")
  end
  
  return nil

end

function SWEP:CheckVerticalSpotDuck( hit_pos, owner ) 

  if self.Debug then print("STARTING CheckVerticalSpotDuck function.") end
  
  local hullmin, hullmax = owner:GetHullDuck()

  --trace our crouched hall to the target location
  local init_hull = util.TraceHull({
    start = hit_pos,
    endpos = hit_pos,
    mins = hullmin,
    maxs = hullmax,
    filter = owner,
    mask = MASK_PLAYERSOLID
  })
  
  if not init_hull.Hit then
    if self.Debug then 
      print("A position was found in Vertical Duck. Returning: " .. tostring(hit_pos)) 
      debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(0, 255, 0, 120)) 
    end
    return hit_pos
  end

  for i = 1, 10 do
    local tr2 = util.TraceHull({
      start = hit_pos + Vector(0, 0, i),
      endpos = hit_pos + Vector(0, 0, i),
      mins = hullmin,
      maxs = hullmax,
      filter = owner,
      mask = MASK_PLAYERSOLID
    })

    if not tr2.Hit then
      if self.Debug then
        print("Found the position in our Vert Duck extra function. Loops: " .. tostring(i))
        print("Returning: " .. tostring(tr2.HitPos))
        --debugoverlay.Box(tr2.HitPos, hullmin, hullmax, 2, Color(0, 255, 0, 100))
      end
      return tr2.HitPos
    end

    if self.Debug then
      print("The init position in Vertical Duck could not be found.") 
      --debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(255, 0, 0, 146))
    end

    return nil
  end
end

function SWEP:CheckSpotWithMulitpleOrigins(hit_pos, hullmin, hullmax, width, owner)
  if self.Debug then print("Starting CheckSpotWithMulitpleOrigins.") end

  local center = (hullmin + hullmax) / 2

  local origins = {
    center,
    Vector(0, 0, 0),
    Vector(0, 0, hullmax.z),
    center
  }

  for i = 1, 4 do
    local origin = origins[i]

    if self.Debug then
      print("In for loop, i = ", i, " and origin = ", origin)
    end

    local new_direction = Vector(0, 0, 0)

    for ii, dirr in ipairs(self.Direction) do
      local dir = Vector(dirr)
      if i == 4 then
        dir:Rotate(self.YawRotate)
      end
      local len = width
      if i == 4 then len = width * math.sqrt(2) end

      local tr = util.TraceLine({
        start = hit_pos + origin,
        endpos = (hit_pos + origin) + dir * len,
        filter = owner,
        mask = MASK_PLAYERSOLID
      })

      if self.Debug then
        print(self.Direction[ii], tr.Hit)
        debugoverlay.Line(hit_pos + origin, (hit_pos + origin) + dir * len, 2, Color(255, 255, 255), true)
      end

      if (tr.Hit) then
        new_direction = new_direction + dir
      end

    end

    if self.Debug then
      print("new Direction = ", new_direction)
    end

    if new_direction ~= Vector(0, 0, 0) then

      local max_loops = 10
      local extra_distance = 8

      new_direction:Mul(-1)
      if self.Debug then
        print("Flip Directionection: ", new_direction)
      end
      
      local loop_count = 1

      repeat
        local tr2 = util.TraceHull( {
          start = hit_pos + new_direction * (loop_count * extra_distance),
          endpos = hit_pos + new_direction * (loop_count * extra_distance),
          filter = owner,
          mins = hullmin,
          maxs = hullmax,
          mask = MASK_PLAYERSOLID
        } )

        if tr2.Hit then
          --==RECOVERY FAILED==--
          if self.Debug then
            print("New position failed, Attempt:  ", loop_count )
            --debugoverlay.Box(hit_pos + new_direction * (loop_count * extra_distance), hullmin, hullmax, 2, Color(232, 251, 25))
          end
        else
          --==RECOVER SUCCESS==--
          if self.Debug then
            print("New position successful! Attempt: ", loop_count)
            print("Found a position in CheckSpotWithMultipleOrigins.")
            print("Returning position: ", hit_pos + new_direction * (loop_count * extra_distance))
            debugoverlay.Box(hit_pos + new_direction * (loop_count * extra_distance), Vector(-16,-16,0), Vector(16,16,72), 2, Color(0, 255, 0, 100))
          end

          return hit_pos + new_direction * (loop_count * extra_distance)
        end

        loop_count = loop_count + 1

        if loop_count > max_loops then
          --print("Nothing found in this Direction.")
          debugoverlay.Box(hit_pos + new_direction * (loop_count * extra_distance), Vector(-16,-16,0), Vector(16,16,72), 2, Color(255, 255, 255, 107))
        end
      until (not tr2.Hit or loop_count > max_loops)
    end
  end
  if self.Debug then print("No position found returning nil.") end
  return nil 
end

function SWEP:AdjustBasedOnNormals(hitpos, normal, width, height)
  local hit_pos = hitpos
  local magic_number = 4

  if normal.z < -0.80 and normal.z >= -1 then 
    hit_pos.z = hit_pos.z - height 
  end

  if normal.z > 0.80 and normal.z < 0.99 then 
    hit_pos.z = hit_pos.z + (normal.z * magic_number) 
  end

  if normal.x > 0.10 or normal.x < -0.10 then
    hit_pos.x = hit_pos.x + normal.x * width
  end

  if normal.y > 0.10 or normal.y < -0.10 then
    hit_pos.y = hit_pos.y + normal.y * width
  end

  if normal.z < 0.10 and normal.z > -0.10 then
    local temp_pos = hit_pos

    local check_floor = util.TraceLine({
      start = temp_pos,
      endpos = temp_pos - Vector(0, 0, height),
      mask = MASK_PLAYERSOLID
    })

    if check_floor.Fraction == 1 then
      temp_pos.z = temp_pos.z - height
    else
      temp_pos = check_floor.HitPos + Vector(0, 0, 1)
    end

    hit_pos = temp_pos
  end 
  
  return hit_pos
end

function SWEP:TeleportPlayer( owner, pos )
  owner:SetVelocity(owner:GetVelocity() * -1) --negate fall damage
  owner:SetPos(pos)

  if SERVER then
    if not self.Mute and IsFirstTimePredicted() then 
      owner:EmitSound( self.ShootSound, 80, 100, 1, CHAN_WEAPON ) 
    end
  end
  
end

function SWEP:Initialize()
  self:SetHoldType( "melee" )

  concommand.Add("tcenabledebug", 
    function(ply, cmd, args, argStr)
      if not IsValid(ply) then return end
      local arg = args[1]

      if arg == "1" or arg == "true" then
        self.Debug = true
        ply:ChatPrint("Debug mode ENABLED")
        
      elseif arg == "0" or arg == "false" then
        self.Debug = false
        ply:ChatPrint("Debug mode DISABLED")
      end
    end, 
    function(cmd, argStr)
      return { "0", "1", "true", "false" }
    end, 
    "Enable or disable debug mode."
  )

  concommand.Add(
    "tcmute", 
    function(ply, cmd, args, argStr)
      if not IsValid(ply) or not ply:IsPlayer() then return end
      local arg = args[1]
      if arg == "1" or arg == "true" then
        ply:ChatPrint("Teleporting crowbar sound disabled.")
        self.Mute = true 
      end
      if arg == "0" or arg == "false" then
        ply:ChatPrint("Teleporting crowbar sound enabled.")
        self.Mute = false 
      end
    end, 
    function(cmd, argStr)
      return { "0", "1", "true", "false" }
    end,
    "Mutes or unmute the sound when teleporting."
  )

  concommand.Add("tcclear", 
    function(ply, cmd, args, argStr)
      if not IsValid(ply) or not ply:IsPlayer() then return end
      self.SaveSpot = nil
      ply:ChatPrint("Saved teleportation spot has been cleared.")
    end, 
    nil, 
    "Clears saved teleport spot."
  )

end

function SWEP:PrimaryAttack() 

  local owner = self:GetOwner()
  if not IsValid(owner) or not owner:IsPlayer() then return end
  
  if not SERVER then return end

  local eye_trace = owner:GetEyeTraceNoCursor()
  local hullmin, hullmax = owner:GetHull()
  local height = hullmax.z
  local width = hullmax.x

  if not eye_trace.Hit then return end

  local hit_pos = eye_trace.HitPos
  local normal = eye_trace.HitNormal

  if self.Debug then
    print(string.format("Normal x: %.4f y: %.4f z: %.4f", normal.x, normal.y, normal.z))
  end

  hit_pos = self:AdjustBasedOnNormals(hit_pos, normal, width, height)

  local initial_check = self:InitialCheckTarget(hit_pos, hullmin, hullmax, owner)

  if initial_check then
    self:TeleportPlayer(owner, initial_check)
    return
  end

  local vertical_duck = self:CheckVerticalSpotDuck(hit_pos, owner)

  if vertical_duck then
    --Could we improve this??
    if owner:Crouching() then
      self:TeleportPlayer(owner, vertical_duck)
      return
    end

    owner:ConCommand("+duck")

    timer.Simple(0.2, function()
      self:TeleportPlayer(owner, vertical_duck)
    end)

    timer.Simple(0.2, function()
      owner:ConCommand("-duck")
    end)
    
    return
  end

  local vertical = self:CheckVerticalSpot(hit_pos, hullmin, hullmax, owner)

  if vertical then
    self:TeleportPlayer(owner, vertical)
    return
  end

  local horizontal = self:CheckSpotWithMulitpleOrigins(hit_pos, hullmin, hullmax, width, owner)

  if horizontal then
    self:TeleportPlayer(owner, horizontal)
    return
  end
end

function SWEP:SecondaryAttack()
  --if not IsFirstTimePredicted() then return end

  if not SERVER then return end

  local owner = self:GetOwner()
  if not IsValid(owner) or not owner:IsPlayer() then return end

  if self.SaveSpot then 
    self:TeleportPlayer(owner, self.SaveSpot)
    return
  end

  local eye_trace = owner:GetEyeTraceNoCursor()
  if not eye_trace.Hit then return end
  self.SaveSpot = eye_trace.HitPos
  owner:ChatPrint("Saved Location.")

end