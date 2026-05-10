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
 and visuals when developer 1 is enabled in the console.
                                                      
 Enjoy!
                                                                                                            
--]]


AddCSLuaFile()

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
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_teleporting_crowbar_v2")
end

SWEP.Category = "Teleportation"
SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.ShootSound = Sound( "WeaponFrag.Throw" )
SWEP.dir = {
    Vector( 1,  0,  0),
    Vector(-1,  0,  0),
    Vector( 0,  1,  0),
    Vector( 0, -1,  0),

}
SWEP.Mute = false 
SWEP.SaveSpot = nil
SWEP.Debug = true

local function MuteAutoComplete()
    return {
        "0",
        "1"
    }
end

function SWEP:CheckVerticalSpot( hit_pos, hullmin, hullmax )
    if self.Debug then print("STARTING CheckVerticalSpot function.") end
    --==HERE WE TRY A TO FIX EDGE CASE WHEN WE CLICK A WALL VERY LOW TO THE FLOOR==--

    --Trace from the center top of the hull and point directly down
    local midTopHull = (hullmin + hullmax) / 2
    midTopHull.z = midTopHull.z * 2
    
    --Make a line trace from the top to the bottom of hull
    --if Hit is true we can try to bring the hull up on +z
    local check_line = util.TraceLine({
        start = hit_pos + midTopHull,
        endpos = hit_pos - midTopHull,
        filter = owner,
        mask = MASK_PLAYERSOLID
    })

    if self.Debug then
        debugoverlay.Line(hit_pos + midTopHull, hit_pos, 2, Color(255, 255, 255), true)
    end
    

    if check_line.Hit then 
        if self.Debug then
            print("The line check Hit = true")
        end
        

        local try_count = 12
        local leep = 8
        for i = 1, try_count do
            local trTop2 = util.TraceHull( {
                start = hit_pos + Vector(0, 0, 1) * (i * leep),
                endpos = hit_pos + Vector(0, 0, 1) * (i * leep),
                filter = self:GetOwner(),
                mins = hullmin,
                maxs = hullmax,
                mask = MASK_PLAYERSOLID
            } )

            --if Hit is false then we know that position is good to teleport to and we can exit loop early
            if not trTop2.Hit then
                if self.Debug then
                    print("Success, attempt: ", i)
                    print("Returning position: ", hit_pos + Vector(0, 0, 1) * (i * leep))
                    debugoverlay.Box(hit_pos + Vector(0, 0, 1) * (i * leep), hullmin, hullmax, 2, Color(0, 255, 0, 100))
                end
                
                
                --self:TeleportPlayer(owner, hit_pos + midTopHull + Vector(0, 0, 1) * (i * leep))
                return hit_pos + midTopHull + Vector(0, 0, 1) * (i * leep)
            end

            --If Hit is false we know the position is bad and we will continue looping unitl 
            if trTop2.Hit then
                if self.Debug then
                    print("Failed, attempt: ", i)

                    if i == try_count then 
                        debugoverlay.Box(hit_pos + Vector(0, 0, 1) * (i * leep), hullmin, hullmax, 2, Color(255, 255, 255, 154))
                        print("No position found in CheckVerticalSpot, returning nil.")
                    end
                end
            end

        end

        return nil
    else
        if self.Debug then
            print("Line check Hit = false")
        end
        
    end

    
    --==END EDGE CASE==--
end

