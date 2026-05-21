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
    -- Do some vertical micro adjustments to check for valid position
    local below = util.TraceLine({
      start = hit_pos,
      endpos = hit_pos - hullmax,
      filter = owner,
      mask = MASK_PLAYERSOLID
    })

    if not below.Hit then
      for i = 1, 10 do
        local check_position = hit_pos + Vector(0, 0, -i)
        local tr2 = util.TraceHull({
          start = check_position,
          endpos = check_position,
          filter = owner,
          mins = hullmin,
          maxs = hullmax,
          mask = MASK_PLAYERSOLID
        })

        if not tr2.Hit then
          if self.Debug then
            print("Found the position in our init extra function. Loops: " .. tostring(i))
            print("Returning: " .. tostring(check_position))
            debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(0, 255, 0, 100))
          end
          return check_position
        end
      end
    end

    for ii = 1, 10 do
      local check_position = hit_pos + Vector(0, 0, ii)
      local tr3 = util.TraceHull({
          start = check_position,
          endpos = check_position,
          filter = owner,
          mins = hullmin,
          maxs = hullmax,
          mask = MASK_PLAYERSOLID
      })

      if not tr3.Hit then
        if self.Debug then
          print("Found the position in our init extra function. Loops: " .. tostring(ii))
          print("Returning: " .. tostring(check_position))
          debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(0, 255, 0, 100))
        end
        return check_position
      end
    end


    if self.Debug then
      print("Could not find position in Initial Check.")
      debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(191, 191, 191, 100))
    end

    return nil
  end
end

function SWEP:CheckVerticalSpot( hit_pos, hullmin, hullmax, owner )
  if self.Debug then print("STARTING CheckVerticalSpot function.") end

  local midTopHull = hullmin + hullmax

  hit_pos = hit_pos + Vector(0, 0, 10)

  local leep = 4
  for i = 1, 12 do
    local check_position = hit_pos + Vector(0, 0, i * leep)
    local tr = util.TraceHull({
      start = check_position,
      endpos = check_position,
      mins = hullmin,
      maxs = hullmax,
      filter = owner,
      mask = MASK_PLAYERSOLID
    })

    if not tr.Hit then
      if self.Debug then
        print("A position in Vert hsa been found.")
        print("Returning: " .. tostring(check_position))
        print("Vert Loops: " .. tostring(i))
        debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(0, 255, 0, 100))
      end

      return check_position
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
    local check_position = hit_pos + Vector(0, 0, i)
    local tr2 = util.TraceHull({
      start = check_position,
      endpos = check_position,
      mins = hullmin,
      maxs = hullmax,
      filter = owner,
      mask = MASK_PLAYERSOLID
    })

    if not tr2.Hit then
      if self.Debug then
        print("Found the position in our Vert Duck extra function. Loops: " .. tostring(i))
        print("Returning: " .. tostring(check_position))
        debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(0, 255, 0, 100))
      end
      return check_position
    end
  end

  if self.Debug then
    print("The init position in Vertical Duck could not be found.")
    --debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(106, 106, 106, 100))
  end

  return nil
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

  for i = 1, #origins do
    local origin = origins[i]

    if self.Debug then
      print("In for loop, i = ", i, " and origin = ", origin)
    end

    local new_direction = Vector(0, 0, 0)

    for ii, dirr in ipairs(self.Direction) do
      local dir = Vector(dirr)
      local len = width
      if i == 4 then
        dir:Rotate(self.YawRotate)
        len = width * math.sqrt(2)
      end

      local tr = util.TraceLine({
        start = hit_pos + origin,
        endpos = (hit_pos + origin) + dir * len,
        filter = owner,
        mask = MASK_PLAYERSOLID
      })

      if self.Debug then
        print(self.Direction[ii], tr.Hit)
      end

      if tr.Hit then
        new_direction = new_direction + dir
      end

    end

    if self.Debug then
      print("new Direction = ", new_direction)
    end

    if new_direction ~= Vector(0, 0, 0) then
      if self.Debug then
        print("Flip Directionection: ", new_direction)
      end

      local max_loops = 10
      local extra_distance = 2
      local loop_count = 1

      new_direction:Mul(-1)

      repeat
        local check_position = hit_pos + new_direction * (loop_count * extra_distance)
        local tr2 = util.TraceHull( {
          start = check_position,
          endpos = check_position,
          filter = owner,
          mins = hullmin,
          maxs = hullmax,
          mask = MASK_PLAYERSOLID
        } )

        if tr2.Hit then
          if self.Debug then
            print("New position failed, Attempt:  ", loop_count )
          end
        else
          if self.Debug then
            print("New position successful! Attempt: ", loop_count)
            print("Found a position in CheckSpotWithMultipleOrigins.")
            print("Returning position: ", check_position)
            debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(0, 255, 0, 100))
          end

          return check_position
        end

        loop_count = loop_count + 1
      until (loop_count > max_loops)
      --until (not tr2.Hit or loop_count > max_loops)
    end
  end

  if self.Debug then print("No position found returning nil.") end
  return nil
