global function Init_Ronin

const PARRY_WINDOW = 1.0
array<string> invalidParryTargetScriptNames = [
    "Ash",
    "Viper",
    "Kane",
    "Blisk",
    "Richter",
    "Slone"
]
struct {
    table<entity, bool> inParryWindow
} file

void function Init_Ronin()
{
    #if SERVER
    EmpTitans_Init()
    AddCallback_OnWeaponActivate_titanability_basic_block( BeginParryWindow_Threaded )
    AddCallback_OnWeaponDeactivate_titanability_basic_block( EndParryWindow )
    AddCallback_IsValidMeleeExecutionTarget( IsTerminationValid_While_InParry )
    AddCallback_OnPilotBecomesTitan( ApplyEmpField )
    AddCallback_OnTitanBecomesPilot( CleanupEmpField )
    AddCallback_OnPilotBecomesTitan( EnableParrying_ForPlayer )
    AddCallback_OnTitanBecomesPilot( CleanupParrying_ForPlayer )
    #endif
}

#if SERVER
void function ApplyEmpField( entity player, entity titan )
{
    entity soul = player.GetTitanSoul()
    if ( !player.IsPlayer() || !IsValid(titan) )
        return
    if ( soul.IsDoomed() )
        return
    entity ordinanceWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
    if ( !ordinanceWeapon.HasMod( "pas_ronin_arcwave" ) )
        return
    thread PlayerEMPTitanThinkConstant( soul )
}

void function CleanupEmpField( entity player, entity titan )
{
    entity soul = titan.GetTitanSoul()
    if ( !IsValid(titan) )
        return
    entity ordinanceWeapon = titan.GetOffhandWeapon( OFFHAND_RIGHT )
    if ( !ordinanceWeapon.HasMod( "pas_ronin_arcwave" ) )
        return
    soul.Signal( "StopEMPField" )
}

void function EnableParrying_ForPlayer( entity player, entity titan )
{
    if ( !player.IsPlayer() || !IsValid(titan) )
        return
    if ( GetTitanCharacterName( titan ) == "ronin" )
        AddEntityCallback_OnDamaged( player, PerformParry )
}

void function CleanupParrying_ForPlayer( entity player, entity titan )
{
    if ( !player.IsPlayer() || !IsValid(titan) )
        return
    if ( GetTitanCharacterName( titan ) == "ronin" )
        RemoveEntityCallback_OnDamaged( player, PerformParry )
}

void function BeginParryWindow_Threaded( entity weapon )
{
    thread BeginParryWindow( weapon )
}

void function BeginParryWindow( entity weapon )
{
    entity owner = weapon.GetWeaponOwner()
    if ( !IsValid( owner ) || !owner.IsPlayer() || !owner.IsTitan() )
        return
    file.inParryWindow[ owner ] <- true
    printt("Beginning parry window")
    wait PARRY_WINDOW
    if ( !file.inParryWindow[ owner ] )
        return
    file.inParryWindow[ owner ] <- false
    printt("Parry window closed due to timeout")
}

void function EndParryWindow( entity weapon )
{
    entity owner = weapon.GetWeaponOwner()
    if ( !IsValid( owner ) || !owner.IsPlayer() || !owner.IsTitan() )
        return
    if ( !file.inParryWindow[ owner ] )
        return
    file.inParryWindow[ owner ] <- false
    printt("Parry window force closed by user")
}

bool function IsTerminationValid_While_InParry( entity attacker, entity target )
{
    // Returns false if the target is able to be executed, meaning it is no longer within the parry window
    if ( !IsValid( target ) || !target.IsTitan() || !target.IsPlayer() )
        return true
    if ( !target.e.blockActive || GetTitanCharacterName( target ) != "ronin" )
        return true
    if ( !file.inParryWindow[ target ] )
        return true
    return false
}

