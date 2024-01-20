global function OnWeaponPrimaryAttack_weapon_epg_Player
global function OnProjectileCollision_weapon_epg
global function AddCallback_OnPrimaryAttackPlayer_weapon_epg
global function AddCallback_OnProjectileCollision_weapon_epg

#if SERVER
global function OnWeaponPrimaryAttack_weapon_epg_NPC
#endif

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onProjectileCollisionCallbacks_weapon_epg
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_epg
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_epg( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_epg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_epg"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_epg.append( callback )
}

void function AddCallback_OnProjectileCollision_weapon_epg( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onProjectileCollisionCallbacks_weapon_epg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnProjectileCollision_weapon_epg"  )
	file.onProjectileCollisionCallbacks_weapon_epg.append( callback )
}
//////////////////////////////////////

void function OnProjectileCollision_weapon_epg( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
    ProjectileCollisionParams params
    params.projectile = projectile
    params.pos = pos
    params.normal = normal
    params.hitEnt = hitEnt
    params.hitbox = hitbox
    params.isCritical = isCritical
    foreach( callback in file.onProjectileCollisionCallbacks_weapon_epg )
    {
        callback( params )
    }
    return
}

int function FireBoltWithDrop( entity weapon, WeaponPrimaryAttackParams attackParams, bool isPlayerFired )
{
#if CLIENT
	if ( !weapon.ShouldPredictProjectiles() )
		return 1
#endif // #if CLIENT

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	const float PROJ_SPEED_SCALE = 1
	const float PROJ_GRAVITY = 1
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, PROJ_SPEED_SCALE, damageFlags, damageFlags, isPlayerFired, 0 )
	if ( bolt != null )
	{
		bolt.kv.gravity = PROJ_GRAVITY
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
	}
    #if SERVER
    if ( bolt )
    {
        //thread OnProjectileCollision(bolt, weapon.GetWeaponOwner())
    }
    #endif

	return 1
}

var function OnWeaponPrimaryAttack_weapon_epg_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    foreach( callback in file.onPrimaryAttackPlayerCallbacks_weapon_epg )
    {
        callback(weapon, attackParams)
    }
	return FireBoltWithDrop( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponPrimaryAttack_weapon_epg_NPC( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireBoltWithDrop( weapon, attackParams, false )
}
#endif