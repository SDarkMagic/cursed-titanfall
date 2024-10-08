// Taken from https://github.com/TheAvaliEngineer/TF-2-Nuke-Code
//		Func decs
global function DoNuclearExplosion

//		Vars
//	Nuclear explosion properties
const int NUCLEAR_STRIKE_EXPLOSION_COUNT = 16
const float NUCLEAR_STRIKE_EXPLOSION_TIME = 1.4

//	Nuclear explosion FX (this needs to be precached)
const var NUCLEAR_STRIKE_FX_3P = $"P_xo_exp_nuke_3P_alt"
const var NUCLEAR_STRIKE_FX_1P = $"P_xo_exp_nuke_1P_alt"
const var NUCLEAR_STRIKE_SUN_FX = $"P_xo_nuke_warn_flare"

#if SERVER
void function DoNuclearExplosion( entity projectile, int eDamageSourceIdGoesHere, RadiusDamageData radiusDamage ) {
	//	Var initialisation
	int explosions = NUCLEAR_STRIKE_EXPLOSION_COUNT
	float time = NUCLEAR_STRIKE_EXPLOSION_TIME
	float explosionInterval = time / explosions

	vector origin = projectile.GetOrigin()

	entity player = projectile.GetOwner()
	int team = player.GetTeam()
	//radiusDamage = GetRadiusDamageDataFromProjectile( projectile, player )

	int normalDamage = radiusDamage.explosionDamage
	int titanDamage = radiusDamage.explosionDamageHeavyArmor
	float innerRadius = radiusDamage.explosionInnerRadius
	float outerRadius = radiusDamage.explosionRadius

	//	Sun FX
	array< entity > nukeFX = []

	//	Create Inflictor
	entity inflictor = CreateEntity( "script_ref" )
	inflictor.SetOrigin( origin )

	inflictor.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT

	DispatchSpawn( inflictor )

	nukeFX.append( PlayFXOnEntity( NUCLEAR_STRIKE_SUN_FX, inflictor ) )
	EmitSoundOnEntity( inflictor, "titan_nuclear_death_charge" )

	wait 2.5 //2.05

	//	Clear sun FX
	ClearNuclearBlueSunEffect( nukeFX )

	//	Explosion FX
	if( IsValid(player) ) {
		thread __CreateFxInternal( NUCLEAR_STRIKE_FX_1P, null, "", origin,
			Vector(0, RandomInt(360), 0), C_PLAYFX_SINGLE, null, 1, player )
		thread __CreateFxInternal( NUCLEAR_STRIKE_FX_3P, null, "", origin + Vector(0, 0, -100),
			Vector(0, RandomInt(360), 0), C_PLAYFX_SINGLE, null, 6, player )
	} else {
		PlayFX( NUCLEAR_STRIKE_FX_3P, origin + Vector(0, 0, -100), Vector(0, RandomInt(360), 0) )
	}

	EmitSoundAtPosition( team, origin, "titan_nuclear_death_explode" )

	//	Thread end
	OnThreadEnd( function() : ( projectile, inflictor ) {
			if ( !IsValid(projectile) || projectile.GrenadeHasIgnited() )
				return
			projectile.GrenadeIgnite()

			if ( IsValid(inflictor) )
				inflictor.Destroy()
		}
	)

	//	Spawn explosions
	for( int i = 0; i < explosions; i++ ) {
		RadiusDamage(
			origin,												// origin
			player,												// owner
			inflictor,		 									// inflictor
			normalDamage,										// normal damage
			titanDamage,										// heavy armor damage
			innerRadius,										// inner radius
			outerRadius,										// outer radius
			SF_ENVEXPLOSION_NO_NPC_SOUND_EVENT,					// explosion flags
			0, 													// distanceFromAttacker
			0, 													// explosionForce
			0,													// damage flags
			eDamageSourceIdGoesHere								// damage source id
		)

		wait explosionInterval
	}
}

void function ClearNuclearBlueSunEffect( array< entity > nukeFX ) {
	foreach( fx in nukeFX ) {
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	nukeFX.clear()
}
#endif