
global function MpWeaponDefender_Init
global function AddCallback_OnPrimaryAttackPlayer_weapon_defender
global function OnWeaponPrimaryAttack_weapon_defender

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_defender
#endif // #if SERVER

// Cursed Titanfall callback stuff
struct {
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_defender
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_defender( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_defender.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_defender"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_defender.append( callback )
}
//////////////////////////////////////


void function MpWeaponDefender_Init()
{
	DefenderPrecache()
}

void function DefenderPrecache()
{
	PrecacheParticleSystem( $"P_wpn_defender_charge_FP" )
	PrecacheParticleSystem( $"P_wpn_defender_charge" )
	PrecacheParticleSystem( $"defender_charge_CH_dlight" )

	PrecacheParticleSystem( $"wpn_muzzleflash_arc_cannon_fp" )
	PrecacheParticleSystem( $"wpn_muzzleflash_arc_cannon" )
}

var function OnWeaponPrimaryAttack_weapon_defender( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( weapon.GetWeaponChargeFraction() < 1.0 )
		return 0
	return FireDefender( weapon, attackParams )
}


#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_defender( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireDefender( weapon, attackParams )
}
#endif // #if SERVER

int function FireDefender( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )

	foreach ( callback in file.onPrimaryAttackPlayerCallbacks_weapon_defender)
	{
		callback( weapon, attackParams )
	}

	return 1
}