-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = true },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["attack"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["grapple"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["damage"] = { sIcon = "action_damage", sTargeting = "each", bUseModStack = true },
	["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
	["cast"] = { sTargeting = "each" },
	["castclc"] = { sTargeting = "each" },
	["castsave"] = { sTargeting = "each" },
	["clc"] = { sTargeting = "each", bUseModStack = true },
	["spellsave"] = { sTargeting = "each" },
	["spdamage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	["skill"] = { bUseModStack = true },
	["init"] = { bUseModStack = true },
	["save"] = { bUseModStack = true },
	["ability"] = { bUseModStack = true },
	-- PF SPECIFIC
	["concentration"] = { bUseModStack = true },
	-- TRIGGERED
	["critconfirm"] = { sIcon = "action_attack" },
	["misschance"] = { },
	["stabilization"] = { },
};

targetactions = {
	"attack",
	"critconfirm",
	"grapple",
	"damage",
	"spdamage",
	"heal",
	"effect",
	"cast",
	"clc",
	"spellsave"
};

currencies = { "PP", "GP", "SP", "CP" };
currencyDefault = "GP";

function onInit()
	-- Languages
	languages = {
		[Interface.getString("language_value_abyssal")] = "Infernal",
		[Interface.getString("language_value_aquan")] = "Elven",
		[Interface.getString("language_value_auran")] = "Draconic",
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_common")] = "",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_druidic")] = "Elven",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_giant")] = "Dwarven",
		[Interface.getString("language_value_gnoll")] = "",
		[Interface.getString("language_value_gnome")] = "Dwarven",
		[Interface.getString("language_value_goblin")] = "Dwarven",
		[Interface.getString("language_value_halfling")] = "",
		[Interface.getString("language_value_ignan")] = "Draconic",
		[Interface.getString("language_value_infernal")] = "Infernal",
		[Interface.getString("language_value_orc")] = "Dwarven",
		[Interface.getString("language_value_sylvan")] = "Elven",
		[Interface.getString("language_value_terran")] = "Dwarven",
		[Interface.getString("language_value_undercommon")] = "Elven",
	}
	if DataCommon.isPFRPG() then
		-- languages[Interface.getString("language_value_aboleth")] = "";
		languages[Interface.getString("language_value_catfolk")] = "";
		languages[Interface.getString("language_value_grippli")] = "";
		-- languages[Interface.getString("language_value_samsaran")] = "";
		-- languages[Interface.getString("language_value_strix")] = "";
		-- languages[Interface.getString("language_value_tengu")] = "";
		languages[Interface.getString("language_value_vanaran")] = "";
		languages[Interface.getString("language_value_vishkanya")] = "";
		-- languages[Interface.getString("language_value_wayang")] = "";
	end
	languagefonts = {
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_infernal")] = "Infernal",
	}

	if DataCommon.isPFRPG() then
		languages[Interface.getString("language_value_aklo")] = "";
	end
end

function getCharSelectDetailHost(nodeChar)
	local sValue = "";
	local nLevel = DB.getValue(nodeChar, "level", 0);
	if nLevel > 0 then
		sValue = "Level " .. math.floor(nLevel*100)*0.01;
	end
	return sValue;
end

function requestCharSelectDetailClient()
	return "name,#level";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], "Level " .. math.floor(vDetails[2]*100)*0.01;
end

function getCharSelectDetailLocal(nodeLocal)
	local vDetails = {};
	table.insert(vDetails, DB.getValue(nodeLocal, "name", ""));
	table.insert(vDetails, DB.getValue(nodeLocal, "level", 0));
	return receiveCharSelectDetailClient(vDetails);
end

function getDistanceUnitsPerGrid()
	return 5;
end

function getDeathThreshold(rActor)
	local nDying = 10;

	if DataCommon.isPFRPG() then
		local nStat = ActorManager2.getAbilityScore(rActor, "constitution");
		if nStat < 0 then
			nDying = 10;
		else
			nDying = nStat - ActorManager2.getAbilityDamage(rActor, "constitution");
			if nDying < 1 then
				nDying = 1;
			end
		end
	end
	
	return nDying;
end

