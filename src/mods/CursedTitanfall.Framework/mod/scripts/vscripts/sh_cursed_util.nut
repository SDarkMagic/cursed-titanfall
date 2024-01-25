globalize_all_functions

const DAMAGE_AGAINST_TITANS 			= 150
const DAMAGE_AGAINST_PILOTS 			= 40

const EMP_DAMAGE_TICK_RATE = 0.3
const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"

#if SERVER
void function PlayerEMPTitanThinkConstant( entity soul )
{
    entity titan = soul.GetTitan()
    entity owner = soul.GetBossPlayer()
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "StopEMPField" )

	//Wait for titan to stand up and exit bubble shield before deploying arc ability.
	WaitTillHotDropComplete( titan )
	soul.EndSignal( "StopEMPField" )

	string attachment = GetEMPAttachmentForTitan( titan )
	int attachID = titan.LookupAttachment( attachment )

	EmitSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

	array<entity> particles = []

	//emp field fx
	vector origin = titan.GetOrigin()
	if ( titan.IsPlayer() )
	{
		entity particleSystem = CreateEntity( "info_particle_system" )
		particleSystem.kv.start_active = 1
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD_1P )

		particleSystem.SetOrigin( origin )
		particleSystem.SetOwner( titan )
		DispatchSpawn( particleSystem )
		particleSystem.SetParent( titan, GetEMPAttachmentForTitan( titan ) )
		particles.append( particleSystem )
	}

	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	if ( titan.IsPlayer() )
		particleSystem.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	else
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD )
	particleSystem.SetOwner( titan )
	particleSystem.SetOrigin( origin )
	DispatchSpawn( particleSystem )
	particleSystem.SetParent( titan, GetEMPAttachmentForTitan( titan ) )
	particles.append( particleSystem )

    AI_CreateDangerousArea(titan, titan, ARC_TITAN_EMP_FIELD_RADIUS, owner.GetTeam(), true, true)
	//titan.SetDangerousAreaRadius( ARC_TITAN_EMP_FIELD_RADIUS )

	OnThreadEnd(
		function () : ( titan, particles )
		{
            StopSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )
			foreach ( particleSystem in particles )
			{
				if ( IsValid_ThisFrame( particleSystem ) )
				{
					particleSystem.ClearParent()
					//particleSystem.Fire( "StopPlayEndCap" )
					particleSystem.Destroy( )
				}
			}
		}
	)

	wait RandomFloat( EMP_DAMAGE_TICK_RATE )

	while ( true )
	{
		origin = titan.GetOrigin()

		RadiusDamage(
   			origin,									// center
   			titan,									// attacker
   			titan,									// inflictor
   			DAMAGE_AGAINST_PILOTS,					// damage
   			DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
   			ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
   			ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
   			SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
   			0,										// distanceFromAttacker
   			DAMAGE_AGAINST_PILOTS,					// explosionForce
   			DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
   			eDamageSourceId.titanEmpField )			// scriptDamageSourceIdentifier
		wait EMP_DAMAGE_TICK_RATE
	}
}

void function ProjectileEMPFieldThinkConstant( entity projectile )
{
    if ( !IsValid( projectile ) )
        return
	projectile.EndSignal( "OnDeath" )
	projectile.EndSignal( "OnDestroy" )
	projectile.EndSignal( "StopEMPField" )

	string attachment = GetEMPAttachmentForTitan( projectile )
	int attachID = projectile.LookupAttachment( attachment )

	EmitSoundOnEntity( projectile, "EMP_Titan_Electrical_Field" )

	array<entity> particles = []

	//emp field fx
	vector origin = projectile.GetOrigin()

	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD )
	particleSystem.SetOwner( projectile )
	particleSystem.SetOrigin( origin )
	DispatchSpawn( particleSystem )
	particleSystem.SetParent( projectile )
	particles.append( particleSystem )

    AI_CreateDangerousArea(projectile, projectile, ARC_TITAN_EMP_FIELD_RADIUS, projectile.GetOwner().GetTeam(), true, true)
	//titan.SetDangerousAreaRadius( ARC_TITAN_EMP_FIELD_RADIUS )

	OnThreadEnd(
		function () : ( projectile, particles )
		{
            StopSoundOnEntity( projectile, "EMP_Titan_Electrical_Field" )
			foreach ( particleSystem in particles )
			{
				if ( IsValid_ThisFrame( particleSystem ) )
				{
					particleSystem.ClearParent()
					//particleSystem.Fire( "StopPlayEndCap" )
					particleSystem.Destroy( )
				}
			}
		}
	)

	wait RandomFloat( EMP_DAMAGE_TICK_RATE )

	while ( true )
	{
		origin = projectile.GetOrigin()

		RadiusDamage(
   			origin,									// center
   			projectile,									// attacker
   			projectile,									// inflictor
   			DAMAGE_AGAINST_PILOTS,					// damage
   			DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
   			ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
   			ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
   			SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
   			0,										// distanceFromAttacker
   			DAMAGE_AGAINST_PILOTS,					// explosionForce
   			DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
   			eDamageSourceId.titanEmpField )			// scriptDamageSourceIdentifier
		wait EMP_DAMAGE_TICK_RATE
	}
}

string function GetEMPAttachmentForTitan( entity titan )
{
	return  "hijack"
}

string function GetEMPAttachmentForProjectile( entity projectile )
{
	return "root"
}
#endif