end

function SWEP:CheckFromBorders(hit_pos, hullmin, hullmax, width, owner)
  if self.Debug then
    print("STARTING CheckFromBorders function.")
  end

  local origins = {
    (hullmin + hullmax) / 2,
    Vector(0, 0, 0),
    Vector(0, 0, hullmax.z),
  }

  local border_positions = {
    Vector(width, 0, 0),
    Vector(-width, 0, 0),
    Vector(0, width, 0),
    Vector(0, -width, 0)
  }

  for i = 1, #origins do
    if self.Debug then
      print("Looping origins: " .. tostring(i) .. ", Value = " .. tostring(origins[i]))
    end

    local traces = {}

    for y = 1, #border_positions do
      table.insert(traces, util.TraceLine({
        start = hit_pos + origins[i] + border_positions[y],
        endpos = hit_pos + origins[i] - border_positions[y],
        filter = owner,
        mask = MASK_PLAYERSOLID
      }))
    end

    if self.Debug then
      print("Printing values in 'Traces':")
      for tt = 1, #traces do
        print("Traces start position: " .. tostring(traces[tt].StartPos))
        print("Traces ending position: " .. tostring(traces[tt].HitPos))
        print("Difference: " .. tostring(traces[tt].StartPos - traces[tt].HitPos))
        print("Normal: " .. tostring(traces[tt].HitNormal))
        print("")
      end
    end

    local valids = {}

    for x = 1, #traces do
      if not traces[x].StartSolid then
        table.insert(valids, traces[x])
      end
    end

    if self.Debug then
      print("Printing traces that did not start in a Solid:")
      for vv = 1, #valids do
        print("Traces start position: " .. tostring(valids[vv].StartPos))
        print("Traces ending position: " .. tostring(valids[vv].HitPos))
        print("Difference: " .. tostring(valids[vv].StartPos - valids[vv].HitPos))
        print("")
      end
    end

    local normals = {}

    if not table.IsEmpty(valids) then
      for z = 1, #valids do
        if valids[z].Hit then
          table.insert(normals, valids[z].HitNormal)
        end
      end
    end

    if self.Debug then
      print("Printing values in normal:")
      for n = 1, #normals do
        print("Normal: " .. tostring(normals[n]))
      end
    end

    local final_direction = Vector(0, 0, 0)

    if not table.IsEmpty(normals) then
      for v = 1, #normals do
        final_direction = final_direction + normals[v]
      end

      if self.Debug then
        print("Printing Final Direction: " .. tostring(final_direction))
      end

      final_direction:Normalize()
    end

    if final_direction ~= Vector(0, 0, 0) then
      local leep = 8
      for f = 1, 10 do
        local check_position = hit_pos + final_direction * (f * leep)

        local hull_check = util.TraceHull({
          start = check_position,
          endpos = check_position,
          mins = hullmin,
          maxs = hullmax,
          filter = owner,
          mask = MASK_PLAYERSOLID
        })

        if not hull_check.Hit then
          if self.Debug then
            print("Found a position in Check From Borders: " .. tostring(check_position))
            debugoverlay.Box(check_position, hullmin, hullmax, 2, Color(00, 255, 000, 100))
          end
          return check_position
        end
      end
    end
  end

  if self.Debug then
    print("Could not find a position in Check From Borders")
  end
  
  return nil
end

function SWEP:AdjustBasedOnNormals(hitpos, normal, width, height)
  local hit_pos = hitpos
  local magic_number = 4
  local radius = math.abs(width * normal.x) +
                 math.abs(width * normal.y) +
                 math.abs(height/2 * normal.z)
  -- Ceiling and Floor
  if math.abs(normal.z) > 0.80 then
    local safeCenter = hit_pos + normal * (radius + 2)
    hit_pos = safeCenter - Vector(0, 0, height/2)
  end

  -- Walls
  if math.abs(normal.x) > 0.10 then
    hit_pos.x = hit_pos.x + normal.x * (radius + 2)
    --print("Radius of x: " .. tostring(radius))
  end

  if math.abs(normal.y) > 0.10 then
    hit_pos.y = hit_pos.y + normal.y * (radius + 2)
    --print("Radius of y: " .. tostring(radius))
  end

  -- Detect position on wall that is near the floor
  if math.abs(normal.z) < 0.20 then
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
      if not ply:IsAdmin() then
        ply:ChatPrint("Only admins can use this command.")
        return
      end

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

  local border = self:CheckFromBorders(hit_pos, hullmin, hullmax, width, owner)

  if border then
    self:TeleportPlayer(owner, border)
    return
  end

  if self.Debug then
    print("Could not find a position to teleport to.")
    debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(252 ,33, 33, 126))
  end
end

function SWEP:SecondaryAttack()
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