function getStabilizationRoll(rActor)
	local rRoll = { sType = "stabilization", sDesc = "[STABILIZATION]" };
	
	if DataCommon.isPFRPG() then
		rRoll.aDice = { "d20" };
		rRoll.nMod = ActorManager2.getAbilityBonus(rActor, "constitution");
		
		local sType, nodeActor = ActorManager.getTypeAndNode(rActor);
		local nHP = 0;
		local nWounds = 0;
		if sType == "pc" then
			nHP = DB.getValue(nodeActor, "hp.total", 0);
			nWounds = DB.getValue(nodeActor, "hp.wounds", 0);
		else
			nHP = DB.getValue(nodeActor, "hp", 0);
			nWounds = DB.getValue(nodeActor, "wounds", 0);
		end
			
		if nHP > 0 and nWounds > nHP then
			rRoll.sDesc = string.format("%s [at %+d]", rRoll.sDesc, (nHP - nWounds));
			rRoll.nMod = rRoll.nMod + (nHP - nWounds);
		end
	
	else
		rRoll.aDice = { "d100" };
		if not UtilityManager.isClientFGU() then
			table.insert(rRoll.aDice, "d10");
		end
		rRoll.nMod = 0;
	end
	
	return rRoll;
end

function modStabilization(rSource, rTarget, rRoll)
	if DataCommon.isPFRPG() then
		ActionAbility.modRoll(rSource, rTarget, rRoll);
	end
end

function getStabilizationResult(rRoll)
	local bSuccess = false;
	
	local nTotal = ActionsManager.total(rRoll);

	if DataCommon.isPFRPG() then
		local nFirstDie = 0;
		if #(rRoll.aDice) > 0 then
			nFirstDie = rRoll.aDice[1].result or 0;
		end
		
		if nFirstDie >= 20 or nTotal >= 10 then
			bSuccess = true;
		end
	else
		if nTotal <= 10 then
			bSuccess = true;
		end
	end
	
	return bSuccess;
end

function performConcentrationCheck(draginfo, rActor, nodeSpellClass)
	if DataCommon.isPFRPG() then
		local rRoll = { sType = "concentration", sDesc = "[CONCENTRATION]", aDice = { "d20" } };
	
		local sAbility = DB.getValue(nodeSpellClass, "dc.ability", "");
		local sAbilityEffect = DataCommon.ability_ltos[sAbility];
		if sAbilityEffect then
			rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
		end

		local nCL = DB.getValue(nodeSpellClass, "cl", 0);
		rRoll.nMod = nCL + ActorManager2.getAbilityBonus(rActor, sAbility);
		
		local nCCMisc = DB.getValue(nodeSpellClass, "cc.misc", 0);
		if nCCMisc ~= 0 then
			rRoll.nMod = rRoll.nMod + nCCMisc;
			rRoll.sDesc = string.format("%s (Spell Class %+d)", rRoll.sDesc, nCCMisc);
		end
		
		ActionsManager.performAction(draginfo, rActor, rRoll);
	else
		local sSkill = "Concentration";
		local nValue = 0;

		local sType, nodeActor = ActorManager.getTypeAndNode(rActor);
		if sType == "pc" then
			nValue = CharManager.getSkillValue(rActor, sSkill);
		else
			local sSkills = DB.getValue(nodeActor, "skills", "");
			local aSkillClauses = StringManager.split(sSkills, ",;\r", true);
			for i = 1, #aSkillClauses do
				local nStarts, nEnds, sLabel, sSign, sMod = string.find(aSkillClauses[i], "([%w%s\(\)]*[%w\(\)]+)%s*([%+%-�]?)(%d*)");
				if nStarts and string.lower(sSkill) == string.lower(sLabel) and sMod ~= "" then
					nValue = tonumber(sMod) or 0;
					if sSign == "-" or sSign == "�" then
						nValue = 0 - nValue;
					end
					break;
				end
			end
		end
		
		local sExtra = nil;
		local nCCMisc = DB.getValue(nodeSpellClass, "cc.misc", 0);
		if nCCMisc ~= 0 then
			nValue = nValue + nCCMisc;
			sExtra = string.format("(Spell Class %+d)", nCCMisc);
		end
		
		ActionSkill.performRoll(draginfo, rActor, sSkill, nValue, nil, sExtra);
	end
end
