//untyped

global function OnWeaponPrimaryAttack_lmg

global function OnWeaponActivate_lmg
global function OnWeaponBulletHit_weapon_lmg
global function OnProjectileCollision_weapon_lmg
global function AddCallback_OnPrimaryAttackPlayer_weapon_lmg
global function AddCallback_OnBulletHit_weapon_lmg

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_lmg
#endif

const float LMG_SMART_AMMO_TRACKER_TIME = 10.0

void function OnWeaponActivate_lmg( entity weapon )
{
	//PrintFunc()
	SmartAmmo_SetAllowUnlockedFiring( weapon, true )
	SmartAmmo_SetUnlockAfterBurst( weapon, (SMART_AMMO_PLAYER_MAX_LOCKS > 1) )
	SmartAmmo_SetWarningIndicatorDelay( weapon, 9999.0 )
}

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onBulletHitCalbacks_weapon_lmg
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_lmg
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_lmg( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_lmg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_lmg"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_lmg.append( callback )
}

void function AddCallback_OnBulletHit_weapon_lmg( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onBulletHitCalbacks_weapon_lmg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnProjectileCollision_weapon_lmg"  )
	file.onBulletHitCalbacks_weapon_lmg.append( callback )
}
//////////////////////////////////////

var function OnWeaponPrimaryAttack_lmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

void function OnWeaponBulletHit_weapon_lmg( entity weapon, WeaponBulletHitParams hitParams )
{
	return
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_lmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, false )
}
#endif // #if SERVER

var function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool isPlayerFired )
{
	if ( isPlayerFired )
	{
		foreach( callback in file.onPrimaryAttackPlayerCallbacks_weapon_lmg )
		{
			callback( weapon, attackParams )
		}
	}

	if ( weapon.HasMod( "smart_lock_dev" ) )
	{
		int damageFlags = weapon.GetWeaponDamageFlags()
		//printt( "DamageFlags for lmg: " + damageFlags )
		return SmartAmmo_FireWeapon( weapon, attackParams, damageFlags, damageFlags )
	}
	else
	{
		bool shouldCreateProjectile = false
		if ( IsServer() || weapon.ShouldPredictProjectiles() )
			shouldCreateProjectile = true

		#if CLIENT
			if ( !isPlayerFired )
				shouldCreateProjectile = false
		#endif

		if ( shouldCreateProjectile )
		{
			vector vBoltSpeed = Vector( RandomFloatRange( -1200, 1200 ), 100, 0 )
			int damageFlags = weapon.GetWeaponDamageFlags()
			entity nade = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir, vBoltSpeed, 0.0, damageFlags, damageFlags, isPlayerFired, true, false )

			if ( nade )
			{
				#if SERVER
					Grenade_Init( nade, weapon )
				#else
					entity weaponOwner = weapon.GetWeaponOwner()
					SetTeam( nade, weaponOwner.GetTeam() )
				#endif
			}
		}
	}


}

void function OnProjectileCollision_weapon_lmg( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	ProjectileCollisionParams params
	params.projectile = projectile
	params.pos = pos
	params.normal = normal
	params.hitEnt = hitEnt
	params.hitbox = 0
	params.isCritical = isCritical

	foreach( callback in file.onBulletHitCalbacks_weapon_lmg )
	{
		callback( params )
	}
}
