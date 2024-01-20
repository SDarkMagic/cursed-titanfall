global function MpWeaponEsaw_Init

global function OnWeaponReload_weapon_esaw
global function OnWeaponPrimaryAttack_weapon_esaw

void function MpWeaponEsaw_Init()
{
	EsawPrecache()
}

void function EsawPrecache()
{
	PrecacheParticleSystem( $"P_wpn_meteor_exp" )
}

void function OnWeaponReload_weapon_esaw( entity weapon, int milestone )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	float tolerance = 0.001
	float expectedTimeBetweenShots = 1/weapon.GetWeaponSettingFloat(eWeaponVar.fire_rate_max)
	entity player = weapon.GetWeaponOwner()
    int currentAmmo = weapon.GetWeaponPrimaryClipCount()
	#if SERVER
		if ( currentAmmo == 0 && weapon.GetNextAttackAllowedTime() - weapon.w.lastFireTime <= (expectedTimeBetweenShots + tolerance))
			player.TakeDamage( player.GetHealth(), null, null, { weapon = weapon, damageSourceId = eDamageSourceId.mp_weapon_esaw } )
			Explosion_DamageDefSimple(
				damagedef_titan_hotdrop,
				weapon.GetOrigin(),
				player,
				null,
				weapon.GetOrigin()
			)
	#endif
	return
}

var function OnWeaponPrimaryAttack_weapon_esaw( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	weapon.w.lastFireTime = Time()
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	#endif

	return weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, weapon.GetWeaponDamageFlags() )
}
