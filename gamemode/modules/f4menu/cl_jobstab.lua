/*---------------------------------------------------------------------------
Left panel for the jobs
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:SetBackgroundColor(Color(0, 0, 0, 0))
	self:EnableVerticalScrollbar()
	self:SetSpacing(2)
	self.VBar.Paint = fn.Id
	self.VBar.btnUp.Paint = fn.Id
	self.VBar.btnDown.Paint = fn.Id

end

function PANEL:Refresh()
	for k,v in pairs(self.Items) do
		if v.Refresh then v:Refresh() end
	end
end

/*-- The white stuff is for testing purposes.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,255))
end*/

derma.DefineControl("F4EmptyPanel", "", PANEL, "DPanelList")

/*---------------------------------------------------------------------------
Right panel for the jobs
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:Init()
	self.BaseClass.Init(self)
	self:SetPadding(10)

	self.lblTitle = vgui.Create("DLabel")
	self.lblTitle:SetFont("HUDNumber5")
	self:AddItem(self.lblTitle)

	self.lblDescription = vgui.Create("DLabel")
	self.lblDescription:SetWide(self:GetWide() - 20)
	self.lblDescription:SetAutoStretchVertical(true)
	self:AddItem(self.lblDescription)

	self.filler = VGUIRect(0, 0, 0, 20)
	self.filler:SetColor(Color(0, 0, 0, 0))
	self:AddItem(self.filler)

	self.lblWeapons = vgui.Create("DLabel")
	self.lblWeapons:SetFont("HUDNumber5")
	self.lblWeapons:SetText("Weapons")
	self.lblWeapons:SizeToContents()
	self.lblWeapons:SetTall(50)
	self:AddItem(self.lblWeapons)

	self.lblSweps = vgui.Create("DLabel")
	self.lblSweps:SetAutoStretchVertical(true)
	self:AddItem(self.lblSweps)
end

local black = Color(0, 0, 0, 170)
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, black)
end

-- functions for getting the weapon names from the job table
local getWepName = fn.FOr{fn.FAnd{weapons.Get, fn.Compose{fn.Curry(fn.GetValue, 2)("PrintName"), weapons.Get}}, fn.Id}
local getWeaponNames = fn.Curry(fn.Map, 2)(getWepName)
local weaponString = fn.Compose{fn.Curry(fn.Flip(table.concat), 2)("\n"), fn.Curry(fn.Seq, 2)(table.sort), getWeaponNames, table.Copy}
function PANEL:updateInfo(job)
	self.lblTitle:SetText(job.name)
	self.lblTitle:SizeToContents()

	self.lblDescription:SetText(job.description)
	self.lblDescription:SizeToContents()

	local weps = weaponString(job.weapons)
	weps = weps ~= "" and weps or DarkRP.getPhrase("no_extra_weapons")

	self.lblSweps:SetText(weps)

	self:InvalidateLayout()
	timer.Simple(0, fn.Curry(self.InvalidateLayout, 2)(self))
end

derma.DefineControl("F4JobsPanelRight", "", PANEL, "F4EmptyPanel")


/*---------------------------------------------------------------------------
Jobs panel
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:Init()
	self.pnlLeft = vgui.Create("F4EmptyPanel", self)
	self.pnlLeft:Dock(LEFT)

	self.pnlRight = vgui.Create("F4JobsPanelRight", self)
	self.pnlRight:Dock(RIGHT)

	self:fillData()
	self.pnlRight:updateInfo(RPExtraTeams[1])
end

function PANEL:PerformLayout()
	self.pnlLeft:SetWide(self:GetWide() * 2/3 - 5)
	self.pnlRight:SetWide(self:GetWide() * 1/3 - 5)
end

PANEL.Paint = fn.Id

function PANEL:Refresh()
	self.pnlLeft:Refresh()
end

function PANEL:fillData()
	for i, job in ipairs(RPExtraTeams) do
		local item = vgui.Create("F4MenuJobButton")
		item:setDarkRPItem(job)
		item.DoClick = fn.Compose{fn.Curry(self.pnlRight.updateInfo, 2)(self.pnlRight), fn.Curry(fn.GetValue, 3)("DarkRPItem")(item)}
		self.pnlLeft:AddItem(item)
	end
end

derma.DefineControl("F4MenuJobs", "", PANEL, "DPanel")
