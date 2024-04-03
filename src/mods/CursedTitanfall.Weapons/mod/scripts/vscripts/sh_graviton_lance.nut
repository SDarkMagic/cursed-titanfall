global function Init_GravitonLance
global function OnWeaponActivate_weapon_g2

const DETONATION_RAD_INNER = 25
const DETONATION_RAD_OUTER = 100
const DETONATION_IMPULSE_FORCE = 1000
const DAMAGE_SOURCEID = eDamageSourceId.mp_weapon_g2
const SEEKER_HUNT_RADIUS = DETONATION_RAD_OUTER * 30
const MAX_SEEKERS = 3

asset seekerModel = $"models/fx/plasma_sphere_01.mdl"

struct {
	array<entity> currentlyProcessingTargets
} file

void function Init_GravitonLance()
{
    PrecacheModel( seekerModel )
    #if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_g2, GravitonHitTarget)
    #endif
}

void function OnWeaponActivate_weapon_g2( entity weapon )
{
    Init_SmartAmmoSettings( weapon )
}

void function Init_SmartAmmoSettings( entity weapon )
{
    SmartAmmo_SetMissileSpeed( weapon, 120 )
    SmartAmmo_SetMissileHomingSpeed( weapon, 125 )

    if ( weapon.HasMod( "burn_mod_rocket_launcher" ) )
        SmartAmmo_SetMissileSpeedLimit( weapon, 130 )
    else
        SmartAmmo_SetMissileSpeedLimit( weapon, 140 )

    SmartAmmo_SetMissileShouldDropKick( weapon, false )  // TODO set to true to see drop kick behavior issues
    SmartAmmo_SetUnlockAfterBurst( weapon, true )
}

void function SmartAmmo_SetMissileTargetPosition( entity missile, entity target )
{
	if ( !IsValid( missile ) || !IsValid( target ) )
		return

	// Set the missile locking offset
	//local missileTargetOffset = target.IsTitan() ? Vector( 0, 0, -25 ) : Vector( 0, 0, -25 )

	// Set the missile target and homing speed
	missile.SetMissileTargetPosition( target.EyePosition() )
}

int function SmartAmmo_FireWeapon_HomingMissile( entity weapon, WeaponPrimaryAttackParams attackParams, int damageType, int explosionDamageType, bool activeShot, entity target )
{
	bool shouldPredict = weapon.ShouldPredictProjectiles()

	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	entity player = weapon.GetWeaponOwner()
	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir
	int missileSpeed = expect int(SmartAmmo_GetMissileSpeed( weapon ))
	bool doPopup = expect bool(SmartAmmo_GetMissileShouldDropKick( weapon ))

	if ( SmartAmmo_GetMissileAimAtCursor( weapon ) )
		attackDir = GetVectorFromPositionToCrosshair( player, attackPos )

	int homingSpeed = expect int(SmartAmmo_GetMissileHomingSpeed( weapon ))
	int missileSpeedLimit = expect int(SmartAmmo_GetMissileSpeedLimit( weapon ))

	array<entity> firedMissiles
	var missileFlightData = SmartAmmo_GetExpandContract( weapon )

	if ( missileFlightData == null )
	{
		entity missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageType, explosionDamageType, doPopup, shouldPredict )
		#if SERVER
		missile.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
		missile.ProjectileSetDamageSourceID( eDamageSourceId.mp_weapon_g2 )
		#endif
		if ( missile )
		{
			//InitMissileForRandomDrift( missile, attackPos, attackDir )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )
			firedMissiles.append( missile )
		}
	}

	foreach( missile in firedMissiles )
	{
		missile.kv.lifetime = 10

		#if SERVER
			missile.SetOwner( player )
			EmitSoundOnEntity( missile, HOMING_SFX_LOOP )
		#endif

		missile.SetSpeed( missileSpeed )
		missile.SetHomingSpeeds( homingSpeed, homingSpeed )
		SetTeam( missile, player.GetTeam() )

		if ( target )
		{
			if ( SmartAmmo_GetShouldTrackPosition( weapon ) )
				SmartAmmo_SetMissileTargetPosition( missile, target )
			else
				SmartAmmo_SetMissileTarget( missile, target )
		}
	}

	return firedMissiles.len()
}

#if SERVER
void function GravitonHitTarget( entity target, var damageInfo )
{
    float damage = DamageInfo_GetDamage( damageInfo )
	int damageFlags = DamageInfo_GetDamageFlags( damageInfo )
    int targetHealth = target.GetHealth()
	printt(target.GetClassName())
    if ( targetHealth - damage > 0 || !IsValid( target ) || !IsAlive( target ) || target.IsProjectile() || file.currentlyProcessingTargets.find( target ) != -1 )
        return
    // detonate target, create small nades that home to nearby enemies
	printt("Graviton hit target")
	file.currentlyProcessingTargets.append( target )
    vector origin = target.GetOrigin()
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
	vector projectileOrigin = attacker.GetOrigin()
	//target.TakeDamage( damage, attacker, attacker, { damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } )
    Explosion( origin, attacker, attacker, damage, damage, DETONATION_RAD_INNER, DETONATION_RAD_OUTER, damageFlags, projectileOrigin, DETONATION_IMPULSE_FORCE, damageFlags, DAMAGE_SOURCEID, "exp_emp" )

    if ( !IsValid( weapon ) )
        return

	array<entity> targets = GetNPCArrayEx( "any", -1, attacker.GetTeam(), origin, SEEKER_HUNT_RADIUS )
	if ( targets.len() == 0 )
		return
    WeaponPrimaryAttackParams attackParams
    attackParams.pos = origin
    for ( int i = 0; i < MAX_SEEKERS; i++ )
    {
		printt("Firing seeker for graviton")
		int index = 0
		if ( targets.len() > 1 )
			index = RandomInt( targets.len() - 1 )
		entity subTarget = targets.remove( index )
        attackParams.dir = Normalize( origin - subTarget.GetOrigin() )
        SmartAmmo_FireWeapon_HomingMissile( weapon, attackParams, damageFlags, damageFlags, false, subTarget )
    }
	file.currentlyProcessingTargets.remove( file.currentlyProcessingTargets.find( target ) )
}
#endif