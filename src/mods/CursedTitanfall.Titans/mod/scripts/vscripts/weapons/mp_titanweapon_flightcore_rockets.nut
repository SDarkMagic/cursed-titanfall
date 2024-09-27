global function OnWeaponPrimaryAttack_titanweapon_flightcore_rockets
global function OnProjectileCollision_titanweapon_flightcore_rockets

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_flightcore_rockets
#endif

var function OnWeaponPrimaryAttack_titanweapon_flightcore_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
	if ( !shouldPredict )
		return 1
	#endif

	// Get missile firing information
	entity owner = weapon.GetWeaponOwner()
	vector offset
	int altFireIndex = weapon.GetCurrentAltFireIndex()
	float horizontalMultiplier
	if ( altFireIndex == 1 )
		horizontalMultiplier = RandomFloatRange( 0.25, 0.45 )
	else
		horizontalMultiplier = RandomFloatRange( -0.45, -0.25 )

	if ( owner.IsPlayer() )
		offset = AnglesToRight( owner.CameraAngles() ) * horizontalMultiplier
	#if SERVER
	else
		offset = owner.GetPlayerOrNPCViewRight() * horizontalMultiplier
	#endif

	vector attackDir = attackParams.dir + offset + <0,0,RandomFloatRange(-0.25,0.55)>
	vector attackPos = attackParams.pos + offset*32
	attackDir = Normalize( attackDir )
	entity missile = weapon.FireWeaponMissile( attackPos, attackDir, 1, (damageTypes.projectileImpact | DF_DOOM_FATALITY), damageTypes.explosive, false, shouldPredict )

	if ( missile )
	{
		TraceResults result = TraceLine( owner.EyePosition(), owner.EyePosition() + attackParams.dir*50000, [ owner ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		missile.kv.lifetime = 10
		missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )
		thread DelayedTrackingStart( missile, result.endPos )
	#if SERVER
		missile.SetOwner( owner )
		EmitSoundAtPosition( owner.GetTeam(), result.endPos, "Weapon_FlightCore_Incoming_Projectile" )

		thread MissileThink( missile )
	#endif // SERVER
	}
	return 1
}

void function OnProjectileCollision_titanweapon_flightcore_rockets( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity owner = projectile.GetOwner()
	if ( !IsAlive( owner ) || !IsValid( owner ) )
		return
	entity offHandWeapon = owner.GetOffhandWeapon( OFFHAND_ORDNANCE )
	if ( !offHandWeapon.HasMod( "pas_northstar_cluster" ) )
		return

	#if SERVER
		float duration = PAS_NORTHSTAR_CLUSTER_ROCKET_DURATION
		float explosionDelay = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" ) )

		ProjectileCollisionParams params
		params.projectile = projectile
		params.pos = pos
		params.normal = normal
		params.hitEnt = hitEnt
		params.hitbox = hitbox
		params.isCritical = isCritical

		SpawnClusterMissile_flightcore_rocket( params )
	#endif
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_flightcore_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_flightcore_rockets( weapon, attackParams )
}

void function MissileThink( entity missile )
{
	missile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( missile )
		{
			if ( IsValid( missile ) )
				missile.Destroy()
		}
	)

	float life = float( missile.kv.lifetime )

	wait life
}

void function SpawnClusterMissile_flightcore_rocket( ProjectileCollisionParams params )
{
	entity rocket = params.projectile
	vector normal = params.normal
	vector pos = params.pos
	float explosionDelay = expect float( rocket.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" ) )

	entity owner = rocket.GetOwner()
	if ( !IsValid( owner ) )
		return

	int count
	float duration
	float range

	array<string> mods = rocket.ProjectileGetMods()
	count = CLUSTER_ROCKET_BURST_COUNT
	duration = 0.75
	range = CLUSTER_ROCKET_BURST_RANGE

	PopcornInfo popcornInfo

	popcornInfo.weaponName = "mp_titanweapon_flightcore_rockets"
	popcornInfo.weaponMods = []
	popcornInfo.damageSourceId = eDamageSourceId.mp_titanweapon_flightcore_rockets
	popcornInfo.count = 5
	popcornInfo.delay = 0.2
	popcornInfo.offset = CLUSTER_ROCKET_BURST_OFFSET
	popcornInfo.range = range
	popcornInfo.normal = normal
	popcornInfo.duration = duration
	popcornInfo.groupSize = 3
	popcornInfo.hasBase = true

	thread StartClusterExplosions( rocket, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
	CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, pos, ( duration + explosionDelay ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
}

#endif // SERVER

void function DelayedTrackingStart( entity missile, vector targetPos )
{
	missile.EndSignal( "OnDestroy" )
	wait 0.1
	missile.SetHomingSpeeds( 2000, 0 )
	missile.SetMissileTargetPosition( targetPos )
}