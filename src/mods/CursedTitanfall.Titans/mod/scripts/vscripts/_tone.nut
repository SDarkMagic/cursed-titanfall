global function Init_Tone

const int SONAR_PULSE_RADIUS = 650
const float SONAR_PULSE_DURATION = 1.5
const float FD_SONAR_PULSE_DURATION = 3.0

void function Init_Tone()
{
    #if SERVER
    AddCallback_OnPrimaryAttackPlayer_titanweapon_40mm( Pulse_OnPrimaryWeaponFire )
    #endif
}

#if SERVER
void function Pulse_OnPrimaryWeaponFire( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity owner = weapon.GetOwner()
    if ( !IsValid( owner ) )
        return

    int team = owner.GetTeam()
    array<string> mods = weapon.GetMods()
    bool hasDamageAmp = mods.contains( "fd_sonar_damage_amp" )
    PulseLocation_Moving( owner, team, owner.GetOrigin(), false, hasDamageAmp )
    return
}

// Copied from mp_titanability_sonar_pulse then modified so it can track the player's origin and also have custom duration and radius
void function PulseLocation_Moving( entity owner, int team, vector pos, bool hasIncreasedDuration, bool hasDamageAmp )
{
	array<entity> nearbyEnemies = GetNearbyEnemiesForSonarPulse( team, pos )
	foreach( enemy in nearbyEnemies )
	{
		thread SonarPulseThink( enemy, pos, team, owner, hasIncreasedDuration, hasDamageAmp )
		ApplyTrackerMark( owner, enemy )
	}
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseFromPosition", pos.x, pos.y, pos.z, SONAR_PULSE_RADIUS, 1.0, hasDamageAmp )
	}
}

void function SonarPulseThink( entity enemy, vector position, int team, entity sonarOwner, bool hasIncreasedDuration, bool hasDamageAmp )
{
	enemy.EndSignal( "OnDeath" )
	enemy.EndSignal( "OnDestroy" )

	int statusEffect = 0
	if ( hasDamageAmp )
		statusEffect = StatusEffect_AddEndless( enemy, eStatusEffect.damage_received_multiplier, 0.25 )
	SonarStart( enemy, position, team, sonarOwner )

	int sonarTeam = sonarOwner.GetTeam()
	IncrementSonarPerTeam( sonarTeam )

	OnThreadEnd(
	function() : ( enemy, sonarTeam, statusEffect, hasDamageAmp )
		{
			DecrementSonarPerTeam( sonarTeam )
			if ( IsValid( enemy ) )
			{
				SonarEnd( enemy, sonarTeam )
				if ( hasDamageAmp )
					StatusEffect_Stop( enemy, statusEffect )
			}
		}
	)

	float duration
	if ( hasIncreasedDuration )
		duration = FD_SONAR_PULSE_DURATION
	else
		duration = SONAR_PULSE_DURATION

	wait duration
}

array<entity> function GetNearbyEnemiesForSonarPulse( int team, vector origin )
{
	array<entity> nearbyEnemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, SONAR_PULSE_RADIUS )
	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( IsEnemyTeam( team, guy.GetTeam() ) )
			nearbyEnemies.append( guy )
	}

	array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, team, origin, SONAR_PULSE_RADIUS )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			nearbyEnemies.append( guy )
	}

	if ( GAMETYPE == FORT_WAR )
	{
		array<entity> harvesters = GetEntArrayByScriptName( "fw_team_tower" )
		foreach ( harv in harvesters )
		{
			if ( harv.GetTeam() == team )
				continue

			if ( Distance( origin, harv.GetOrigin() ) < SONAR_PULSE_RADIUS )
			{
				nearbyEnemies.append( harv )
			}
		}
	}

	return nearbyEnemies
}
#endif