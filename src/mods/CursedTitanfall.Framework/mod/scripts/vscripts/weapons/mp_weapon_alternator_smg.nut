
global function OnWeaponPrimaryAttack_alternator_smg
global function MpWeaponAlternatorSMG_Init
global function OnWeaponReload_weapon_alternator_smg
global function AddCallback_OnWeaponReload_weapon_alternator_smg
global function AddCallback_OnWeaponPrimaryAttackPlayer_weapon_alternator_smg

#if SERVER
global function OnWeaponNpcPrimaryAttack_alternator_smg
#endif

#if CLIENT
	global function OnClientAnimEvent_alternator_smg
#endif


const ALTERNATOR_SMG_TRACER_FX = $"weapon_tracers_xo16_speed"

// Cursed Titanfall callback stuff
struct {
    array< void functionref( entity, int ) > onWeaponReloadCallbacks_weapon_alternator_smg
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_alternator_smg
} file

void function AddCallback_OnWeaponPrimaryAttackPlayer_weapon_alternator_smg( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_alternator_smg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_alternator_smg"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_alternator_smg.append( callback )
}

void function AddCallback_OnWeaponReload_weapon_alternator_smg( void functionref( entity, int ) callback )
{
    Assert( !file.onWeaponReloadCallbacks_weapon_alternator_smg.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnWeaponReload_weapon_alternator_smg"  )
	file.onWeaponReloadCallbacks_weapon_alternator_smg.append( callback )
}
//////////////////////////////////////


void function MpWeaponAlternatorSMG_Init()
{
	#if CLIENT
		PrecacheParticleSystem( ALTERNATOR_SMG_TRACER_FX )
	#endif
}

var function OnWeaponPrimaryAttack_alternator_smg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	foreach( callback in file.onPrimaryAttackPlayerCallbacks_weapon_alternator_smg )
	{
		callback( weapon, attackParams )
	}
	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

void function OnWeaponReload_weapon_alternator_smg( entity weapon, int milestone )
{
	foreach( callback in file.onWeaponReloadCallbacks_weapon_alternator_smg )
	{
		callback( weapon, milestone )
	}
	return
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_alternator_smg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( weapon, attackParams, false )
}
#endif

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	int damageType = weapon.GetWeaponDamageFlags()
	//if ( weapon.HasMod( "burn_mod_lmg" ) )
	//	damageType = damageType | DF_GIB
	//int modulusRemainder = weapon.GetShotCount() % 2
	//entity owner = weapon.GetWeaponOwner()
	//vector right = owner.GetRightVector()
	//array<float> traceOffsets = [ -2.0, 2.0 ]
	//bool useLeftBarrel = ( modulusRemainder == 0 )
	//attackParams.pos = attackParams.pos + (right * traceOffsets[modulusRemainder] )
	weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )

	return 1
}

#if CLIENT
void function OnClientAnimEvent_alternator_smg( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )
}
#endif