function SWEP:CheckVerticalSpotDuck( hit_pos, owner ) 
    --IDEA
    --maybe have a raycast check above to really check if we need to crouch?

    if self.Debug then print("STARTING CheckVerticalSpotDuck function.") end
    --==HERE WE TRY A TO FIX EDGE CASE WHEN WE CLICK A WALL VERY LOW TO THE FLOOR==--

    --Trace from the center top of the hull and point directly down
    --local midTopHull = (hullmin + hullmax) / 2
    --midTopHull.z = midTopHull.z * 2
    
    local hullmin, hullmax = owner:GetHullDuck()
    local midTopHull = hullmin + hullmax

    --Make a line trace from the top to the bottom of hull
    --if Hit is true we can try to bring the hull up on +z
    local check_line = util.TraceLine({
        start = hit_pos + midTopHull,
        endpos = hit_pos - midTopHull,
        filter = owner,
        mask = MASK_PLAYERSOLID
    })

    if self.Debug then
        debugoverlay.Line(hit_pos + midTopHull, hit_pos, 2, Color(23, 95, 248), true)
    end
    

    if check_line.Hit then 
        if self.Debug then
            print("The line check Hit = true")
        end
        

        local try_count = 4
        local leep = 4
        for i = 1, try_count do
            local trTop2 = util.TraceHull( {
                start = hit_pos + Vector(0, 0, 1) * (i * leep),
                endpos = hit_pos + Vector(0, 0, 1) * (i * leep),
                filter = self:GetOwner(),
                mins = hullmin,
                maxs = hullmax,
                mask = MASK_PLAYERSOLID
            } )

            --if Hit is false then we know that position is good to teleport to and we can exit loop early
            if not trTop2.Hit then
                if self.Debug then
                    print("Success, attempt: ", i)
                    print("Returning position: ", hit_pos + Vector(0, 0, 1) * (i * leep))
                    debugoverlay.Box(hit_pos + Vector(0, 0, 1) * (i * leep), hullmin, hullmax, 2, Color(0, 255, 0, 100))
                end
                
                
                --self:TeleportPlayer(owner, hit_pos + midTopHull + Vector(0, 0, 1) * (i * leep))
                return hit_pos + Vector(0, 0, 1) * (i * leep)
            end

            --If Hit is false we know the position is bad and we will continue looping unitl 
            if trTop2.Hit then
                if self.Debug then
                    print("Failed, attempt: ", i)

                    if i == try_count then 
                        debugoverlay.Box(hit_pos + Vector(0, 0, 1) * (i * leep), hullmin, hullmax, 2, Color(255, 255, 255, 154))
                        print("No position found in CheckVerticalSpotDuck, returning nil.")
                    end
                end
            end

        end

        return nil
    else
        if self.Debug then
            print("Line check Hit = false")
        end
        
    end

    
    --==END EDGE CASE==--
end

function SWEP:CheckSpotWithMulitpleOrigins(hit_pos, hullmin, hullmax, height)
    if self.Debug then print("Starting CheckSpotWithMulitpleOrigins.") end

    for i = 1, 3 do
        local origin
        if i == 1 then origin = (hullmin + hullmax) / 2 end -- Middle
        if i == 2 then origin = Vector(0, 0, 0) end -- Bottom
        if i == 3 then origin = Vector(0, 0, hullmax.z) end --Top
        --if i == 4 then origin = (hullmin + hullmax) / 2 end -- same as middle but we need to rotate the vectors in dir by 45

        if self.Debug then
            print("In for loop, i = ", i, " and origin = ", origin)
        end

        local new_dir = Vector(0, 0, 0)

        for ii, direction in ipairs(self.dir) do
            local len = 16
            if direction.z ~= 0 then len = height / 2 end --Drawing line for height cant be 16 so height/2
            local tr = util.TraceLine({
                start = hit_pos + origin,
                endpos = (hit_pos + origin) + direction * len,
                filter = owner,
                mask = MASK_PLAYERSOLID
            })

            if self.Debug then
                print(self.dir[ii], tr.Hit)
                debugoverlay.Line(hit_pos + origin, (hit_pos + origin) + direction * len, 2, Color(0, 0, 0), true)
            end

            if (tr.Hit) then
                new_dir = new_dir + direction
            end

        end

        if self.Debug then
            print("new direction = ", new_dir)
        end

        if new_dir ~= Vector(0, 0, 0) then -- If we hit something on +x and -x then x becomes 0, same for y

            local max_loops = 10
            local extra_distance = 8

            new_dir:Mul(-1)
            if self.Debug then
                print("Flip Direction: ", new_dir)
            end
            
            local loop_count = 1
            repeat

                local tr2 = util.TraceHull( {
                    start = hit_pos + new_dir * (loop_count * extra_distance),
                    endpos = hit_pos + new_dir * (loop_count * extra_distance),
                    filter = self:GetOwner(),
                    mins = hullmin,
                    maxs = hullmax,
                    mask = MASK_PLAYERSOLID
                } )
                if tr2.Hit then
                    --==RECOVERY FAILED==--
                    if self.Debug then
                        print("New position failed, Attempt:  ", loop_count )
                        --debugoverlay.Box(hit_pos + new_dir * (loop_count * extra_distance), hullmin, hullmax, 2, Color(232, 251, 25))
                    end
                    
                    
                else
                    --==RECOVER SUCCESS==--
                    if self.Debug then
                        print("New position successful! Attempt: ", loop_count)
                        print("Found a position in CheckSpotWithMultipleOrigins.")
                        print("Returning position: ", hit_pos + new_dir * (loop_count * extra_distance))
                        debugoverlay.Box(hit_pos + new_dir * (loop_count * extra_distance), Vector(-16,-16,0), Vector(16,16,72), 2, Color(0, 255, 0, 100))
                    end
                    return hit_pos + new_dir * (loop_count * extra_distance)
                    

                    --self:TeleportPlayer( owner, hit_pos + new_dir * (loop_count * extra_distance))
                end

                loop_count = loop_count + 1

                if loop_count > max_loops then
                    print("Nothing found in this direction.")
                    debugoverlay.Box(hit_pos + new_dir * (loop_count * extra_distance), Vector(-16,-16,0), Vector(16,16,72), 2, Color(255, 255, 255, 107))
                end
            until (not tr2.Hit or loop_count > max_loops)
            --silent fail
        end
        
    end
    if self.Debug then print("No position found returning nil.") end
    return nil 
