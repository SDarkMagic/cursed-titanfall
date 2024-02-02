global function InitGeneralTitanFunctions

void function InitGeneralTitanFunctions()
{
    #if SERVER
    AddCallback_OnTitanVsTitan3p_ShouldGiveBattery( RoninExecutionGivesBatt )
    AddCallback_OnPilotBecomesTitan( WarnNorthstarBug )
    #endif
}

#if SERVER

bool function RoninExecutionGivesBatt( entity attacker, entity target )
{
	if ( attacker.IsPlayer() )
	{
        string titanName = GetTitanCharacterName( attacker )
		printt(titanName)
		switch (titanName)
		{
			case "ronin":
				return true
		}
	}
    return false
}

void function WarnNorthstarBug( entity player, entity titan )
{
    entity soul = player.GetTitanSoul()
    string bugWarning = "The Viper thrusters kit is currently buggy, and can cause you to become stuck in the air when using flight core. It is recommended that you change kits."
    if ( !IsValid( player ) || !IsValid( titan ) || !IsValid( soul ) )
        return
    if ( !SoulHasPassive( soul, ePassives.PAS_NORTHSTAR_FLIGHTCORE) )
        return
    NSSendAnnouncementMessageToPlayer( player, "Warning", bugWarning, <1,1,0>, 1, 1 )
}
#endif