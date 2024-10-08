// TODO: Add function to spawn cloak drone and parent it to player titan. Follow position of player. If the drone dies, wait X duration before respawning a new one.
untyped
global function Init_Northstar

const DRONE_TIMEOUT = 30.0

void function Init_Northstar()
{
    #if SERVER
    //AddCallback_OnPilotBecomesTitan( CreateChildCloaker )
    //AddCallback_OnTitanBecomesPilot( CleanupChildCloaker )
    AddCallback_OnWeaponPrimaryAttack_titanability_smoke( CreateCloakDrone_For_Callback )
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
    if ( GetTitanCharacterName( titan ) != "northstar" )
        return
    entity drone = SpawnPlayerCloakDrone( titan.GetTeam(), titan.GetOrigin(), titan.GetAngles(), player )
    SetPlayerCloakedDrone( player, drone )
    printt(drone)
}

void function CleanupChildCloaker( entity player, entity titan )
{
    if ( !IsValid( titan )  || !IsValid( player ) )
        return
    if ( !( "cloakedDrone" in player.s ) )
        return
    entity drone = expect entity( GetPlayerCloakedDrone( player ) )
    if ( IsValid( drone ) )
        drone.Destroy()
}

void function CreateCloakDrone_For_Callback( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity player = weapon.GetWeaponOwner()
    entity soul = player.GetTitanSoul()
    if( !IsValid( soul ) )
        return

    entity titan = soul.GetTitan()
    if ( !IsValid( titan ) || !IsAlive( titan ) )
        return

    CreateChildCloaker_Timed( player, titan, DRONE_TIMEOUT )
}

void function CreateChildCloaker_Timed( entity player, entity titan, float timeout )
{
    // Need a couple helper functions to thread off of this that wait for timeout then destroy the drone
    var playerDrone = GetPlayerCloakedDrone( player )
    if( playerDrone == null )
    {
        if ( !IsValid( titan )  || !IsValid( player ) )
            return
        if ( GetTitanCharacterName( titan ) != "northstar" )
            return
        entity drone = SpawnPlayerCloakDrone( titan.GetTeam(), titan.GetOrigin(), titan.GetAngles(), player )
        SetPlayerCloakedDrone( player, drone )
        printt(drone)
        printt("Creating timed cloaker drone")
        PlayerCloakedDrone_WarpIn( drone )
    }
    entity drone = expect entity( GetPlayerCloakedDrone( player ) )
    thread Timeout_KillChildCloaker( player, titan, timeout )
}

void function Timeout_KillChildCloaker( entity player, entity titan, float timeout)
{
    wait timeout
    KillChildCloaker( player )
}

void function KillChildCloaker( entity player )
{
    if ( !IsValid( player ) )
        return
    if ( !( "cloakedDrone" in player.s ) )
        return

    entity drone = expect entity( GetPlayerCloakedDrone( player ) )
    if( !IsAlive( drone ) || !IsValid( drone ) )
        return
    PlayerCloakedDrone_WarpOut( drone )
    if( !IsAlive( drone ) || !IsValid( drone ) )
        return // Drone can be killed during the warpout sequence
    drone.Destroy()
    player.s.cloakedDrone = null
}



// Basic getter helper function to fetch the associated player's cloak drone entity from the player entity
var function GetPlayerCloakedDrone( entity player )
{
    if ( ( "cloakedDrone" in player.s ) )
		return player.s.cloakedDrone
	else
        return null
}

// Basic setter helper function to set a player entity's associated cloak drone
void function SetPlayerCloakedDrone( entity player, entity drone )
{
    if ( !( "cloakedDrone" in player.s ) )
		player.s.cloakedDrone <- null
	player.s.cloakedDrone = drone
}
#endif