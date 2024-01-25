global function GravField_Init
#if SERVER
global function CreateGravFieldOnEnt
#endif

const float MAX_WAIT_TIME = 6.0
const float POP_DELAY = 0.8
const float PULL_DELAY = 2.0
const float PUSH_DELAY = 0.2
const float POP_HEIGHT = 60
const float PULL_RANGE = 250.0
const float PULL_STRENGTH_MAX = 500.0
const float PULL_VERT_VEL = 220
const float PUSH_STRENGTH_MAX = 125.0
const float EXPLOSION_DELAY = 0.1
const float FX_END_CAP_TIME = 1.5

struct
{
	int cockpitFxHandle = -1
} file

const asset GRAVITY_VORTEX_FX = $"P_wpn_grenade_gravity"
const asset GRAVITY_SCREEN_FX = $"P_gravity_mine_FP"

void function GravField_Init()
{
	PrecacheParticleSystem( GRAVITY_VORTEX_FX )
	PrecacheParticleSystem( GRAVITY_SCREEN_FX )
	//RegisterSignal( "GravityMineTriggered" )
	//RegisterSignal( "LeftGravityMine" )

	#if CLIENT
 	//StatusEffect_RegisterEnabledCallback( eStatusEffect.gravity_grenade_visual, GravityScreenFXEnable )
 	//StatusEffect_RegisterDisabledCallback( eStatusEffect.gravity_grenade_visual, GravityScreenFXDisable )
	#endif
}

#if SERVER
void function TriggerWait( entity trig, float maxtime )
{
	trig.CheckForLOS()
	wait maxtime
}

void function SetGravityGrenadeTriggerFilters( entity gravityMine, entity trig )
{
	if ( gravityMine.GetTeam() == TEAM_IMC )
		trig.kv.triggerFilterTeamIMC = "0"
	else if ( gravityMine.GetTeam() == TEAM_MILITIA )
		trig.kv.triggerFilterTeamMilitia = "0"
	trig.kv.triggerFilterNonCharacter = "0"
}

bool function GravityGrenadeTriggerThink( entity gravityMine )
{
	// EmitSoundOnEntity( gravityMine, "SonarGrenade_On" )

	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetRadius( PULL_RANGE )
	trig.SetAboveHeight( PULL_RANGE )
	trig.SetBelowHeight( PULL_RANGE )
	trig.SetAbsOrigin( gravityMine.GetOrigin() )

	SetGravityGrenadeTriggerFilters( gravityMine, trig )

	DispatchSpawn( trig )
	trig.SearchForNewTouchingEntity()

	OnThreadEnd(
		function() : ( trig )
		{
			trig.Destroy()
		}
	)

	//waitthread TriggerWait( trig, MAX_WAIT_TIME )

	return trig.IsTouched()
}

void function CreateGravFieldOnEnt( entity projectile)
{
	projectile.EndSignal( "OnDestroy" )
	WaitFrame()

	vector pullPosition = projectile.GetOrigin()
	entity gravTrig = CreateEntity( "trigger_point_gravity" )
	// pull inner radius, pull outer radius, reduce speed inner radius, reduce speed outer radius, pull accel, pull speed, 0
	gravTrig.SetParams( PULL_RANGE, PULL_RANGE * 2, 32, 128, 2000, 400 )
	gravTrig.SetOrigin( projectile.GetOrigin() )
	//projectile.ClearParent()
	gravTrig.SetParent( projectile )
	gravTrig.RoundOriginAndAnglesToNearestNetworkValue()
    //gravTrig.SetParent(projectile)
	SetTeam( gravTrig, projectile.GetTeam() )
	DispatchSpawn( gravTrig )
	gravTrig.SearchForNewTouchingEntity()

	EmitSoundOnEntity( projectile, "default_gravitystar_impact_3p" )
	entity FX = StartParticleEffectOnEntity_ReturnEntity( projectile, GetParticleSystemIndex( GRAVITY_VORTEX_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
    //	EmitSoundOnEntity( projectile, "gravitystar_vortex" )

	OnThreadEnd(
		function() : ( gravTrig, FX )
		{
			if ( IsValid( gravTrig ) )
				gravTrig.Destroy()
            if ( IsValid( FX ) )
    			EntFireByHandle( FX, "kill", "", FX_END_CAP_TIME, null, null )

		}
	)

	EmitSoundOnEntity( projectile, "weapon_gravitystar_preexplo" )
    AI_CreateDangerousArea( projectile, projectile, PULL_RANGE * 2.0, TEAM_INVALID, true, false )
    //gravTrig.ClearParent()
    while ( true )
    {
        pullPosition = projectile.GetOrigin()
        //trig.SetOrigin( pullPosition )
        gravTrig.SetOrigin( pullPosition )
        gravTrig.RoundOriginAndAnglesToNearestNetworkValue()
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

void function OnGravGrenadeTrigLeave( entity trigger, entity ent )
{
	if ( IsValid( ent ) )
	{
		ent.Signal( "LeftGravityMine" )
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

void function Proto_SetEnemyVelocity_Pull( entity enemy, vector projOrigin )
{
	if ( enemy.IsPhaseShifted() )
		return
	vector enemyOrigin = enemy.GetOrigin()
	vector dir = Normalize( projOrigin - enemy.GetOrigin() )
	float dist = Distance( enemyOrigin, projOrigin )
	float distZ = enemyOrigin.z - projOrigin.z
	vector newVelocity = enemy.GetVelocity() * GraphCapped( dist, 50, PULL_RANGE, 0, 1 ) + dir * GraphCapped( dist, 50, PULL_RANGE, 0, PULL_STRENGTH_MAX ) + < 0, 0, GraphCapped( distZ, -50, 0, PULL_VERT_VEL, 0 )>
	if ( enemy.IsTitan() )
		newVelocity.z = 0
	enemy.SetVelocity( newVelocity )
}

array<entity> function GetNearbyEnemiesForGravGrenade( entity projectile )
{
	int team = projectile.GetTeam()
	entity owner = projectile.GetOwner()
	vector origin = projectile.GetOrigin()
	array<entity> nearbyEnemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, PULL_RANGE )
	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( IsEnemyTeam( team, guy.GetTeam() ) || (IsValid( owner ) && guy == owner) )
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

array<entity> function GetNearbyProjectilesForGravGrenade( entity gravGrenade )
{
	int team = gravGrenade.GetTeam()
	entity owner = gravGrenade.GetOwner()
	vector origin = gravGrenade.GetOrigin()

	array<entity> projectiles = GetProjectileArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, PULL_RANGE )

	array<entity> affectedProjectiles

	entity projectileOwner
	foreach( projectile in projectiles )
	{
		if ( projectile == gravGrenade )
			continue

		projectileOwner = projectile.GetOwner()
		if ( IsEnemyTeam( team, projectile.GetTeam() ) || ( IsValid( projectileOwner ) && projectileOwner == owner ) )
			affectedProjectiles.append( projectile )
	}

	return affectedProjectiles
}
#endif
