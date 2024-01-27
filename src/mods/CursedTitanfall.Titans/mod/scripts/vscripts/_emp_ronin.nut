global function Init_ArcTitan_Player

void function Init_ArcTitan_Player()
{
    #if SERVER
    EmpTitans_Init()
    AddCallback_OnPilotBecomesTitan( ApplyEmpField )
    AddCallback_OnTitanBecomesPilot( CleanupEmpField )
    #endif
}

#if SERVER
void function ApplyEmpField( entity player, entity titan)
{
    entity soul = player.GetTitanSoul()
    if ( !player.IsPlayer() || !IsValid(titan) )
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
#endif