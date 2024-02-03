global function Init_UpgradeCore_Callbacks

void function Init_UpgradeCore_Callbacks()
{
    printt("Initializing Custom titan callback functions...")
    #if SERVER
	AddCallback_OnPrimaryAttackPlayer_titancore_upgrade( ReaperJumpscare )
    AddCallback_OnPrimaryAttackPlayer_titancore_upgrade( SwapUtility )
    AddCallback_OnPrimaryAttackPlayer_titancore_upgrade( EnhanceMissileRackUpgrade_UpgradeCore )
    AddCallback_OnPilotBecomesTitan( EnhanceMissileRackUpgrade ) // Super hacky way of doing this, but should ensure the apex upgrade also gets the effect
    #endif
}

#if SERVER
void function ReaperJumpscare( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int currentUpgradeCount = GetCurrentUpgrade_FromWeapon( weapon )
	entity owner = weapon.GetWeaponOwner()
	if (currentUpgradeCount >= 2){
			entity reaper = CreateNPC( "npc_super_spectre", GetOtherTeam(owner.GetTeam()), owner.GetOrigin(), owner.GetAngles() )
			DispatchSpawn(reaper)
			if ( owner.IsPlayer() )
				NSSendPopUpMessageToPlayer(owner, "Dodge! :)")
                EmitSoundOnEntityOnlyToPlayer( owner, owner, "diag_sp_bossFight_STS676_08_01_imc_viper")
			thread SuperSpectre_WarpFall(reaper)
		}
}

void function SwapUtility( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity owner = weapon.GetWeaponOwner()
    entity soul = owner.GetTitanSoul()
    int currentUpgradeCount = GetCurrentUpgrade_FromWeapon( weapon )
    if ( !IsValid( soul ) || currentUpgradeCount < 1 )
        return
    if ( SoulHasPassive( soul, ePassives.PAS_VANGUARD_CORE4 ) && IsValid( owner ) )  // Rapid Rearm
    {
        entity offhandWeaponUtility = owner.GetOffhandWeapon( OFFHAND_ANTIRODEO )
        array<string> mods = []
        offhandWeaponUtility.SetMods( mods )
        owner.TakeOffhandWeapon( OFFHAND_ANTIRODEO ) // Take utility weapon
        owner.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_ANTIRODEO ) // Give northstar hover ability instead

    }
}

void function EnhanceMissileRackUpgrade_UpgradeCore( entity weapon, WeaponPrimaryAttackParams attackParams)
{
    entity owner = weapon.GetWeaponOwner()
    entity soul = owner.GetTitanSoul()
    if ( !IsValid( soul ) )
        return
    EnhanceMissileRackUpgrade( owner, soul )
}

void function EnhanceMissileRackUpgrade( entity owner, entity soul )
{
    // give the rapid rearm/reload as a default for missile racks. This passive function will be overwritten by a callback that swaps the utility weapon
    entity titan = soul
    entity weapon = owner.GetOffhandWeapon( OFFHAND_EQUIPMENT )
    int currentUpgradeCount = GetCurrentUpgrade_FromWeapon( weapon )
    if ( !IsValid( soul ) || currentUpgradeCount != 0)
        return
    entity offhandWeaponUtility = owner.GetOffhandWeapon( OFFHAND_ANTIRODEO )
    entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_RIGHT )
    if ( !IsValid( offhandWeapon ) )
        return
    if ( !offhandWeapon.HasMod( "missile_racks" ) )
        return

    if ( IsValid( offhandWeaponUtility ) )
    {
        array<string> mods = offhandWeaponUtility.GetMods()
        mods.append( "rapid_rearm" )
        offhandWeaponUtility.SetMods( mods )
    }
    array<entity> weapons = GetPrimaryWeapons( owner )
    if ( weapons.len() > 0 )
    {
        entity primaryWeapon = weapons[0]
        if ( IsValid( primaryWeapon ) )
        {
            array<string> mods = primaryWeapon.GetMods()
            mods.append( "rapid_reload" )
            primaryWeapon.SetMods( mods )
        }
    }
}

int function GetCurrentUpgrade_FromWeapon( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	entity soul = owner.GetTitanSoul()
	return soul.GetTitanSoulNetInt( "upgradeCount" )
}
#endif