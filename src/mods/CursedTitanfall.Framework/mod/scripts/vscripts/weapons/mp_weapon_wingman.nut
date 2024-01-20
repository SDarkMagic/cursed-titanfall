global function OnWeaponPrimaryAttack_weapon_wingman_Player
global function OnProjectileCollision_weapon_wingman
global function AddCallback_OnPrimaryAttackPlayer_weapon_wingman
global function AddCallback_OnProjectileCollision_weapon_wingman

#if SERVER
global function OnWeaponPrimaryAttack_weapon_wingman_NPC
#endif

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onProjectileCollisionCallbacks_weapon_wingman
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_wingman
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_wingman( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_wingman.contains( callback ), "Already added " + string( callback ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_wingman"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_wingman.append( callback )
}

void function AddCallback_OnProjectileCollision_weapon_wingman( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onProjectileCollisionCallbacks_weapon_wingman.contains( callback ), "Already added " + string( callback ) + " with AddCallback_OnProjectileCollision_weapon_wingman"  )
	file.onProjectileCollisionCallbacks_weapon_wingman.append( callback )
}
//////////////////////////////////////

var function OnWeaponPrimaryAttack_weapon_wingman_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	OnWeaponPrimaryAttack_weapon_wingman(weapon, attackParams, true)
	#endif
	foreach( callback in file.onPrimaryAttackPlayerCallbacks_weapon_wingman )
    {
        callback(weapon, attackParams)
    }
	return
}

void function OnProjectileCollision_weapon_wingman( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	ProjectileCollisionParams params
    params.projectile = projectile
    params.pos = pos
    params.normal = normal
    params.hitEnt = hitEnt
    params.hitbox = hitbox
    params.isCritical = isCritical

	foreach( callback in file.onProjectileCollisionCallbacks_weapon_wingman )
	{
		callback( params )
	}
}

#if SERVER
var function OnWeaponPrimaryAttack_weapon_wingman_NPC( entity weapon, WeaponPrimaryAttackParams attackParams)
{
	OnWeaponPrimaryAttack_weapon_wingman(weapon, attackParams, false)
	return
}

void function OnWeaponPrimaryAttack_weapon_wingman( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
	boltSpeed = 1
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )
	if ( bolt )
	{

	}
}
#endif