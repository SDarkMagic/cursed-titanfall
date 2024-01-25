global function Init_ArcTitan_Player

void function Init_ArcTitan_Player()
{
    #if SERVER
    EmpTitans_Init()
    AddCallback_OnPilotBecomesTitan( ApplyEmpField )
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
#endif