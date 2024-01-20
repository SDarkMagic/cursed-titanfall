global function Init_SpitfireProjectileCollison_Callback

void function Init_SpitfireProjectileCollison_Callback( )
{
    #if SERVER
    AddCallback_OnBulletHit_weapon_lmg(SpitfireBulletHit)
    #endif
}

#if SERVER
void function SpitfireBulletHit( ProjectileCollisionParams hitParams )
{

    entity projectile = hitParams.projectile
    vector pos = hitParams.pos
    vector normal = hitParams.normal
    entity hitEnt = hitParams.hitEnt
    int hitbox = hitParams.hitbox
    bool isCritical = false

    entity player = projectile.GetOwner()
    if ( hitEnt == player )
		return

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}


	bool result = PlantStickyEntity( projectile, collisionParams )

    projectile.SetDoesExplode( false )

    thread ThermiteBurn( 2.0, player, projectile)
    entity entAttachedTo = projectile.GetParent()
		if ( !IsValid( entAttachedTo ) )
			return

		if ( !player.IsPlayer() ) //If an NPC Titan has vortexed a satchel and fires it back out, then it won't be a player that is the owner of this satchel
			return

		entity titanSoulRodeoed = player.GetTitanSoulBeingRodeoed()
		if ( !IsValid( titanSoulRodeoed ) )
			return

		entity titan = titanSoulRodeoed.GetTitan()

		if ( !IsAlive( titan ) )
			return

		if ( titan == entAttachedTo )
			titanSoulRodeoed.SetLastRodeoHitTime( Time() )
}
#endif