end

function SWEP:AdjustBasedOnNormals(hitpos, normal, width, height)
    local hit_pos = hitpos
    if normal.z < -0.80 and normal.z >= -1 then hit_pos.z = hit_pos.z - height end

    -- Upward facing normal
    if normal.z > 0.80 and normal.z < 1 then hit_pos.z = hit_pos.z + (normal.z * 4) end

    if normal.x > 0.80 or normal.x < -0.80 then
        
        hit_pos.x = hit_pos.x + normal.x * ( ((width * width) + (width * width)) / width)
        
    end

    if normal.y > 0.30 or normal.y < -0.30 then
        hit_pos.y = hit_pos.y + normal.y * ( ((width * width) + (width * width)) / width)
    end

    if normal.z < 0.1 and normal.z > -0.1 then
        hit_pos.z = hit_pos.z - height
    end 
    return hit_pos
end

function SWEP:TeleportPlayer( owner, pos )
    owner:SetVelocity(owner:GetVelocity() * -1) --negate fall damage
    owner:SetPos(pos)

    if not self.mute then self:EmitSound( self.ShootSound ) end
end

-- function SWEP:EnableDebug(ply, cmd, args, argStr)

-- end

function SWEP:Initialize()
    self:SetHoldType( "melee" )

    concommand.Add("tcenabledebug", function(ply, cmd, args, argStr)
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
    "Enable or disable debug mode (0/1)")
end

