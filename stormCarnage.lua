Storm = {}

Storm.optionEnable = Menu.AddOptionBool({"Hero Specific", "Storm Spirit"}, "Auto Remnant", "Auto cast remnant if there's an enemy in range"), "Combo Key", Enum.ButtonCode.KEY_7)
Storm.optionAutoVortex = Menu.AddOptionBool({"Hero Specific", "Storm Spirit"}, "Auto Vortex", "Auto vortex any enemy in range"), "Combo Key", Enum.ButtonCode.KEY_6)
Storm.optionAttackHelper = Menu.AddOptionBool({"Hero Specific", "Storm Spirit"}, "Attack Helper", "When right click enemy, auto bolt to maximize damage"), "Enable", false)

 target
 hasAttacked = true

function Storm.OnPrepareUnitOrders(orders)
    if not orders then return true end
    target = orders.target
    return true
end

function Storm.OnProjectile(projectile)
    if not projectile then return end

 myHero = Heroes.GetLocal()
    if not myHero then return end

    if projectile.isAttack and projectile.source == myHero then
        hasAttacked = true
    end
end

function Storm.OnUpdate()
    if Menu.IsEnabled(optionAutoRemnant) then
        Storm.AutoRemnant()
    end

    if Menu.IsEnabled(optionAutoVortex) then
        Storm.AutoVortex()
    end

    if Menu.IsEnabled(optionAttackHelper) then
        Storm.AttackHelper()
    end
end

function Storm.AutoRemnant()
     myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

     spell = NPC.GetAbility(myHero, "storm_spirit_static_remnant")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    radius = 200 -- 235, 260

    for i = 1, Heroes.Count() do
         enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, radius) then

            Ability.CastNoTarget(spell)
            return
        end
    end
end

function Storm.AutoVortex()
     myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

     spell = NPC.GetAbility(myHero, "storm_spirit_electric_vortex")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
         enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) and not Utility.IsLinkensProtected(enemy) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function Storm.AttackHelper()
     myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

     spell = NPC.GetAbility(myHero, "storm_spirit_ball_lightning")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    if not target or Entity.IsSameTeam(myHero, target) or not Entity.IsHero(target) then return end
    if not Utility.CanCastSpellOn(target) then return end

    -- 50 + 75 * Ability.GetLevel(spell) -- Damage Radius: 125/200/275
    radius = 60 -- 60 seems to be an optimal value.
     dir = Entity.GetAbsRotation(target):GetForward():Normalized()
     front_pos = Entity.GetAbsOrigin(target) + dir:Scaled(radius)
     back_pos = Entity.GetAbsOrigin(target) - dir:Scaled(radius)

    if hasAttacked and (not NPC.IsEntityInRange(myHero, target, NPC.GetAttackRange(myHero))
    or not NPC.HasModifier(myHero, "modifier_storm_spirit_overload_debuff")) then

        if (Entity.GetAbsOrigin(myHero) - front_pos):Length2D() < radius then
            Ability.CastPosition(spell, back_pos)
        else
            Ability.CastPosition(spell, front_pos)
        end

        hasAttacked = false
    end

    Player.AttackTarget(Players.GetLocal(), myHero, target)
end

return Storm

