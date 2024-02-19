global function Init_Scorch

const asset DAMAGE_AREA_MODEL = $"models/fx/xo_shield.mdl"
const float SLOW_TRAP_RADIUS = 440
const asset TOXIC_FUMES_FX 	= $"P_meteor_trap_gas"
const asset TOXIC_FUMES_S2S_FX 	= $"P_meteor_trap_gas_s2s"
const asset FIRE_CENTER_FX = $"P_meteor_trap_center"
const asset BARREL_EXP_FX = $"P_meteor_trap_EXP"
const asset FIRE_LINES_FX = $"P_meteor_trap_burn"
const asset FIRE_LINES_S2S_FX = $"P_meteor_trap_burn_s2s"
const float FIRE_TRAP_MINI_EXPLOSION_RADIUS = 150
const float FIRE_TRAP_LIFETIME = 10.5
const int GAS_FX_HEIGHT = 45

struct {
    table<entity, bool> hasUsedPhoenix
} file

void function Init_Scorch()
{
    #if SERVER
    RegisterWeaponDamageSource( "mp_titanweapon_phoenix_trap", "Phoenix Burst" )
    AddCallback_OnTitanGetsNewTitanLoadout( ApplyPassiveOnLoadoutUpdate )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_phoenix_trap, FireTrap_DamagedPlayerOrNPC )
    AddCallback_OnTitanDoomed( PlayerScorchBecomesDoomed )
    #endif
}

#if SERVER
void function ApplyPassiveOnLoadoutUpdate( entity titan, TitanLoadoutDef loadout )
{
    entity soul = titan.GetTitanSoul()
    entity owner = titan.GetOwner()
	if ( loadout.titanClass != "scorch" || !IsValid( soul ) || !titan.IsTitan() )
		return
    file.hasUsedPhoenix[soul] <- false
    //GivePassive( soul, ePassives.PAS_SCORCH_PHOENIX )
}

void function PlayerScorchBecomesDoomed( entity victim, var damageInfo )
{
    if ( !IsValid( victim ) || !victim.IsPlayer() || !victim.IsTitan() )
        return
    entity soul = victim.GetTitanSoul()
    if ( !IsValid( soul ) || GetTitanCharacterName( victim ) != "scorch")
        return
    if ( file.hasUsedPhoenix[soul] )
        return
    victim.SetInvulnerable()
    thread WaitUndoom( victim, 2 )
    file.hasUsedPhoenix[soul] <- true
    entity damageArea = CreateDamageArea( victim, victim.GetOrigin(), victim.GetAngles() )
    CreateExplosiveBarrelExplosion( damageArea )
    IgniteArea( damageArea )
}

void function WaitUndoom( entity titan, int cells )
{
    entity soul = titan.GetTitanSoul()
    while ( true )
    {
        WaitFrame()
        if ( soul.IsDoomed() )
        {
            UndoomTitan( titan, cells )
            break
        }
    }
    soul.SetShieldHealth( soul.GetShieldHealthMax() )
    titan.ClearInvulnerable()
}

entity function CreateDamageArea( entity owner, vector origin, vector angles )
{
    if ( !IsValid( owner ) )
        return
    int team = owner.GetTeam()
    string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, FIRE_TRAP_LIFETIME, SLOW_TRAP_RADIUS )
    entity damageArea = CreatePropScript( DAMAGE_AREA_MODEL, origin, angles, 0 )
	damageArea.SetOwner( owner )
	if ( owner.IsPlayer() )
		damageArea.SetBossPlayer( owner )
	damageArea.SetMaxHealth( 100 )
	damageArea.SetHealth( 100 )
	damageArea.SetTakeDamageType( DAMAGE_NO )
	damageArea.SetDamageNotifications( false )
	damageArea.SetDeathNotifications( false )
	damageArea.SetArmorType( ARMOR_TYPE_HEAVY )
	damageArea.Hide()
	damageArea.SetParent( owner, "", true, 0 )
	SetTeam( damageArea, TEAM_UNASSIGNED )
	SetObjectCanBeMeleed( damageArea, false )
	SetVisibleEntitiesInConeQueriableEnabled( damageArea, false )

    thread TrapThink( damageArea, noSpawnIdx )

    return damageArea
}

