local v_major, v_minor = 1, 0
---@class SpellButton
local lib = _G.LibStub:NewLibrary("LibSpellButton-" .. v_major, v_minor)
if not lib then
    -- luacov: disable
    return    -- already loaded and no upgrade necessary
    -- luacov: enable
end

local function OnLeave()
    _G.GameTooltip:Hide()
end

local ButtonMixin = {}

---@return SpellButton
function ButtonMixin:init(spellId, name, height, width)
    self.spellId = spellId
    self.name = name
    self.height = height or 38
    self.width = width or 38

    ---@type Frame
    self.btn = _G.CreateFrame("Button", name, _G.UIParent, "ActionButtonTemplate,SecureActionButtonTemplate")
    self.icon = _G[name .. "Icon"]
    self:setSpell(spellId)

    self.btn:SetSize(self.width, self.height)
    self.btn:RegisterForClicks("AnyDown", "AnyUp")

    self.btn.Cooldown = _G.CreateFrame("Cooldown", name .. "Cooldown", self.btn, "CooldownFrameTemplate")
    self:cooldown()

    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    --self:RegisterEvent("PLAYER_REGEN_DISABLED")
    --self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self.btn:SetScript("OnLeave", OnLeave)
    self:movable()
    self.btn:Show()
end

function ButtonMixin:setSpell(spellID)
    self.spellInfo = _G.C_Spell.GetSpellInfo(spellID)
    self.btn:SetAttribute("type1", "spell")
    self.btn:SetAttribute("spell", self.spellInfo['name'])
    self:SetIcon(self.spellInfo['iconID'])
end

function ButtonMixin:SetIcon(iconID)
    self.icon:SetTexture(iconID)
    self.icon:SetSize(self.width, self.height)
    self.icon:SetAllPoints()
end

function ButtonMixin:SPELL_UPDATE_COOLDOWN(_, spellID)
    if spellID == self.spellId then
        self:cooldown()
    end
end

function ButtonMixin:movable(positionCallback)
    self.btn:SetMovable(true)
    self.btn:EnableMouse(true)
    self.btn:SetClampedToScreen(true)
    self.btn:RegisterForDrag("LeftButton")
    self.btn:SetScript("OnDragStart", function(button)
        button:StartMoving()
    end)
    self.btn:SetScript("OnDragStop", function(button)
        local offsetX, offsetY = self:getPosition()
        if positionCallback then
            positionCallback(offsetX, offsetY)
        end
        button:StopMovingOrSizing()
    end)
end

function ButtonMixin:cooldown()
    local spellCooldownInfo = _G.C_Spell.GetSpellCooldown(self.spellId)
    _G.CooldownFrame_Set(self.btn.Cooldown, spellCooldownInfo['startTime'], spellCooldownInfo['duration'], spellCooldownInfo['isEnabled'])
end

function ButtonMixin:setUnit(unit)
    self.btn:SetAttribute("unit", unit);
end

function ButtonMixin:setScript(event, callback)
    self.btn:SetScript(event, callback)
end

---@param point string Point on the current frame
---@param relativeTo string a frame the point should be relative to
---@param relativeToPoint string Point on the other frame
---@param x number Horizontal offset from the relative point
---@param y number Vertical offset from the relative point
function ButtonMixin:setPoint(point, relativeTo, relativeToPoint, x, y)
    self.btn:SetPoint(point, relativeTo, relativeToPoint, x, y);
end

function ButtonMixin:getPosition()
    local point, relativeTo, relativePoint, offsetX, offsetY = self.btn:GetPoint(1)
    --@debug@
    print('Button position', point, relativeTo, relativePoint, offsetX, offsetY)
    --@end-debug@
    return ('%d'):format(offsetX), ('%d'):format(offsetY)
end

function ButtonMixin:setItem(bag, slot)
    self.btn:SetAttribute('target-bag', bag)
    self.btn:SetAttribute('target-slot', slot)
    self.btn:SetAttribute("target-item", ("%d %d"):format(bag, slot))

    local itemInfo = _G.C_Container.GetContainerItemInfo(bag, slot);
    self.icon:SetTexture(itemInfo['iconFileID'])
    self.itemID = itemInfo['itemID']
    self:setCount(C_Item.GetItemCount(self.itemID))
    --@debug@
    print('Set button item', itemInfo['hyperlink'])
    --@end-debug@
end

function ButtonMixin:removeItem()
    self:setCount("")
    self:SetIcon(self.spellInfo['iconID'])
    self.btn:ClearAttribute('target-bag')
    self.btn:ClearAttribute('target-slot')
    self.btn:ClearAttribute("target-item")
end

function ButtonMixin:setCount(count)
    local count_frame = _G[self.name .. "Count"]
    count_frame:SetText(count)
end

function ButtonMixin:Hide()
    self.btn:Hide()
    self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
end

function ButtonMixin:Show()
    self.btn:Show()
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end

_G.LibStub("AceEvent-3.0"):Embed(ButtonMixin)

---@return SpellButton
function lib.CreateSpellButton(spellId, name, height, width)
    local button = _G.CreateFromMixins(ButtonMixin)
    button:init(spellId, name, height, width)
    return button
end