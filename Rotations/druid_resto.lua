function druid_resto(self)
	-- INFO --
	-- Shift-key to cast Tree of Life
	-- jps.MultiTarget to Wild Regrowth
	-- Use Innervate and Tranquility manually

	--healer
	local tank = nil
	local me = "player"

	-- Tank is focus.
	tank = jps.findMeATank()

    -- Check if we should cleanse
    local cleanseTarget = nil
    local hasSacredCleansingTalent = 0
    _,_,_,_,hasSacredCleansingTalent = 1 -- GetTalentInfo(1,14) JPTODO: find the resto talent
    if hasSacredCleansingTalent == 1 then
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"},{"Magic"})
    else
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"})
    end

	--Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()

	--Check that the tank isn't going critical, and that I'm not about to die
    if jps.canHeal(tank) and jps.hpInc(tank) <= 0.5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)

	--JPTODO tranquility detection
	
	local spellTable =
	{
		-- rebirth Ctrl-key + mouseover
		{ "rebirth", 			IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("rebirth", "mouseover"), "mouseover" },
		-- 
		{ "barkskin",			jps.hp() < 0.50 },
		{ "tree of life",		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
--		{ "tree of life",		defaultHP < 0.45 and not jps.buff("tree of life") },
		{ "remove corruption",	cleanseTarget~=nil, cleanseTarget },
		{ "lifebloom",			jps.buffDuration("lifebloom",tank) < 3 or jps.buffStacks("lifebloom",tank) < 3, tank },
		{ "swiftmend",			defaultHP < 0.85 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
		{ "wild growth",		defaultHP < 0.95 and jps.MultiTarget, defaultTarget },
		{ "rejuvenation",		defaultHP < 0.95 and not jps.buff("rejuvenation",defaultTarget), defaultTarget },
		{ "rejuvenation",		jps.buffDuration("rejuvenation",tank) < 3, tank },
		{ "regrowth",			defaultHP < 0.55 or jps.buff("clearcasting"), defaultTarget },
		{ "nature's swiftness", defaultHP < 0.40 },
		{ "healing touch", 		(jps.buff("nature's swiftness") or not jps.Moving) and defaultHP < 0.55, defaultTarget },	
		{ "nourish",			defaultHP < 0.85, defaultTarget },
--		{ "nourish",			jps.hpInc(tank) < 0.9 or jps.buffDuration("lifebloom",tank) < 5, tank },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