void function TrapThink( entity damageArea, string noSpawnIdx )
{
    damageArea.EndSignal( "OnDestroy" )
    OnThreadEnd(
	function() : ( noSpawnIdx, damageArea )
		{
			DeleteNoSpawnArea( noSpawnIdx )

			if ( IsValid( damageArea ) )
			{
				//Naturally Timed Out
				EmitSoundAtPosition( TEAM_UNASSIGNED, damageArea.GetOrigin() + <0,0,GAS_FX_HEIGHT>, "incendiary_trap_gas_stop" )
				damageArea.Destroy()
			}
		}
	)
}

void function CreateExplosiveBarrelExplosion( entity damageArea )
{
	entity owner = damageArea.GetOwner()
	if ( !IsValid( owner ) )
		return

	Explosion_DamageDefSimple( damagedef_fd_explosive_barrel, damageArea.GetOrigin(), owner, owner, damageArea.GetOrigin() )
}

void function IgniteArea( entity damageArea )
{
	entity owner = damageArea.GetOwner()
	Assert( IsValid( owner ) )
	if ( !IsValid( owner ) )
		return

    entity weapon = owner.GetOffhandWeapon( OFFHAND_ANTIRODEO )
	if ( !IsValid( weapon ) || weapon.GetWeaponClassName() != "mp_titanability_slow_trap"  )
		return

	vector originNoHeightAdjust = damageArea.GetOrigin()
	vector origin = originNoHeightAdjust + <0,0,GAS_FX_HEIGHT>
	float range = SLOW_TRAP_RADIUS

    entity initialExplosion = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( BARREL_EXP_FX ), origin, <0,0,0> )
    EntFireByHandle( initialExplosion, "Kill", "", 3.0, null, null )
    EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "incendiary_trap_explode_large" )

	float duration = FLAME_WALL_THERMITE_DURATION
	entity inflictor = CreateOncePerTickDamageInflictorHelper( duration )
	inflictor.SetOrigin( origin )

	// Increase the radius a bit so AI proactively try to get away before they have a chance at taking damage
	float dangerousAreaRadius = SLOW_TRAP_RADIUS + 50

	array<entity> ignoreArray = damageArea.GetLinkEntArray()
	ignoreArray.append( damageArea )
	entity myParent = damageArea.GetParent()
	entity movingGeo = ( myParent && myParent.HasPusherRootParent() ) ? myParent : null
	if ( movingGeo )
	{
		inflictor.SetParent( movingGeo, "", true, 0 )
		AI_CreateDangerousArea( inflictor, weapon, dangerousAreaRadius, TEAM_INVALID, true, true )
	}
	else
	{
		AI_CreateDangerousArea_Static( inflictor, weapon, dangerousAreaRadius, TEAM_INVALID, true, true, originNoHeightAdjust )
	}

	for ( int i = 0; i < 12; i++ )
	{
		vector trailAngles = < 30 * i, 30 * i, 0 >
		vector forward = AnglesToForward( trailAngles )
		vector startPosition = origin + forward * FIRE_TRAP_MINI_EXPLOSION_RADIUS
		vector direction = forward * 150
		if ( i > 5 )
			direction *= -1
		const float FUSE_TIME = 0.0
		entity projectile = weapon.FireWeaponGrenade( origin, <0,0,0>, <0,0,0>, FUSE_TIME, damageTypes.projectileImpact, damageTypes.explosive, PROJECTILE_NOT_PREDICTED, true, true )
		if ( !IsValid( projectile ) )
			continue
        projectile.ProjectileSetDamageSourceID( eDamageSourceId.mp_titanweapon_phoenix_trap )
		projectile.SetModel( $"models/dev/empty_model.mdl" )
		projectile.SetOrigin( origin )
		projectile.SetVelocity( Vector( 0, 0, 0 ) )
		projectile.StopPhysics()
		projectile.SetTakeDamageType( DAMAGE_NO )
		projectile.Hide()
		projectile.NotSolid()
		projectile.SetProjectilTrailEffectIndex( 1 )
		thread SpawnFireLine( projectile, i, inflictor, origin, direction )
	}
	thread IncendiaryTrapFireSounds( inflictor )

	if ( !movingGeo )
		thread FlameOn( inflictor )
	else
		thread FlameOnMovingGeo( inflictor )
}

void function IncendiaryTrapFireSounds( entity inflictor )
{
	inflictor.EndSignal( "OnDestroy" )

	vector position = inflictor.GetOrigin()
	EmitSoundAtPosition( TEAM_UNASSIGNED, position, "incendiary_trap_burn" )
	OnThreadEnd(
	function() : ( position )
		{
			StopSoundAtPosition( position, "incendiary_trap_burn" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, position, "incendiary_trap_burn_stop" )
		}
	)

	WaitForever()
}

