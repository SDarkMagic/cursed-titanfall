//untyped

global function OnWeaponPrimaryAttack_lmg

global function OnWeaponActivate_lmg
global function OnWeaponBulletHit_weapon_lmg

const float LMG_SMART_AMMO_TRACKER_TIME = 10.0

void function OnWeaponActivate_lmg( entity weapon )
{
	//PrintFunc()
	SmartAmmo_SetAllowUnlockedFiring( weapon, true )
	SmartAmmo_SetUnlockAfterBurst( weapon, (SMART_AMMO_PLAYER_MAX_LOCKS > 1) )
	SmartAmmo_SetWarningIndicatorDelay( weapon, 9999.0 )
}

#if SERVER
bool function PlayerHasMoved( vector startPos, entity player, float minDeviation, float delay=2.0 )
{
	wait delay
	vector currentPos = player.GetOrigin()
	float deviationX = currentPos.x - startPos.x
	float deviationY = currentPos.y - startPos.y
	float deviationZ = currentPos.z - startPos.z

	if ( deviationX < 0)
		deviationX += -2 * deviationX

	if ( deviationY < 0)
		deviationY += -2 * deviationY

	if ( deviationZ < 0)
		deviationZ += -2 * deviationZ

	if (deviationX > minDeviation || deviationY > minDeviation || deviationZ > minDeviation)
	{
		return true
	}
	else {
		return false
	}
	return false
}

void function PreventCamping( entity weapon )
{
	entity player = weapon.GetOwner()
	vector currentPos = player.GetOrigin()
	bool hasMoved = PlayerHasMoved(currentPos, player, 200.0)
	if ( !hasMoved )
	{
		player.TakeDamage( player.GetHealth(), null, null, { weapon = weapon, damageSourceId = eDamageSourceId.mp_weapon_lmg } )
		Explosion_DamageDefSimple(
			damagedef_titan_hotdrop,
			weapon.GetOrigin(),
			player,
			null,
			weapon.GetOrigin()
		)
	}
	return
}
#endif

var function OnWeaponPrimaryAttack_lmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	thread PreventCamping( weapon )
	#endif
	if ( weapon.HasMod( "smart_lock_dev" ) )
	{
		int damageFlags = weapon.GetWeaponDamageFlags()
		//printt( "DamageFlags for lmg: " + damageFlags )
		return SmartAmmo_FireWeapon( weapon, attackParams, damageFlags, damageFlags )
	}
	else
	{
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
		weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, weapon.GetWeaponDamageFlags() )
	}


}

void function OnWeaponBulletHit_weapon_lmg( entity weapon, WeaponBulletHitParams hitParams )
{

	#if SERVER
	//AttachThermite(hitParams, weapon.GetWeaponOwner())
	#endif

	if ( !weapon.HasMod( "smart_lock_dev" ) )
		return

	entity hitEnt = hitParams.hitEnt //Could be more efficient with this and early return out if the hitEnt is not a player, if only smart_ammo_player_targets_must_be_tracked  is set, which is currently true

	if ( IsValid( hitEnt ) )
	{
		weapon.SmartAmmo_TrackEntity( hitEnt, LMG_SMART_AMMO_TRACKER_TIME )

		#if SERVER
			if ( hitEnt.IsPlayer() &&  !hitEnt.IsTitan() ) //Note that there is a max of 10 status effects, which means that if you theoreteically get hit as a pilot 10 times without somehow dying, you could knock out other status effects like emp slow etc
			{
				printt( "Adding status effect" )
				StatusEffect_AddTimed( hitEnt, eStatusEffect.sonar_detected, 1.0, LMG_SMART_AMMO_TRACKER_TIME, 0.0 )
			}
			printt("Threaded thermite burn")
		#endif
	}
}

#if SERVER
void function AttachThermite( WeaponBulletHitParams hitParams, entity player )
{
	table collisionParams =
	{
		pos = hitParams.hitPos,
		normal = hitParams.hitNormal,
		hitEnt = hitParams.hitEnt,
		hitbox = 1
	}

	//bool result = PlantStickyEntity( hitParams, collisionParams )
}
#endif
