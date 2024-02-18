global function OnWeaponPrimaryAttack_weapon_dmr_laser
global function OnWeaponPrimaryAttack_weapon_wingman_n

#if SERVER
global function OnWeaponNPCPrimaryAttack_weapon_dmr_laser
#endif

// Copied from mp_weapon_sniper since the wingman elite uses that function when firing
var function OnWeaponPrimaryAttack_weapon_wingman_n( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	if ( shouldCreateProjectile )
	{
		int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
		int damageFlags = weapon.GetWeaponDamageFlags()
		entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )

		if ( bolt != null )
		{
			bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )

#if CLIENT
				StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
#endif // #if CLIENT
		}
	}

	return 1
}
/////////////////////////////////////////////////////

var function OnWeaponPrimaryAttack_weapon_dmr_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
    return 1
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_weapon_dmr_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    return OnWeaponPrimaryAttack_weapon_dmr_laser( weapon, attackParams )
}
#endif