void function FlameOn( entity inflictor )
{
	inflictor.EndSignal( "OnDestroy")

	float intialWaitTime = 0.3
	wait intialWaitTime

	float duration = FLAME_WALL_THERMITE_DURATION
	if ( GAMETYPE == GAMEMODE_SP )
		duration *= SP_FLAME_WALL_DURATION_SCALE
	foreach( key, pos in inflictor.e.fireTrapEndPositions )
	{
		entity fireLine = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FIRE_LINES_FX ), pos, inflictor.GetAngles() )
		EntFireByHandle( fireLine, "Kill", "", duration, null, null )
		EffectSetControlPointVector( fireLine, 1, inflictor.GetOrigin() )
	}
}

void function FlameOnMovingGeo( entity inflictor )
{
	inflictor.EndSignal( "OnDestroy")

	float intialWaitTime = 0.3
	wait intialWaitTime

	float duration = FLAME_WALL_THERMITE_DURATION
	if ( GAMETYPE == GAMEMODE_SP )
		duration *= SP_FLAME_WALL_DURATION_SCALE

	vector angles = inflictor.GetAngles()
	int fxID = GetParticleSystemIndex( FIRE_LINES_FX )
	if ( GetMapName() == "sp_s2s" )
	{
		angles = <0,-90,0> // wind dir
		fxID = GetParticleSystemIndex( FIRE_LINES_S2S_FX )
	}

	foreach( key, relativeDelta in inflictor.e.fireTrapEndPositions )
	{
		if ( ( key in inflictor.e.fireTrapMovingGeo ) )
		{
			entity movingGeo = inflictor.e.fireTrapMovingGeo[ key ]
			if ( !IsValid( movingGeo ) )
				continue
			vector pos = GetWorldOriginFromRelativeDelta( relativeDelta, movingGeo )

			entity script_mover = CreateScriptMover( pos, angles )
			script_mover.SetParent( movingGeo, "", true, 0 )

			int attachIdx 		= script_mover.LookupAttachment( "REF" )
			entity fireLine 	= StartParticleEffectOnEntity_ReturnEntity( script_mover, fxID, FX_PATTACH_POINT_FOLLOW, attachIdx )

			EntFireByHandle( script_mover, "Kill", "", duration, null, null )
			EntFireByHandle( fireLine, "Kill", "", duration, null, null )
			thread EffectUpdateControlPointVectorOnMovingGeo( fireLine, 1, inflictor )
		}
		else
		{
			entity fireLine = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FIRE_LINES_FX ), relativeDelta, inflictor.GetAngles() )
			EntFireByHandle( fireLine, "Kill", "", duration, null, null )
			EffectSetControlPointVector( fireLine, 1, inflictor.GetOrigin() )
		}
	}
}

void function EffectUpdateControlPointVectorOnMovingGeo( entity fireLine, int cpIndex, entity inflictor )
{
	fireLine.EndSignal( "OnDestroy" )
	inflictor.EndSignal( "OnDestroy" )

	while ( 1 )
	{
		EffectSetControlPointVector( fireLine, cpIndex, inflictor.GetOrigin() )
		WaitFrame()
	}
}


void function SpawnFireLine( entity projectile, int projectileCount, entity inflictor, vector origin, vector direction )
{
	if ( !IsValid( projectile ) ) //unclear why this is necessary. We check for validity before creating the thread.
		return

	projectile.EndSignal( "OnDestroy" )
	entity owner = projectile.GetOwner()
	owner.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( projectile )
		{
			if ( IsValid( projectile ) )
				projectile.Destroy()
		}
	)
	projectile.SetAbsOrigin( origin )
	projectile.SetAbsAngles( direction )
	projectile.proj.savedOrigin = < -999999.0, -999999.0, -999999.0 >

	wait RandomFloatRange( 0.0, 0.1 )

	waitthread WeaponAttackWave( projectile, projectileCount, inflictor, origin, direction, CreateSlowTrapSegment )
}