function SWEP:PrimaryAttack() 

    local owner = self:GetOwner()
    if (not owner:IsValid() ) then return end

    if SERVER then

        local eye_trace = owner:GetEyeTraceNoCursor()
        local hullmin, hullmax = owner:GetHull()
        local height = hullmax.z
        local width = hullmax.x

        --print("Min: ", hullmin, "Max: ", hullmax)

        if (not eye_trace.Hit) then return end

        --if (eye_trace.HitNonWorld) then return end

        local hit_pos = eye_trace.HitPos

        local normal = eye_trace.HitNormal
        if self.Debug then
            --PrintMessage(HUD_PRINTTALK, string.format("Normal x: %f y: %f z: %f", normal.x, normal.y, normal.z))
            print(string.format("Normal x: %f y: %f z: %f", normal.x, normal.y, normal.z))
        end

        hit_pos = self:AdjustBasedOnNormals(hit_pos, normal, width, height)

        --==INITIAL TRACE HULL==--
        local tr = util.TraceHull( {
            start = hit_pos,
            endpos = hit_pos,
            filter = self:GetOwner(),
            mins = hullmin,
            maxs = hullmax,
            mask = MASK_PLAYERSOLID
        } )

        --==INITIAL TRACE SUCCESS==--
        if not tr.Hit then
            print("First Initial hit is good!")
            if self.Debug then
                debugoverlay.Box(hit_pos, hullmin, hullmax, 2, Color(0, 255, 0, 100))
            end
            
            --self:TeleportPlayer( owner, hit_pos)
            return
        else

            if self.Debug then
                print("Initial trace hull failed!")
                --debugoverlay.Box(tr.HitPos, hullmin, hullmax, 2, Color(255, 0, 0, 100))
            end

           --==INITIAL TRACE FAILED, ATTEMPT RECOVERY==--
            local vertical_duck = self:CheckVerticalSpotDuck(hit_pos, owner)
            if vertical_duck then
                print("A location from the vertical duck function has been found.")


                --Could we improve this??
                --owner:ConCommand("+duck")
  
                timer.Simple(0.2, function()
                    --self:TeleportPlayer(owner, vertical_duck)
                end)
                timer.Simple(0.2, function()
                    --owner:ConCommand("-duck")
                end)
                
                
                
                return
            end

            

            --==HERE WE TRY A TO FIX EDGE CASE WHEN WE CLICK A WALL VERY LOW TO THE FLOOR==--
            local vertical = self:CheckVerticalSpot(hit_pos, hullmin, hullmax)

            if vertical then
                print("A location from the vertical function has been found.")
                --self:TeleportPlayer(owner, vertical)
                return
            end
            --if not vertical then print("We did get nil.") end


            

            --Shall we add a loop for the rest of the code?
            --Changing the location of the origin of the trace lines?
            --middle, bottom, top and maybe rotated by 45 degrees on the z axis


            local horizontal = self:CheckSpotWithMulitpleOrigins(hit_pos, hullmin, hullmax, height)

            if self.Debug then
                if horizontal == nil then print("CheckSpotWithMulitpleOrigins could not find a spot and returned us nil.") end
                if horizontal ~= nil then 
                    print("CheckSpotWithMulitpleOrigins found a spot at: ", horizontal) 
                    --self:TeleportPlayer( owner, horizontal)
                    return 
                end
            end

        end

    end

end

--TO DO
--CHANGE THE ORIGIN OF THE TRACELINES FROM THE CENTER TO TOP AND BOTTOM OF HULL??

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    if SERVER then
        if game.SinglePlayer() then
            self:CallOnClient("DoClientSecondary")
        end
        local owner = self:GetOwner()
        if (not owner:IsValid() ) then return end

        if save then 
            owner:SetPos(self.SaveSpot) 
            return
        end

        local eye_trace = owner:GetEyeTraceNoCursor()
        offset.x = 0
        offset.y = 0
        offset.z = 0

        if eye_trace.HitNonWorld then return end

        --local hit_pos = eye_trace.HitPos
        local normal = eye_trace.Normal

        if normal.z < -0.5 then 
            offset.z = normal.z * 82
        end

        if normal.x > 0.1 or normal.x < -0.1 then
            offset.x = normal.x * 25
            --offset.z = 0
        end

        if normal.y > 0.1 or normal.y < -0.1 then
            offset.y = normal.y * 25
            --offset.z = 0
        end

        self.SaveSpot = eye_trace.HitPos

    end

end

function SWEP:DoClientSecondary()
    chat.AddText(Color(221, 234, 79), "Saved teleportation spot has been cleared.")

end



concommand.Add("tcmute", function(ply, cmd, args, argStr)
    local arg = args[1]
    ServerLog(arg)
    if arg == "1" then mute = true end
    if arg == "0" then mute = false end
end, MuteAutoComplete, "test")

concommand.Add("tcclear", function(ply, cmd, args, argStr)
    if not IsValid(ply) then return end

    -- Clear the saved position
    save = nil

    -- Send message to the player who used the command
    if SERVER then
        net.Start("TC_ClearMessage")
        --net.WriteString()
        net.Send(ply)
    end
end, nil, "Clears saved teleport spot")

--concommand.Add("tcenabledebug", SWEP:EnableDebug(ply, cmd, args, argStr), MuteAutoComplete, "test")