-- RepReward addon for World of Warcraft
-- Author: jayd (jaydcurse)
-- v2.05
-- Date: 2013-06-04
-- Copyright(c) 2013, all rights reserved.

local questIndex, questName, numRewFactions
local updateInterval = 1.0
local timeSinceLastUpdate = 0

function CalcBonusRep(factionName)
	local bonusRep = 0
	local buffs = {
		-- setting the defaults to false so that you can start out assuming the player doesn't have the buff
		["Spirit of Sharing"] = {faction="all", bonusAmt=0.1},
        ["Grim Visage"] = {faction="all", bonusAmt=0.1},
        ["Unburdened"] = {faction="all", bonusAmt=0.1},
		["Banner of Cooperation"] = {faction="all", bonusAmt=0.05},
		["Standard of Unity"] = {faction="all", bonusAmt=0.1},
		["Battle Standard of Coordination"] = {faction="all", bonusAmt=0.15},
		["Nazgrel's Fervor"] = {faction="Thrallmar", bonusAmt=0.10},
		["Trollbane's Command"] = {faction="Honor Hold", bonusAmt=0.10},
		["A'dal's Song of Battle"] = {faction="Sha'tar", bonusAmt=0.10},
		["WHEE!"] = {faction="all", bonusAmt=0.10},
		["Darkmoon Top Rat"] = {faction="all", bonusAmt=0.10},
		["Berserker Rage"] = {faction="all", bonusAmt=1.0},
	}

	for buff, buffInfo in pairs(buffs) do
		if UnitBuff("player", buff) then
			if buffInfo.faction == "all" or buffInfo.faction == factionName then
				bonusRep = bonusRep + buffInfo.bonusAmt
			end
		end
	end

	local _, raceEn = UnitRace("player")
	if raceEn == "Human" then
		bonusRep = bonusRep + 0.1
	end
	return bonusRep
end

function CalcBonusRepCommendation(factionName)
	local factionIndex = 1
	local lastFactionName, name, hasBonusRepGain
	local bonusRepCommendation = 1
	repeat
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, hasBonusRepGain, _ = GetFactionInfo(factionIndex)
		if name == lastFactionName then break end
		lastFactionName = name
		if name == factionName then
			if hasBonusRepGain then
				bonusRepCommendation = 2
			end
			break
		end
		factionIndex = factionIndex + 1
	until factionIndex > 200
	return bonusRepCommendation
end

function ShowRepReward()
	local stringRep
	local numRewFactions = 0
	if QuestLogFrame:IsVisible() or QuestLogDetailFrame:IsVisible() then
		questIndex = GetQuestLogSelection()
		questName = GetQuestLogTitle(questIndex)
		numRewFactions = GetNumQuestLogRewardFactions()
	elseif QuestFrameDetailPanel:IsVisible() or QuestFrameRewardPanel:IsVisible() then
		questIndex = nil
		questName = GetTitleText()
		numRewFactions = GetNumQuestLogRewardFactions()	
	end
	if questName then
		local foundRep = false
		local factionId, amtRep, factionName, isHeader, hasRep, bonusRep, bonusRepCommendation, amtBonus, amtBase, stringRepColor1, stringRepColor2, stringRepLine
		for i = 1, numRewFactions do
			factionId, amtBase = GetQuestLogRewardFactionInfo(i);
			factionName, _, _, _, _, _, _, _, isHeader, _, hasRep = GetFactionInfoByID(factionId);
			if factionName and (not isHeader or hasRep) then
				foundRep = true
				amtBase = floor(amtBase / 100);
				bonusRep = CalcBonusRep(factionName)
				bonusRepCommendation = CalcBonusRepCommendation(factionName)
				if factionName == "Cenarion Circle" or factionName == "Timbermaw Hold" or factionName == "Argent Dawn" then
					amtBase = amtBase * 2
				elseif factionName == "Thorium Brotherhood" then
					amtBase = amtBase * 4
				end
				amtRep = floor((amtBase * (1 + bonusRep)) * bonusRepCommendation)
				amtBonus = amtRep - amtBase
				if amtBase < 0 then
					stringRepColor1 = "|cff621a00"
					stringRepColor2 = "|r"
				else
					stringRepColor1 = ""
					stringRepColor2 = ""
				end

				stringRepLine = factionName..": "..stringRepColor1..amtRep..stringRepColor2
				if amtBonus ~= 0 then
					stringRepLine = stringRepLine.."\n"..stringRepColor1.." ("..amtBase.." base + "..amtBonus.." bonus)"..stringRepColor2
				end
				if stringRep then
					stringRep = stringRep.."\n\n"..stringRepLine
				else
					stringRep = stringRepLine
				end
				stringRepLine = nil
			end
		end
		if not foundRep then
			stringRep = "No reputation reward"
		end
	end
	return stringRep, numRewFactions
