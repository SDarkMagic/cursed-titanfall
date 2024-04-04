global function Init_RodeoWeaponSwap

void function Init_RodeoWeaponSwap()
{
    AddOnRodeoStartedCallback( PlayerRodeoBegins )
    AddOnRodeoEndedCallback( PlayerRodeoEnds )
}

void function PlayerRodeoBegins( entity player, entity titan )
{
    if ( !IsValid( player ) || !IsValid( titan ) || !titan.IsTitan() )
        return
    int playerTeam = player.GetTeam()
    int targetTeam = titan.GetTeam()
    bool hasCorrectWeapon = PlayerHasWeapon( player, "mp_weapon_rspn101" )

    if ( playerTeam != targetTeam || !hasCorrectWeapon )
        return

    player.TakeWeaponNow( "mp_weapon_rspn101" )
    player.GiveWeapon( [ "mp_titanweapon_flightcore_rockets", "player_rodeo_weapon" ] )

}

void function PlayerRodeoEnds( entity player, entity titan )
{
    if ( !IsValid( player ) || !IsValid( titan ) || !titan.IsTitan() )
        return
    int playerTeam = player.GetTeam()
    int targetTeam = titan.GetTeam()
    bool hasCorrectWeapon = PlayerHasWeapon( player, "mp_titanweapon_flightcore_rockets" )

    if ( playerTeam != targetTeam || !hasCorrectWeapon )
        return

    player.TakeWeaponNow( "mp_titanweapon_flightcore_rockets" )
    player.GiveWeapon( "mp_weapon_rspn101" )
}