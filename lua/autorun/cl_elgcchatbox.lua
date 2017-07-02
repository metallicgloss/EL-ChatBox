
if SERVER then
	resource.AddFile("materials/elgcchatbox/banner.png")
	resource.AddFile("materials/elgcchatbox/bu1.png")
	resource.AddFile("materials/elgcchatbox/bu2.png")
	resource.AddFile("materials/elgcchatbox/bu3.png")
	AddCSLuaFile()

	local PLAYER = FindMetaTable("Player")
	util.AddNetworkString("elgcChatbox_printMessage")

	function PLAYER:ChatPrint(message)
		net.Start("elgcChatbox_printMessage")
		net.WriteString(message)
		net.WriteString("")
		net.Send(self)
	end

	function PLAYER:PrintMessage(typ, message)
		if typ == HUD_PRINTCONSOLE then
			net.Start("elgcChatbox_printMessage")
			net.WriteString("")
			net.WriteString(message)
			net.Send(self)
		elseif type == HUD_PRINTTALK then
			net.Start("elgcChatbox_printMessage")
			net.WriteString(message)
			net.WriteString(message)
			net.Send(self)
		end
	end
	
	function PrintMessage(typ, message)
		if typ == HUD_PRINTCONSOLE then
			net.Start("elgcChatbox_printMessage")
			net.WriteString("")
			net.WriteString(message)
			net.Send(player.GetAll())
		elseif type == HUD_PRINTTALK then
			net.Start("elgcChatbox_printMessage")
			net.WriteString(message)
			net.WriteString(message)
			net.Send(player.GetAll())
		end
	end

return end

elgcChatbox = {}
elgcChatbox.alpha = 255
elgcChatbox.font = "Roboto Bold"
elgcChatbox.size = 16
elgcChatbox.titleSize = 18
elgcChatbox.button1link = "https://steamcommunity.com/sharedfiles/filedetails/?id=346340614" --Set your Steam Workshop Pack here
elgcChatbox.button2link = "https://steamcommunity.com/groups/elhostingservices" --Set your Steam Group here
elgcChatbox.button3link = "https://www.elhostingservices.com" --Set your website here
elgcChatbox.y = 0
elgcChatbox.lastPrint = nil
elgcChatbox.isOpen = false
elgcChatbox.buttons = {}
elgcChatbox.maxCharacters = 150
elgcChatbox.ChatType = "say"
elgcChatbox.id = 0

surface.CreateFont("elgcChatbox_font", {
	font = elgcChatbox.font,
	size = elgcChatbox.size,
	antialias = true,
})

surface.CreateFont("elgcChatbox_titleFont", {
	font = elgcChatbox.font,
	size = elgcChatbox.titleSize,
	antialias = true,
})

