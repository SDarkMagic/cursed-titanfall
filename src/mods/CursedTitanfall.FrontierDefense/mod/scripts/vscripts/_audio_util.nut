globalize_all_functions

struct {
    array<string> musicTracksPlaying
} file

void function PlayBossCommsForAllPlayers( string comm )
{
    foreach( entity player in GetPlayerArray() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, comm )
	}
}

void function PlayMusic( string track )
{
	printt( "#################################" )
	printt( "Playing Music" )
	printt( "  Track:", track )
	printt( "#################################" )
	file.musicTracksPlaying.append( track )

	foreach( entity player in GetPlayerArray() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, track )
	}
}

void function StopMusic( float fadeTime = 2.0 )
{
	array<string> tracks = clone file.musicTracksPlaying
	foreach( entity player in GetPlayerArray() )
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

void function StopMusicTrack( string track, float fadeTime = 2.0 )
{
	printt( "#################################" )
	printt( "Stopping music track:", track )
	printt( "#################################" )

	foreach( entity player in GetPlayerArray() )
	{
		//StopSoundOnEntity( player, file.lastMusicTrack )
		FadeOutSoundOnEntity( player, track, fadeTime )
	}

	file.musicTracksPlaying.fastremovebyvalue( track )
}
