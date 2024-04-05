global function Init_Ronin

const PARRY_WINDOW = 1.0
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
        DamageInfo_SetDamage( damageInfo, 0 )
        entity attacker = DamageInfo_GetAttacker( damageInfo )
        entity soul = attacker.GetTitanSoul()
        if( !attacker.IsTitan() || !IsValid( soul ))
            return
        soul.EnableDoomed()
        thread DoSyncedMelee( player, attacker )
    }
}

#endif