global function OnWeaponPrimaryAttack_weapon_epg_Player
global function OnProjectileCollision_weapon_epg

#if SERVER
global function OnWeaponPrimaryAttack_weapon_epg_NPC
#endif

void function OnProjectileCollision_weapon_epg( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
    #if SERVER
    projectileCollision( projectile, pos, normal, hitEnt, hitbox, isCritical)
    #endif
    return
}

#if SERVER
void function projectileCollision( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
    entity prowler = CreateEntity( "npc_prowler" )
    entity player = projectile.GetOwner()
    int team = player.GetTeam()
    vector spawnOffset = -150 * Normalize(projectile.GetVelocity()) // Move the spawn point back by 150 units of the projectile's velocity vector

    prowler.SetOrigin(pos + spawnOffset)
    prowler.SetAngles(projectile.GetAngles())
    prowler.SetBossPlayer(player)
    SetTeam(prowler, team)
    DispatchSpawn(prowler)
    add_prowler(prowler)
    return
}
#endif

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
	return FireBoltWithDrop( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponPrimaryAttack_weapon_epg_NPC( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireBoltWithDrop( weapon, attackParams, false )
}
#endif