global function InitGeneralTitanFunctions

const float PULL_RANGE = 1500.0 // Double the default player nuclear explosion outerRadius of 750
const float PULL_STRENGTH_MAX = 1000.0
const float FX_END_CAP_TIME = 1.5

const asset GRAVITY_VORTEX_FX = $"P_wpn_grenade_gravity"
const asset GRAVITY_SCREEN_FX = $"P_gravity_mine_FP"

void function InitGeneralTitanFunctions()
{
    PrecacheParticleSystem( GRAVITY_VORTEX_FX )
	PrecacheParticleSystem( GRAVITY_SCREEN_FX )
    #if SERVER
    AddCallback_OnTitanVsTitan3p_ShouldGiveBattery( RoninExecutionGivesBatt )
    AddCallback_OnPilotBecomesTitan( GiveDevSword )
    AddCallback_OnPilotBecomesTitan( Enable_NuclearGravField )
    //AddCallback_OnPilotBecomesTitan( WarnNorthstarBug )
    #endif
}

#if SERVER

bool function RoninExecutionGivesBatt( entity attacker, entity target )
{
	if ( attacker.IsPlayer() )
	{
        string titanName = GetTitanCharacterName( attacker )
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

void function GiveDevSword( entity player, entity titan )
{
    if ( !IsValid( player ) || !player.IsPlayer() )
        return
    if ( !IsPlayerAdmin( player ) || GetTitanCharacterName( titan ) == "ronin" )
        return
    entity meleeWeapon = player.GetOffhandWeapon( OFFHAND_MELEE )
    if ( IsValid( meleeWeapon ) )
    {
        player.TakeOffhandWeapon( OFFHAND_MELEE )
        player.GiveOffhandWeapon( "melee_titan_sword", OFFHAND_MELEE )
    }
}

void function Enable_NuclearGravField( entity player, entity titan )
{
    if( !IsValid( player ) || !IsValid( titan ) )
        return
    entity soul = player.GetTitanSoul()
    if ( !IsValid( soul ) )
        return
    if ( GetSoulTitanSubClass( soul ) != "ogre" )
        return // Only run continue if the player is not running scorch or legion
    if ( !( GetNuclearPayload > 0 ) )
        return // Make sure the player is also running nuclear payload
    thread EjectCallback( player, soul )
}


void function EjectCallback( entity player, entity soul )
{
    soul.EndSignal( "OnDeath")
    soul.EndSignal( "OnDestroy" )
    soul.EndSignal( "PlayerDisembarkedTitan" )

    player.WaitSignal( "TitanEjectionStarted" )
    thread CreateGravFieldOnTitan( soul.GetTitan(), soul )
}

// Gravity Field creation and attachment functions

void function CreateGravFieldOnTitan( entity titan, entity soul )
{
	soul.EndSignal( "OnDestroy" )
    soul.EndSignal( "OnDeath" )
    printt( "Creating grav field" )
	WaitFrame()
	array<entity> nearbyEnemies
	vector pullPosition = titan.GetOrigin()

	EmitSoundOnEntity( soul, "default_gravitystar_impact_3p" )
	entity FX = StartParticleEffectOnEntity_ReturnEntity( soul, GetParticleSystemIndex( GRAVITY_VORTEX_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	OnThreadEnd(
		function() : ( FX )
		{
            printt( "Finalizing Grav field" )
            if ( IsValid( FX ) )
    			EntFireByHandle( FX, "kill", "", FX_END_CAP_TIME, null, null )

		}
	)

	EmitSoundOnEntity( soul, "weapon_gravitystar_preexplo" )
    AI_CreateDangerousArea( FX, soul, PULL_RANGE * 2.0, TEAM_INVALID, true, false )
    while ( true )
    {
        printt( "Pulling enemies to ", pullPosition )
        if ( !titan.IsTitan() && IsValid( soul ) )
            titan = soul.GetTitan()
		nearbyEnemies = GetNearbyEnemiesForGravGrenade( titan )
		foreach ( enemy in nearbyEnemies )
		{
			Proto_SetEnemyVelocity_Pull( enemy, titan.GetOrigin() )
		}
        pullPosition = titan.GetOrigin()
        WaitFrame()
    }
}

void function OnGravGrenadeTrigEnter( entity trigger, entity ent )
{
	if ( ent.GetTeam() == trigger.GetTeam() ) // trigger filters handle this except in FFA
		return

	if ( ent.IsNPC() && ( IsGrunt( ent ) || IsSpectre( ent ) || IsStalker( ent ) ) && IsAlive( ent ) && !ent.ContextAction_IsActive() && ent.IsInterruptable() )
	{
		ent.ContextAction_SetBusy()
		ent.Anim_ScriptedPlayActivityByName( "ACT_FALL", true, 0.2 )

		if ( IsGrunt( ent ) )
			EmitSoundOnEntity( ent, "diag_efforts_gravStruggle_gl_grunt_3p" )

		thread EndNPCGravGrenadeAnim( ent )
	}
}

void function EndNPCGravGrenadeAnim( entity ent )
{
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnAnimationInterrupted" )
	ent.EndSignal( "OnAnimationDone" )

	ent.WaitSignal( "LeftGravityMine", "OnDeath" )

	ent.ContextAction_ClearBusy()
	ent.Anim_Stop()
}

void function Proto_SetEnemyVelocity_Pull( entity enemy, vector origin )
{
	if ( enemy.IsPhaseShifted() )
		return
	vector enemyOrigin = enemy.GetOrigin()
	vector dir = Normalize( origin - enemy.GetOrigin() )
	float dist = Distance( enemyOrigin, origin )
	float distZ = enemyOrigin.z - origin.z
	vector newVelocity = enemy.GetVelocity() * GraphCapped( dist, 25, PULL_RANGE, 0, 1 ) + dir * GraphCapped( dist, 25, PULL_RANGE, 0, PULL_STRENGTH_MAX )
	if ( enemy.IsTitan() )
		newVelocity.z = 0
	enemy.SetVelocity( newVelocity )
}

array<entity> function GetNearbyEnemiesForGravGrenade( entity projectile )
{
	int team = projectile.GetTeam()
	vector origin = projectile.GetOrigin()
	array<entity> nearbyEnemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, PULL_RANGE )

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( IsEnemyTeam( team, guy.GetTeam() ) )
			nearbyEnemies.append( guy )
	}

	array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, team, origin, PULL_RANGE )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			nearbyEnemies.append( guy )
	}

	return nearbyEnemies
}
#endif