--[[
  File: init.lua
  Author: Cpt. Dave
  License: MIT
--]]

if SERVER then
  AddCSLuaFile("cl_init.lua")
  AddCSLuaFile("shared.lua")
end

include("shared.lua")