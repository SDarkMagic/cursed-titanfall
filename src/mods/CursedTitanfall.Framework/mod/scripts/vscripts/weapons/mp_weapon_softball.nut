untyped

global function OnWeaponPrimaryAttack_weapon_softball
global function OnProjectileCollision_weapon_softball
global function AddCallback_OnPrimaryAttackPlayer_weapon_softball
global function AddCallback_OnProjectileCollision_weapon_softball

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_softball
#endif // #if SERVER

const FUSE_TIME = 0.5 //Applies once the grenade has stuck to a surface.

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onProjectileCollisionCallbacks_weapon_softball
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_softball
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_softball( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_softball.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_softball"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_softball.append( callback )
}

void function AddCallback_OnProjectileCollision_weapon_softball( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onProjectileCollisionCallbacks_weapon_softball.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnProjectileCollision_weapon_softball"  )
	file.onProjectileCollisionCallbacks_weapon_softball.append( callback )
}
//////////////////////////////////////

var function OnWeaponPrimaryAttack_weapon_softball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	//vector bulletVec = ApplyVectorSpread( attackParams.dir, player.GetAttackSpreadAngle() * 2.0 )
	//attackParams.dir = bulletVec

	if ( IsServer() || weapon.ShouldPredictProjectiles() )
	{
		vector offset = Vector( 30.0, 6.0, -4.0 )
		if ( weapon.IsWeaponInAds() )
			offset = Vector( 30.0, 0.0, -3.0 )
		vector attackPos = player.OffsetPositionFromView( attackParams[ "pos" ], offset )	// forward, right, up
		FireGrenade( weapon, attackParams )
	}
	foreach( callback in file.onPrimaryAttackPlayerCallbacks_weapon_softball )
    {
        callback(weapon, attackParams)
    }
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_softball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	FireGrenade( weapon, attackParams, true )
}
#endif // #if SERVER

function FireGrenade( entity weapon, WeaponPrimaryAttackParams attackParams, isNPCFiring = false )
{
	vector angularVelocity = Vector( RandomFloatRange( -1200, 1200 ), 100, 0 )

	int damageType = DF_RAGDOLL | DF_EXPLOSION

	entity nade = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir, angularVelocity, 0.0 , damageType, damageType, !isNPCFiring, true, false )

	if ( nade )
	{
		#if SERVER
			EmitSoundOnEntity( nade, "Weapon_softball_Grenade_Emitter" )
			Grenade_Init( nade, weapon )
		#else
			entity weaponOwner = weapon.GetWeaponOwner()
			SetTeam( nade, weaponOwner.GetTeam() )
		#endif
	}
}

void function OnProjectileCollision_weapon_softball( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	bool didStick = PlantSuperStickyGrenade( projectile, pos, normal, hitEnt, hitbox )
	if ( !didStick )
		return

	ProjectileCollisionParams params
    params.projectile = projectile
    params.pos = pos
    params.normal = normal
    params.hitEnt = hitEnt
    params.hitbox = hitbox
    params.isCritical = isCritical

	foreach( callback in file.onProjectileCollisionCallbacks_weapon_softball )
	{
		callback( params )
	}
	#if SERVER
		if ( IsAlive( hitEnt ) && hitEnt.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( projectile, hitEnt, "weapon_softball_grenade_attached_1P" )
			EmitSoundOnEntityExceptToPlayer( projectile, hitEnt, "weapon_softball_grenade_attached_3P" )
		}
		else
		{
			EmitSoundOnEntity( projectile, "weapon_softball_grenade_attached_3P" )
		}
		thread DetonateStickyAfterTime( projectile, FUSE_TIME, normal )
	#endif
}

#if SERVER
// need this so grenade can use the normal to explode
void function DetonateStickyAfterTime( entity projectile, float delay, vector normal )
{
	wait delay
	if ( IsValid( projectile ) )
		projectile.GrenadeExplode( normal )
}
#endif