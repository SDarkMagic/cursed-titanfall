globalize_all_functions

struct {
    array<string> musicTracksPlaying
} file

void function PlayBossCommsForAllPlayers( string comm, int team = -1 )
{
	array<entity> players
	if ( team != -1 )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()
    foreach( entity player in players )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, comm )
	}
}

void function PlayMusic( string track, int team = -1 )
{
	printt( "#################################" )
	printt( "Playing Music" )
	printt( "  Track:", track )
	printt( "#################################" )
	file.musicTracksPlaying.append( track )

	array<entity> players
	if ( team != -1 )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()
    foreach( entity player in players )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, track )
	}
}

void function StopMusic_General( float fadeTime = 2.0, int team = -1 )
{
	array<string> tracks = clone file.musicTracksPlaying
	array<entity> players
	if ( team != -1 )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()
    foreach( entity player in players )
	{
		foreach( string track in tracks )
		{
			StopMusicTrack( track, fadeTime )
		}
	}
}

bool function IsMusicTrackPlaying( string track )
{
	return file.musicTracksPlaying.contains( track )
}

void function StopMusicTrack( string track, float fadeTime = 2.0, int team = -1 )
{
	printt( "#################################" )
	printt( "Stopping music track:", track )
	printt( "#################################" )

	array<entity> players
	if ( team != -1 )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()
    foreach( entity player in players )
	{
		//StopSoundOnEntity( player, file.lastMusicTrack )
		FadeOutSoundOnEntity( player, track, fadeTime )
	}

	file.musicTracksPlaying.fastremovebyvalue( track )
}
