global function Init_FD_TeamSwap

void function Init_FD_TeamSwap()
{
    if( GameRules_GetGameMode() == FD )
    {
        AddCallback_OnClientConnected( SetTeam_Random )
        AddCallback_OnReceivedSayTextMessage( ForceSwitch_Militia )
    }
}

void function SetTeam_Random( entity player )
{
    printt( "Player connected...", player)
    int currentPlayerCount_Militia = GetPlayerArrayOfTeam( TEAM_MILITIA ).len()
    string playlistName = GetCurrentPlaylistName()
    int maxPlayers = GetMaxPlayersForPlaylistName( playlistName )
    int chance = 2 * ( maxPlayers - currentPlayerCount_Militia )
    if ( currentPlayerCount_Militia <= 1 || chance <= 1)
        return
    if ( RandomInt( chance ) == 1 && GetPlayerArrayOfTeam( TEAM_IMC ).len() < 1 )
    {
        return
        printt("Swapping player's team", player)
        SetTeam( player, TEAM_IMC )
        //NSSendAnnouncementMessageToPlayer( player, "You have been randomly assigned to the enemy team.", "If you would like to defend the harvester, send '!switch' in the chat", <1,1,0>, 1, 1 )
    }
}

ClServer_MessageStruct function ForceSwitch_Militia( ClServer_MessageStruct message )
{
    int team = message.player.GetTeam()
    printt( "Received switch command", message.player )
    if ( team != TEAM_IMC )
        return message
    if ( message.message.find( "!switch" ) )
    {
        entity player = message.player
        SetTeam( player, TEAM_MILITIA )
    }
    return message
}