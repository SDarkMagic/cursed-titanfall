global function OnWeaponPrimaryAttack_weapon_wingman_n_Player
global function OnProjectileCollision_weapon_wingman_n

#if SERVER
global function OnWeaponPrimaryAttack_weapon_wingman_n_NPC
#endif

var function OnWeaponPrimaryAttack_weapon_wingman_n_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	OnWeaponPrimaryAttack_weapon_wingman_n(weapon, attackParams, true)
	#endif
	return
}

void function OnProjectileCollision_weapon_wingman_n( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
	collision(projectile, pos, normal, hitEnt, hitbox, isCritical)
	#endif
}

#if SERVER
var function OnWeaponPrimaryAttack_weapon_wingman_n_NPC( entity weapon, WeaponPrimaryAttackParams attackParams)
{
	OnWeaponPrimaryAttack_weapon_wingman_n(weapon, attackParams, false)
	return
}

void function OnWeaponPrimaryAttack_weapon_wingman_n( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
	boltSpeed = 1
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )
	if ( bolt )
	{

	}
}

void function collision( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()
    vector spawnOffset = -150 * Normalize(projectile.GetVelocity()) // Move the spawn point back by 150 units of the projectile's velocity vector

    player.SetOrigin(pos + spawnOffset)
	printt("WINGMAN SHOT ATHING")
}
#endif