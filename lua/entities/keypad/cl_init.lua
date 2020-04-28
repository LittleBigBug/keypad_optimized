include "sh_init.lua"
include "cl_maths.lua"
include "cl_panel.lua"

local ply

ENT.Opac = 0

function ENT:KPShouldDraw()
	if not ply then ply = LocalPlayer() return false end

	local dist = 120
	return ply:GetPos():DistToSqr(self:GetPos()) < (dist * dist)
end

local wMat = CreateMaterial("XD", "UnlitGeneric", {
 ["$basetexture"] = "white",
 ["$translucent"] = 1,
 ["$vertexalpha"] = 1,
 ["$vertexcolor"] = 1,
 ["$color"] = "{ 36 36 36 }"
} )

function ENT:Draw()
	local shDraw = self:KPShouldDraw()

	self.Opac = Lerp(0.1, self.Opac, shDraw and 255 or 0)

	if math.Round(self.Opac) < 255 then
		self:DrawModel()
		if math.Round(self.Opac) == 0 then
			return
		end
	end

	render.OverrideDepthEnable(true, true)
		render.SetMaterial(wMat)
		render.DrawBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, Color(16, 16, 16, self.Opac), true)
	render.OverrideDepthEnable(false)

	local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()

	local w, h = self.Width2D, self.Height2D
	local x, y = self:CalculateCursorPos()

	local scale = self.Scale -- A high scale avoids surface call integerising from ruining aesthetics

	cam.Start3D2D(pos, ang, self.Scale)
		self:Paint(w, h, x, y)
	cam.End3D2D()
end

function ENT:SendCommand(command, data)
	net.Start("Keypad")
		net.WriteEntity(self)
		net.WriteUInt(command, 4)

		if data then
			net.WriteUInt(data, 8)
		end
	net.SendToServer()
end
