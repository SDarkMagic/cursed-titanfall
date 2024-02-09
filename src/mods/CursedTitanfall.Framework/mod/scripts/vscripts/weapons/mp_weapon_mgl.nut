
global function OnWeaponActivate_weapon_mgl
global function OnWeaponPrimaryAttack_weapon_mgl
global function OnProjectileCollision_weapon_mgl
global function AddCallback_OnPrimaryAttackPlayer_weapon_mgl
global function AddCallback_OnProjectileCollision_weapon_mgl

#if CLIENT
global function OnClientAnimEvent_weapon_mgl
#endif // #if CLIENT

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_mgl
#endif // #if SERVER

const MAX_BONUS_VELOCITY	= 1250

// Cursed Titanfall callback stuff
struct {
    array< void functionref( ProjectileCollisionParams ) > onProjectileCollisionCallbacks_weapon_mgl
    array< void functionref( entity, WeaponPrimaryAttackParams ) > onPrimaryAttackPlayerCallbacks_weapon_mgl
} file

void function AddCallback_OnPrimaryAttackPlayer_weapon_mgl( void functionref( entity, WeaponPrimaryAttackParams ) callback )
{
    Assert( !file.onPrimaryAttackPlayerCallbacks_weapon_mgl.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPrimaryAttackPlayer_weapon_mgl"  )
	file.onPrimaryAttackPlayerCallbacks_weapon_mgl.append( callback )
}

void function AddCallback_OnProjectileCollision_weapon_mgl( void functionref( ProjectileCollisionParams ) callback )
{
    Assert( !file.onProjectileCollisionCallbacks_weapon_mgl.contains( callback ), "Already added " + string( callbackFunc ) + " with AddCallback_OnProjectileCollision_weapon_mgl"  )
	file.onProjectileCollisionCallbacks_weapon_mgl.append( callback )
}
//////////////////////////////////////

void function OnWeaponActivate_weapon_mgl( entity weapon )
{
#if CLIENT
	UpdateViewmodelAmmo( false, weapon )
#endif // #if CLIENT
}

#if CLIENT
void function OnClientAnimEvent_weapon_mgl( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )
}
#endif // #if CLIENT

var function OnWeaponPrimaryAttack_weapon_mgl( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	//vector bulletVec = ApplyVectorSpread( attackParams.dir, player.GetAttackSpreadAngle() * 2.0 )
	//attackParams.dir = bulletVec

	foreach ( callback in file.onPrimaryAttackPlayerCallbacks_weapon_mgl )
	{
		callback ( weapon, attackParams )
	}

	if ( IsServer() || weapon.ShouldPredictProjectiles() )
	{
		FireGrenade( weapon, attackParams )
	}
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_mgl( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	FireGrenade( weapon, attackParams, true )
}
#endif // #if SERVER

void function FireGrenade( entity weapon, WeaponPrimaryAttackParams attackParams, bool isNPCFiring = false )
{
	vector angularVelocity = Vector( RandomFloatRange( -1200, 1200 ), 100, 0 )
	entity nade = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir, angularVelocity, 0, damageTypes.explosive, damageTypes.explosive, !isNPCFiring, true, false )

	if ( nade )
	{
		entity weaponOwner = weapon.GetWeaponOwner()
		#if SERVER
			EmitSoundOnEntity( nade, "Weapon_MGL_Grenade_Emitter" )
			Grenade_Init( nade, weapon )
		#else
			//InitMagnetic needs to be after the team is set on both client and server.
			SetTeam( nade, weaponOwner.GetTeam() )
		#endif

		nade.InitMagnetic( MGL_MAGNETIC_FORCE, "Explo_MGL_MagneticAttract" )

		//thread MagneticFlight( nade, MGL_MAGNETIC_FORCE )
	}
}

void function OnProjectileCollision_weapon_mgl( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{

	ProjectileCollisionParams params
    params.projectile = projectile
    params.pos = pos
    params.normal = normal
    params.hitEnt = hitEnt
    params.hitbox = hitbox
    params.isCritical = isCritical

	if ( !IsValid( hitEnt ) )
		return

	foreach( callback in file.onProjectileCollisionCallbacks_weapon_mgl )
    {
        callback( params )
    }

	if ( IsMagneticTarget( hitEnt ) && IsValid( projectile ) )
	{
		if ( hitEnt.GetTeam() != projectile.GetTeam() )
		{
			projectile.ExplodeForCollisionCallback( normal )
		}
	}
}