function elgcChatbox.buildFrame()
	elgcChatbox.alpha = 0
	
	elgcChatbox.frame = vgui.Create("DFrame")
	elgcChatbox.frame:SetSize(ScrW() / 3, ScrH() / 3)
	elgcChatbox.frame:SetPos(25, ScrH() - elgcChatbox.frame:GetTall() - 25)
	elgcChatbox.frame:ShowCloseButton(false)
	elgcChatbox.frame:SetTitle("")
	
	local elgcBanner = vgui.Create("DImage", elgcChatbox.frame)
	elgcBanner:SetImage("elgcChatbox/banner.png")
	elgcBanner:SetSize(25, 25)
	elgcBanner:SetPos(elgcChatbox.frame:GetWide() - 25 - 7.5, 7.5)
	elgcBanner.Think = function(self) self:SetAlpha(elgcChatbox.alpha) end
	
	local chatButton = vgui.Create("DButton", elgcChatbox.frame)
	chatButton:SetFont("elgcChatbox_font")
	chatButton:SetText("CHAT")
	chatButton:SizeToContents()
	chatButton:SetSize(chatButton:GetWide() + 10, chatButton:GetTall() + 10)
	chatButton:SetText("")
	chatButton:SetPos(10, elgcChatbox.frame:GetTall() - chatButton:GetTall() - 10)
	chatButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(21, 22, 24, elgcChatbox.alpha))
		draw.SimpleText("CHAT", "elgcChatbox_font", w / 2, h / 2, Color(240, 240, 240, elgcChatbox.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	chatButton.DoClick = function(self)
		if string.Trim(elgcChatbox.textEntry:GetText()) != "" then LocalPlayer():ConCommand(elgcChatbox.ChatType .. " \"" .. string.sub(elgcChatbox.textEntry:GetText() or "", 1, elgcChatbox.maxCharacters) .. "\"") end
		elgcChatbox.Close()
	end
	
	elgcChatbox.textEntry = vgui.Create("DTextEntry", elgcChatbox.frame)
	elgcChatbox.textEntry:SetSize(elgcChatbox.frame:GetWide() - 25 - chatButton:GetWide(), chatButton:GetTall())
	elgcChatbox.textEntry:SetPos(15 + chatButton:GetWide(), elgcChatbox.frame:GetTall() - 10 - elgcChatbox.textEntry:GetTall())
	elgcChatbox.textEntry:SetTextColor(Color(255, 255, 255, 255))
	elgcChatbox.textEntry:SetDrawBackground(false)
	elgcChatbox.textEntry:SetDrawBorder(false)
	elgcChatbox.textEntry:SetFont("elgcChatbox_font")
	elgcChatbox.textEntry:SetHighlightColor(Color(48, 183, 86, 255))
	elgcChatbox.textEntry:SetCursorColor(Color(255, 255, 255, 255))
	elgcChatbox.textEntry.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(21, 22, 24, elgcChatbox.alpha))
		derma.SkinHook("Paint", "TextEntry", self, w, h)
		if string.len(self:GetText()) > elgcChatbox.maxCharacters then
			surface.SetDrawColor(255, 0, 0, elgcChatbox.alpha)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end
	elgcChatbox.textEntry.OnTextChanged = function(self) if self and self.GetText then gamemode.Call("ChatTextChanged", self:GetText() or "") end end
	elgcChatbox.textEntry.OnKeyCodeTyped = function(self, code)
		if code == KEY_ESCAPE then
			elgcChatbox.Close()
			gui.HideGameUI()
		elseif code == KEY_TAB then
			timer.Simple(0.001, function() elgcChatbox.textEntry:RequestFocus() end)
		elseif code == KEY_ENTER then
			if string.Trim(self:GetText()) != "" then LocalPlayer():ConCommand(elgcChatbox.ChatType .. " \"" .. string.sub(self:GetText() or "", 1, elgcChatbox.maxCharacters) .. "\"") end
			elgcChatbox.Close()
		end
	end
	
	elgcChatbox.chatLog = vgui.Create("DScrollPanel", elgcChatbox.frame)
	elgcChatbox.chatLog:SetSize(elgcChatbox.frame:GetWide() - 20, elgcChatbox.frame:GetTall() - 65 - chatButton:GetTall())
	elgcChatbox.chatLog:SetPos(10, 50)
	elgcChatbox.chatLog:SetVerticalScrollbarEnabled(true)
	elgcChatbox.chatLog.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(21, 22, 24, elgcChatbox.alpha))
	end
	elgcChatbox.chatLog.autoScroll = true
	elgcChatbox.chatLog.OnMousePressed = function()
		if elgcChatbox.isOpen == true then elgcChatbox.chatLog.autoScroll = false end
	end
	
	elgcChatbox.chatLog:GetVBar().Paint = function(self, w, h) draw.RoundedBox(0, w / 4, 15, w / 2, h - 30, Color(33, 33, 36, elgcChatbox.alpha)) end
	elgcChatbox.chatLog:GetVBar().btnUp.Paint = function(self, w, h) draw.RoundedBox(0, w / 4, h / 4, w / 2, h / 2, Color(48, 183, 86, elgcChatbox.alpha)) end
	elgcChatbox.chatLog:GetVBar().btnDown.Paint = function(self, w, h) draw.RoundedBox(0, w / 4, h / 4, w / 2, h / 2, Color(48, 183, 86, elgcChatbox.alpha)) end
	elgcChatbox.chatLog:GetVBar().btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, w / 4, 0, w / 2, h, Color(48, 183, 86, elgcChatbox.alpha)) end
	
	elgcChatbox.frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 10, 40, w - 20, 10, Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, 10, h - 10, w - 20, 10, Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, 10, h - 15 - chatButton:GetTall(), w - 20, 5, Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, 10 + chatButton:GetWide(), h - 10 - chatButton:GetTall(), 5, chatButton:GetTall(), Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, 0, 40, 10, h - 40, Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, w - 10, 40, 10, h - 40, Color(48, 183, 86, elgcChatbox.alpha))
		draw.RoundedBox(0, 0, 0, w, 40, Color(21, 22, 24, elgcChatbox.alpha))
		draw.SimpleText("Encrypted Laser Gaming Community", "elgcChatbox_titleFont", 15, 20, Color(240, 240, 240, elgcChatbox.alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	elgcChatbox.buttons = {}
	
	elgcChatbox.buttons[1] = vgui.Create("DImageButton")
	elgcChatbox.buttons[1]:SetSize(35, 35)
	elgcChatbox.buttons[1]:SetImage("elgcChatbox/bu1.png")
	local x, y = chat.GetChatBoxPos()
	x = x + elgcChatbox.frame:GetWide() + 10
	elgcChatbox.buttons[1]:SetPos(x, y)
	elgcChatbox.buttons[1].Think = function(self) self:SetAlpha(elgcChatbox.alpha) end
	elgcChatbox.buttons[1].DoClick = function() gui.OpenURL(elgcChatbox.button1link) end
	
	elgcChatbox.buttons[2] = vgui.Create("DImageButton")
	elgcChatbox.buttons[2]:SetSize(35, 35)
	elgcChatbox.buttons[2]:SetImage("elgcChatbox/bu2.png")
	y = y + 40
	elgcChatbox.buttons[2]:SetPos(x, y)
	elgcChatbox.buttons[2].Think = function(self) self:SetAlpha(elgcChatbox.alpha) end
	elgcChatbox.buttons[2].DoClick = function() gui.OpenURL(elgcChatbox.button2link) end
	
	elgcChatbox.buttons[3] = vgui.Create("DImageButton")
	elgcChatbox.buttons[3]:SetSize(35, 35)
	elgcChatbox.buttons[3]:SetImage("elgcChatbox/bu3.png")
	y = y + 40
	elgcChatbox.buttons[3]:SetPos(x, y)
	elgcChatbox.buttons[3].Think = function(self) self:SetAlpha(elgcChatbox.alpha) end
	elgcChatbox.buttons[3].DoClick = function() gui.OpenURL(elgcChatbox.button3link) end
	
	elgcChatbox.Close()
	
	hook.Add("Think", "elgcChatbox_closeOnMainMenu", function()
		if gui.IsGameUIVisible() and elgcChatbox.isOpen == true then
			elgcChatbox.Close()
			gui.HideGameUI()
		elseif gui.IsGameUIVisible() and elgcChatbox.isOpen == false then
			elgcChatbox.frame:SetVisible(false)
		elseif gui.IsGameUIVisible() == false and elgcChatbox.isOpen == false then
			elgcChatbox.frame:SetVisible(true)
		end
	end)
end

function elgcChatbox.Open()
	elgcChatbox.isOpen = true
	elgcChatbox.frame:MakePopup()
	elgcChatbox.textEntry:RequestFocus()
	
	timer.Remove("elgcChatbox_fade")
	timer.Create("elgcChatbox_fade", 0.01, 0, function()
		if elgcChatbox.alpha < 255 then elgcChatbox.alpha = elgcChatbox.alpha + 50
			if elgcChatbox.alpha > 255 then elgcChatbox.alpha = 255 end
		end
		if elgcChatbox.alpha == 255 then timer.Remove("elgcChatbox_fade") end
	end)
	
	gamemode.Call("StartChat")
end

function elgcChatbox.Close()
	elgcChatbox.textEntry:KillFocus()
	elgcChatbox.frame:KillFocus()
	elgcChatbox.isOpen = false
	
	for _, pnl in pairs({elgcChatbox.frame, elgcChatbox.buttons[1], elgcChatbox.buttons[2], elgcChatbox.buttons[3]}) do
		elgcChatbox.frame:SetMouseInputEnabled(false)
		elgcChatbox.frame:SetKeyboardInputEnabled(false)
	end
	gui.EnableScreenClicker(false)
	
	timer.Remove("elgcChatbox_fade")
	timer.Create("elgcChatbox_fade", 0.01, 0, function()
		if elgcChatbox.alpha > 0 then elgcChatbox.alpha = elgcChatbox.alpha - 50
			if elgcChatbox.alpha < 0 then elgcChatbox.alpha = 0 end
		end
		if elgcChatbox.alpha == 0 then timer.Remove("elgcChatbox_fade") end
	end)
	
	elgcChatbox.hideText = CurTime() + 6
	
	elgcChatbox.chatLog.autoScroll = true
	
	gamemode.Call("FinishChat")
	elgcChatbox.textEntry:SetText("")
	gamemode.Call("ChatTextChanged", "")
end

hook.Add("PlayerBindPress", "elgcChatbox_bindDetect", function(ply, bind, pressed)
	if string.sub(bind, 1, 11) == "messagemode" then
		if bind == "messagemode2" then elgcChatbox.ChatType = "say_team"
		else elgcChatbox.ChatType = "say" end
		if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
		elgcChatbox.Open()
		return true
	end
end)

hook.Add("HUDShouldDraw", "elgcChatbox_hideDefaultChatbox", function(name) if name == "CHudChat" then return false end end)

function chat.GetChatBoxSize()
	if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
	return elgcChatbox.frame:GetSize()
end

function chat.GetChatBoxPos()
    if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
	return elgcChatbox.frame:GetPos()
end

function chat.Open()
	if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
	elgcChatbox.Open()
end

function chat.Close() 
	if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
	elgcChatbox.Close()
end

function chat.AddText(...)
	if not IsValid(elgcChatbox.frame) then elgcChatbox.buildFrame() end
	
	local cText = ""
	local fText = {}
	local lastColor = Color(255, 255, 255, 255)
	
	local function printLine(args)
		local newLine = vgui.Create("RichText", elgcChatbox.chatLog)
		newLine:SetVerticalScrollbarEnabled(false)
		newLine:SetSize(elgcChatbox.chatLog:GetWide(), draw.GetFontHeight("elgcChatbox_font") + 3)
		newLine.PerformLayout = function(self)
			self:SetFontInternal("elgcChatbox_font")
			self:SetFGColor(Color(255, 255, 255, 255))
		end
		newLine:SetPos(0, elgcChatbox.y)
		elgcChatbox.y = elgcChatbox.y + draw.GetFontHeight("elgcChatbox_font")
		for _, obj in pairs(args) do
			if type(obj) == "table" then newLine:InsertColorChange(obj.r, obj.g, obj.b, obj.a)
			elseif type(obj) == "string" then newLine:AppendText(obj) end
		end
		newLine.elgcAlpha = 255
		if elgcChatbox.isOpen == true then newLine.fade = CurTime() + 999999 else newLine.fade = CurTime() + 7 end
		elgcChatbox.id = elgcChatbox.id + 1
		newLine.elgcID = elgcChatbox.id
		newLine.Paint = function(self, w, h)
			local a = 1
			if gui.IsGameUIVisible() then a = 0 end
			draw.RoundedBox(0, 0, 0, w, h, Color(21, 22, 24, newLine.elgcAlpha * a))
			self:SetAlpha(newLine.elgcAlpha * a)
		end
		newLine:SetMouseInputEnabled(false)
		newLine.Think = function(self)
			if newLine.fade < CurTime() and timer.Exists("elgcChatbox_fadeout" .. newLine.elgcID) == false and newLine.elgcAlpha > 0 then
				timer.Remove("elgcChatbox_fadein" .. newLine.elgcID)
				timer.Create("elgcChatbox_fadeout" .. newLine.elgcID, 0.01, 0, function()
					if newLine.elgcAlpha > 0 then
						newLine.elgcAlpha = newLine.elgcAlpha - 30
						if newLine.elgcAlpha < 0 then newLine.elgcAlpha = 0 end
					end
					if newLine.elgcAlpha == 0 then timer.Remove("elgcChatbox_fadeout" .. newLine.elgcID) end
				end)
			elseif newLine.fade > CurTime() and timer.Exists("elgcChatbox_fadein" .. newLine.elgcID) == false and newLine.elgcAlpha < 255 then
				timer.Remove("elgcChatbox_fadeout" .. newLine.elgcID)
				timer.Create("elgcChatbox_fadein" .. newLine.elgcID, 0.01, 0, function()
					if newLine.elgcAlpha < 255 then
						newLine.elgcAlpha = newLine.elgcAlpha + 30
						if newLine.elgcAlpha > 255 then newLine.elgcAlpha = 255 end
					end
					if newLine.elgcAlpha == 255 then timer.Remove("elgcChatbox_fadein" .. newLine.elgcID) end
				end)
			end
		end
		hook.Add("StartChat", "elgcChatbox_showText" .. newLine.elgcID, function()
			newLine.fade = CurTime() + 999999
		end)
		hook.Add("FinishChat", "elgcChatbox_fadeText" .. newLine.elgcID, function()
			newLine.fade = CurTime() + 7
		end)
		if elgcChatbox.chatLog.autoScroll == true then elgcChatbox.chatLog:ScrollToChild(newLine) end
	end
	
	local function getFirstWord(text)
		local words = string.Explode("", text)
		local endP = 1
		local isLastSpace = (words[1] == " ")
		for p, letter in pairs(words) do
			if p != 1 and ((letter == " " and isLastSpace == false) or (letter != " " and isLastSpace == true)) then
				endP = p - 1
				break
			end
		end
		return string.sub(text, 1, endP)
	end
	
	local function chatInsert(text)
		surface.SetFont("elgcChatbox_font")
		local maxLineSize = elgcChatbox.chatLog:GetWide() - 32
		
		if surface.GetTextSize(cText .. text) > maxLineSize then
			local firstWord = ""
			local extraText = text
			while true do
				firstWord = getFirstWord(extraText)
				if firstWord != extraText then
					extraText = string.sub(extraText, string.len(firstWord) + 1, string.len(extraText))
				else extraText = "" end
				
				if surface.GetTextSize(cText .. firstWord) > maxLineSize then
					if surface.GetTextSize(firstWord) > maxLineSize then
						for _, letter in pairs(string.Explode("", firstWord)) do	
							if surface.GetTextSize(cText .. letter) > maxLineSize then
								printLine(fText)
								cText = letter
								fText = {lastColor, letter}
							else
								cText = cText .. letter
								table.Add(fText, {letter})
							end
						end
					else
						printLine(fText)
						cText = firstWord
						fText = {lastColor, firstWord}
					end
				else
					cText = cText .. firstWord
					table.Add(fText, {firstWord})
				end
				
				if extraText == "" then break end
			end
		else
			cText = cText .. text
			table.Add(fText, {text})
		end
	end
	
	for _, obj in pairs({...}) do
		if type(obj) == "table" then
			table.Add(fText, {obj})
			lastColor = obj
		elseif type(obj) == "string" then
			chatInsert(obj)
		elseif obj:IsPlayer() then
			table.Add(fText, {GAMEMODE:GetTeamColor(obj)})
			lastColor = GAMEMODE:GetTeamColor(obj)
			chatInsert(obj:Nick())
		end
	end
	
	if cText != "" then printLine(fText) end
	
	elgcChatbox.hideText = CurTime() + 6
end

hook.Add("ChatText", "elgcChatbox_consoleMessages", function(index, name, message, typ)
	if index == 0 then chat.AddText(Color(100, 100, 100, 255), "CONSOLE", Color(255, 255, 255, 255), ": ".. message) end
end)

net.Receive("elgcChatbox_printMessage", function()
	chatMessage = net.ReadString()
	consoleMessage = net.ReadString()
	if chatMessage != "" then chat.AddText(chatMessage) end
	if consoleMessage != "" then print(consoleMessage) end
end)