void function PerformParry( entity player, var damageInfo )
{
    int dmgFlags = DamageInfo_GetCustomDamageType( damageInfo )
    if( !IsValid( player ) || !player.IsPlayer() || !player.IsTitan() )
        return
    if( !player.e.blockActive || !file.inParryWindow[ player ] )
        return
    printt("Initial checks passed for parry")
    if ( dmgFlags & DF_MELEE )
    {
        // Always negate the damage when the player performs a parry regardless of core charge
        DamageInfo_SetDamage( damageInfo, 0 )
        entity attacker = DamageInfo_GetAttacker( damageInfo )
        ForceTermination( player, attacker )
    }
}

void function ForceTermination( entity player, entity target )
{
    entity soul = player.GetTitanSoul()
    entity targetSoul = target.GetTitanSoul()

    if( !IsValid( soul ) || !IsValid( targetSoul ) )
        return

    string targetScriptName = target.GetScriptName()
    float coreChargeFrac = SoulTitanCore_GetNextAvailableTime( soul )
    if( coreChargeFrac < 0.25 || invalidParryTargetScriptNames.find( targetScriptName ) != -1 ) // Second check prevents parries from working on the boss titans
        return

    targetSoul.EnableDoomed()
    float coreFrac = 0.25 + GetCurrentPlaylistVarFloat( "battery_core_frac", 0.2 ) // Always remove 25% core from what the player had when performing the execution accounting for core regen from batt
    RemoveCreditFromTitanCoreBuilder( player, coreFrac ) // Add a negative amount of core buildup to the player in order to perform the forced execution
    thread DoSyncedMelee( player, target )
}

// Modified variant of the function AddCreditToTitanCoreBuilder found in titan/_titan_health.nut
void function RemoveCreditFromTitanCoreBuilder( entity titan, float credit )
{
	Assert( TitanDamageRewardsTitanCoreTime() )

	entity soul = titan.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	entity bossPlayer = soul.GetBossPlayer()

	if ( titan.IsPlayer() )
	{
		if ( !IsValid( bossPlayer ) )
			return

		if ( bossPlayer.IsTitan() && TitanCoreInUse( bossPlayer ) )
			return
	}
	else
	{
		Assert( titan.IsNPC() )
		if ( TitanCoreInUse( titan ) )
			return
	}

	if ( !IsAlive( titan ) )
		return

	bool coreWasAvailable = false

	if ( IsValid( bossPlayer ) )
		coreWasAvailable = IsCoreChargeAvailable( bossPlayer, soul )

	float oldTotalCredit = SoulTitanCore_GetNextAvailableTime( soul )
	float newTotalCredit = (oldTotalCredit - credit > 0.0 ? oldTotalCredit - credit : 0.0)
	if ( newTotalCredit >= 0.998 ) //JFS - the rui has a +0.001 for showing the meter as full. This fixes the case where the core meter displays 100 but can't be fired.
		newTotalCredit = 1.0
	SoulTitanCore_SetNextAvailableTime( soul, newTotalCredit )

	if ( IsValid( bossPlayer ) && !coreWasAvailable && IsCoreChargeAvailable( bossPlayer, soul ) )
	{
		AddPlayerScore( bossPlayer, "TitanCoreEarned", bossPlayer ) // this will show the "Core Earned" callsign event
		#if MP
			UpdateTitanCoreEarnedStat( bossPlayer, titan )
			PIN_PlayerAbilityReady( bossPlayer, "core" )
		#endif
	}

	#if MP
	if ( IsValid( bossPlayer ) )
		JFS_PlayerEarnMeter_CoreRewardUpdate( titan, oldTotalCredit, newTotalCredit )
	#endif

	#if HAS_TITAN_TELEMETRY
	if ( titan.IsPlayer() )
	{
		if ( IsCoreChargeAvailable( titan, soul ) )
		{
			TitanHints_TryShowHint( titan, [OFFHAND_EQUIPMENT] )
		}
	}
	#endif
}

#endif