// TODO: Add function to spawn cloak drone and parent it to player titan. Follow position of player. If the drone dies, wait X duration before respawning a new one.
global function Init_Northstar

struct {
    table<entity, entity> playerCloakDrones
} file

void function Init_Northstar()
{
    #if SERVER
    //AddCallback_OnTitanGetsNewTitanLoadout( ApplyPassiveOnLoadoutUpdate )
    AddCallback_OnPilotBecomesTitan( CreateChildCloaker )
    AddCallback_OnTitanBecomesPilot( CleanupChildCloaker )
    #endif
}

#if SERVER
void function ApplyPassiveOnLoadoutUpdate( entity titan, TitanLoadoutDef loadout )
{
    entity soul = titan.GetTitanSoul()
    entity owner = titan.GetOwner()
	if ( loadout.titanClass != "northstar" || !IsValid( soul ) || !titan.IsTitan() )
		return
    //CreateChildCloaker( titan )
    printt("Creating cloaker drone")
}

void function CreateChildCloaker( entity player, entity titan )
{
    if ( !IsValid( titan )  || !IsValid( player ) )
        return
    entity soul = player.GetTitanSoul()
    if ( soul.IsDoomed() || GetTitanCharacterName( titan ) != "northstar" )
        return
    entity drone = SpawnPlayerCloakDrone( titan.GetTeam(), titan.GetOrigin(), titan.GetAngles(), player )
    file.playerCloakDrones[player] <- drone
    printt(drone)
    thread RespawnDroneAfterDeath( drone, player, titan )
}

void function RespawnDroneAfterDeath( entity drone, entity player, entity titan )
{
    drone.EndSignal( "OnDestroy" )

    drone.WaitSignal( "OnDeath" )
    wait 10.0
    if ( !IsAlive( drone ) )
        CreateChildCloaker( player, titan )
    return
}

void function CleanupChildCloaker( entity player, entity titan )
{
    if ( !IsValid( titan )  || !IsValid( player ) )
        return
    entity soul = player.GetTitanSoul()
    if ( GetTitanCharacterName( titan ) != "northstar" ) // Add a check for the player entity in file here as well later
        return
    entity drone = file.playerCloakDrones[player]
    if ( IsValid( drone ) )
        drone.Destroy()
}
#endif