end

local RepRewardTitleFrame = CreateFrame("Frame")
RepRewardTitleFrame:SetSize(288,20)
RepRewardTitleFrame.text = RepRewardTitleFrame:CreateFontString(nil,"ARTWORK","QuestFont_Shadow_Huge")
RepRewardTitleFrame.text:SetAllPoints(true)
RepRewardTitleFrame.text:SetJustifyH("LEFT")
RepRewardTitleFrame.text:SetJustifyV("TOP")
RepRewardTitleFrame.text:SetTextColor(0,0,0,1)

local RepRewardDetailFrame = CreateFrame("Frame")
RepRewardDetailFrame:SetSize(288,200)
RepRewardDetailFrame.text = RepRewardDetailFrame:CreateFontString(nil,"ARTWORK","QuestFontNormalSmall")
RepRewardDetailFrame.text:SetAllPoints(true)
RepRewardDetailFrame.text:SetJustifyH("LEFT")
RepRewardDetailFrame.text:SetJustifyV("TOP")
RepRewardDetailFrame.text:SetTextColor(0,0,0,1)

local function RepReward_ShowTitle()
	if QuestInfoRewardsHeader then
		RepRewardTitleFrame.text:SetTextColor(QuestInfoRewardsHeader:GetTextColor())
	end
	RepRewardTitleFrame.text:SetText("RepReward")
	return RepRewardTitleFrame
end

local function RepReward_ShowDetail()
	local stringRep, numRepFactions = ShowRepReward()
	local windowSize
	if QuestInfoDescriptionText then
		RepRewardDetailFrame.text:SetTextColor(QuestInfoDescriptionText:GetTextColor())
	end
	if numRepFactions then
		windowSize = numRepFactions * 30 + 20
		RepRewardDetailFrame:SetSize(288, windowSize)
	end
	RepRewardDetailFrame.text:SetText(stringRep)
	return RepRewardDetailFrame
end

local posSpacer = 0
for i = #QUEST_TEMPLATE_LOG.elements-2, 1, -3 do
	if QUEST_TEMPLATE_LOG.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer+1, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer+2, -10)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer+3, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer+4, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer+5, -5)
else
	table.insert(QUEST_TEMPLATE_LOG.elements, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_LOG.elements, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, -10)
	table.insert(QUEST_TEMPLATE_LOG.elements, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_LOG.elements, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, -5)
end

for i = #QUEST_TEMPLATE_DETAIL2.elements-2, 1, -3 do
	if QUEST_TEMPLATE_DETAIL2.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer+1, 0)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer+2, -10)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer+3, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer+4, 0)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, posSpacer+5, -5)
else
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, 0)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, -10)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, 0)
	table.insert(QUEST_TEMPLATE_DETAIL2.elements, -5)
end


for i = #QUEST_TEMPLATE_REWARD.elements-2, 1, -3 do
	if QUEST_TEMPLATE_REWARD.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer+1, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer+2, -10)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer+3, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer+4, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer+5, -5)
else
	table.insert(QUEST_TEMPLATE_REWARD.elements, RepReward_ShowTitle)
	table.insert(QUEST_TEMPLATE_REWARD.elements, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, -10)
	table.insert(QUEST_TEMPLATE_REWARD.elements, RepReward_ShowDetail)
	table.insert(QUEST_TEMPLATE_REWARD.elements, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, -5)
end
