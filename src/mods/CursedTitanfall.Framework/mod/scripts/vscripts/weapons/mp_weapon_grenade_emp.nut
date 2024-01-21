global function OnProjectileCollision_weapon_grenade_emp
global function AddCallback_OnProjectileCollision_weapon_grenade_emp

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onProjectileCollisionCallbacks_weapon_grenade_emp
} file

void function AddCallback_OnProjectileCollision_weapon_grenade_emp( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onProjectileCollisionCallbacks_weapon_grenade_emp.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnProjectileCollision_weapon_grenade_emp"  )
	file.onProjectileCollisionCallbacks_weapon_grenade_emp.append( callback )
}
//////////////////////////////////////

void function OnProjectileCollision_weapon_grenade_emp( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	ProjectileCollisionParams params
	params.projectile = projectile
	params.pos = pos
	params.normal = normal
	params.hitEnt = hitEnt
	params.hitbox = hitbox
	params.isCritical = isCritical

	foreach( callback in file.onProjectileCollisionCallbacks_weapon_grenade_emp )
	{
		callback( params )
	}

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	if ( IsSingleplayer() && ( player && !player.IsPlayer() ) )
		collisionParams.hitEnt = GetEntByIndex( 0 )

	bool result = PlantStickyEntity( projectile, collisionParams )

	if ( projectile.GrenadeHasIgnited() )
		return

	//Triggering this on the client triggers an impact effect.
	#if SERVER
	projectile.GrenadeIgnite()
	#endif
}