bool function CreateSlowTrapSegment( entity projectile, int projectileCount, entity inflictor, entity movingGeo, vector pos, vector angles, int waveCount )
{
	projectile.SetOrigin( pos )
	entity owner = projectile.GetOwner()

	if ( projectile.proj.savedOrigin != < -999999.0, -999999.0, -999999.0 > )
	{
		float duration = FLAME_WALL_THERMITE_DURATION

		if ( GAMETYPE == GAMEMODE_SP )
			duration *= SP_FLAME_WALL_DURATION_SCALE

		if ( !movingGeo )
		{
			if ( projectileCount in inflictor.e.fireTrapEndPositions )
				inflictor.e.fireTrapEndPositions[projectileCount] = pos
			else
				inflictor.e.fireTrapEndPositions[projectileCount] <- pos

			thread FireTrap_DamageAreaOverTime( owner, inflictor, pos, duration )
		}
		else
		{
			vector relativeDelta = GetRelativeDelta( pos, movingGeo )

			if ( projectileCount in inflictor.e.fireTrapEndPositions )
				inflictor.e.fireTrapEndPositions[projectileCount] = relativeDelta
			else
				inflictor.e.fireTrapEndPositions[projectileCount] <- relativeDelta

			if ( projectileCount in inflictor.e.fireTrapMovingGeo )
				inflictor.e.fireTrapMovingGeo[projectileCount] = movingGeo
			else
				inflictor.e.fireTrapMovingGeo[projectileCount] <- movingGeo

			thread FireTrap_DamageAreaOverTimeOnMovingGeo( owner, inflictor, movingGeo, relativeDelta, duration )
		}

	}

	projectile.proj.savedOrigin = pos
	return true
}

void function FireTrap_DamageAreaOverTime( entity owner, entity inflictor, vector pos, float duration )
{
	Assert( IsValid( owner ) )
	owner.EndSignal( "OnDestroy" )
	float endTime = Time() + duration
	while ( Time() < endTime )
	{
		FireTrap_RadiusDamage( pos, owner, inflictor )
		wait 0.2
	}
}

void function FireTrap_DamageAreaOverTimeOnMovingGeo( entity owner, entity inflictor, entity movingGeo, vector relativeDelta, float duration )
{
	Assert( IsValid( owner ) )
	owner.EndSignal( "OnDestroy" )
	movingGeo.EndSignal( "OnDestroy" )
	inflictor.EndSignal( "OnDestroy" )

	float endTime = Time() + duration
	while ( Time() < endTime )
	{
		vector pos = GetWorldOriginFromRelativeDelta( relativeDelta, movingGeo )
		FireTrap_RadiusDamage( pos, owner, inflictor )
		wait 0.2
	}
}

void function FireTrap_RadiusDamage( vector pos, entity owner, entity inflictor )
{
	MeteorRadiusDamage meteorRadiusDamage = GetMeteorRadiusDamage( owner )
	float METEOR_DAMAGE_TICK_PILOT = meteorRadiusDamage.pilotDamage
	float METEOR_DAMAGE_TICK = meteorRadiusDamage.heavyArmorDamage

	RadiusDamage(
		pos,												// origin
		owner,												// owner
		inflictor,		 									// inflictor
		METEOR_DAMAGE_TICK_PILOT,							// pilot damage
		METEOR_DAMAGE_TICK,									// heavy armor damage
		FIRE_TRAP_MINI_EXPLOSION_RADIUS,					// inner radius
		FIRE_TRAP_MINI_EXPLOSION_RADIUS,					// outer radius
		SF_ENVEXPLOSION_NO_NPC_SOUND_EVENT,					// explosion flags
		0, 													// distanceFromAttacker
		0, 													// explosionForce
		DF_EXPLOSION,										// damage flags
		eDamageSourceId.mp_titanability_slow_trap			// damage source id
	)
}

void function FireTrap_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	Thermite_DamagePlayerOrNPCSounds( ent )

	float originDistance2D = Distance2D( inflictor.GetOrigin(), DamageInfo_GetDamagePosition( damageInfo ) )
	if ( originDistance2D > SLOW_TRAP_RADIUS )
		DamageInfo_SetDamage( damageInfo, 0 )
	else
		Scorch_SelfDamageReduction( ent, damageInfo )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) || attacker.GetTeam() == ent.GetTeam() )
		return

	array<entity> weapons = attacker.GetMainWeapons()
	if ( weapons.len() > 0 )
	{
		if ( weapons[0].HasMod( "fd_fire_damage_upgrade" )  )
			DamageInfo_ScaleDamage( damageInfo, FD_FIRE_DAMAGE_SCALE )
		if ( weapons[0].HasMod( "fd_hot_streak" ) )
			UpdateScorchHotStreakCoreMeter( attacker, DamageInfo_GetDamage( damageInfo ) )
	}
}
#endif
