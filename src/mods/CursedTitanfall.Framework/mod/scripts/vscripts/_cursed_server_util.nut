global function IsPlayerAdmin

bool function IsPlayerAdmin( entity player )
{
    string adminUid = GetConVarString( "cs_admin_uid")
    if ( !IsValid( player ) || !player.IsPlayer() )
        return false
    string name = player.GetPlayerName()
    string id = player.GetUID()
    if ( id == adminUid )
        return true
    return false
}