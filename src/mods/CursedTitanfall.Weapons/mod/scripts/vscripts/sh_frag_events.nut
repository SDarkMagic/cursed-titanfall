global function FragEvents_Init

const float PULL_RANGE = 250.0
const float PULL_STRENGTH_MAX = 1000.0
const float PULL_VERT_VEL = 440

const FX_LASERCANNON_AIM = $"P_wpn_lasercannon_aim"
const FX_LASERCANNON_CORE = $"P_lasercannon_core"
const FX_LASERCANNON_MUZZLEFLASH = $"P_handlaser_charge"

const LASER_MODEL = $"models/weapons/empty_handed/w_laser_cannon.mdl"

#if SP
const LASER_FIRE_SOUND_1P = "Titan_Core_Laser_FireBeam_1P_extended"
#else
const LASER_FIRE_SOUND_1P = "Titan_Core_Laser_FireBeam_1P"
#endif

struct {
	entity activeBossTitan
} file

void function FragEvents_Init( )
{
	PrecacheParticleSystem( FX_LASERCANNON_AIM )
	PrecacheParticleSystem( FX_LASERCANNON_CORE )
	PrecacheParticleSystem( FX_LASERCANNON_MUZZLEFLASH )

	PrecacheModel( LASER_MODEL )

    AddRandomEventCallback_FragGrenade( PullAll_To_Singularity )
    AddRandomEventCallback_FragGrenade( CreateRandomQuantity_Decoys )
	AddRandomEventCallback_FragGrenade( CreateClusterExplosion )
	AddRandomEventCallback_FragGrenade( SpawnTurretTick_Frag )
	if ( GameRules_GetGameMode() != FD )
		AddRandomEventCallback_FragGrenade( TempFreeze )
	AddRandomEventCallback_FragGrenade( SpawnReaper_ForPlayer )
	AddRandomEventCallback_FragGrenade( CreateRandomQuantity_Batteries )
	AddRandomEventCallback_FragGrenade( Rocket_Smite )
	AddRandomEventCallback_FragGrenade( NuclearDetonation )
	AddRandomEventCallback_FragGrenade( CreateRandomWeapon )
	//if ( IsModuleLoaded( "cs.fd" ) )
	//	AddRandomEventCallback_FragGrenade( SpawnBoss_ForCallback )
	//AddRandomEventCallback_FragGrenade( CombatMRVN )
	// Trigger a nuke eject
	// If CursedTitanfall.FrontierDefense is enabled, spawn a random boss titan
	// Scorch gas trap ignition?
	// Combat MRVN
	// Spawn spectre squad
	// Smite a random player (Use arc cannon effect, spawn it vertically above a player in the skybox)
	// Smite with aerial laser core
	// Dome shield/titan bubble
	// swap team for ent in blast radiusw
}

void function CreateRandomWeapon( entity projectile )
{
	#if SERVER
	vector origin = projectile.GetOrigin()
	origin.z += 2 // Prevents weapons from being created in the ground since that was happening before
	vector angles = projectile.GetAngles()
	string weaponClass = GetRandomWeaponClass_ForGenerator()
	void functionref( entity ) generator = GetGenerator_FromClass( weaponClass )
	entity weapon = CreateWeaponEntityByNameWithPhysics( weaponClass, origin, angles )
	generator( weapon )
	// Do some celebratory particle effects here on the weapons location when creating it
	#endif
}

void function PullAll_To_Singularity( entity projectile )
{
    thread Threaded_PullAll_To_Singularity( projectile )
}

void function Threaded_PullAll_To_Singularity( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )
    #if SERVER
    array<entity> enemies = GetEnemiesForSingularityEvent( projectile )
    while ( true )
    {
		foreach ( enemy in enemies )
		{
			Proto_SetEnemyVelocity_Pull( enemy, projectile.GetOrigin() )
		}
        WaitFrame()
    }
    #endif
}

void function CreateRandomQuantity_Batteries( entity weapon )
{
	vector origin = weapon.GetOrigin()
	for ( int i = 0; i <= RandomInt( 5 ); i++ )
	{
		printt( "Spawning battery" )
		CreateBattery_AtPosition( origin )
	}
}

void function CreateBattery_AtPosition( vector origin )
{
	#if SERVER
	entity battery = Rodeo_CreateBatteryPack()
	battery.SetOrigin( origin )

	bool result = PutEntityInSafeSpot( battery, null, null, origin, origin )
	if ( !result )
	{
		battery.Destroy() //Can't put the battery anywhere safe, so just destroy it.
	}
	#endif
}

void function CreateRandomQuantity_Decoys( entity weapon )
{
	entity weaponOwner = weapon.GetOwner()
	if ( !weaponOwner.IsPlayer() )
		return // I'm too lazy right now to rewrite the holopilot ability to function with all actors just to allow testing of callbacks
	int decoyCount = RandomIntRange( 1, 20 )
	printt("Creating ", decoyCount, " decoys")
    #if SERVER
    CreateHoloPilotDecoys( weaponOwner, decoyCount )
    #endif
}

void function CreateClusterExplosion( entity weapon )
{
	ProjectileCollisionParams params
	params.projectile = weapon
	params.pos = weapon.GetOrigin()
	params.normal = Normalize( weapon.GetVelocity() )

	if ( !weapon.GetOwner().IsPlayer() )
		return

	#if SERVER
	SpawnClusterMissile_frag( params )
	#endif
}

void function TempFreeze( entity weapon )
{
	entity owner = weapon.GetOwner()
	int team = owner.GetTeam()
	#if SERVER
	array<entity> enemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, owner.GetOrigin(), -1 )

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( IsEnemyTeam( team, guy.GetTeam() ) )
			enemies.append( guy )
	}

	thread TempDisableControls_Threaded( enemies, RandomFloatRange( 2.5,7.5 ) )
	#endif
}
/*
void function CombatMRVN( entity weapon )
{
	#if SERVER
	SpawnCombatMRVN( weapon )
	#endif
}
*/

void function SpawnBoss_ForCallback( entity weapon )
{
	#if SERVER
	if ( file.activeBossTitan != null && IsAlive( file.activeBossTitan ) )
		file.activeBossTitan.Die()
	entity player = weapon.GetOwner()
	int team = player.GetTeam()
	vector origin = weapon.GetOrigin()
	int boss = RandomInt( eFD_Bosses.len() )
	entity npc
	switch ( boss )
    {
        case eFD_Bosses.Kane:
            npc = Spawn_Kane( origin, < 0 , 0 , 0 >, team, 0 )
            break
        case eFD_Bosses.Ash:
           npc = Spawn_Ash( origin, < 0 , 0 , 0 >, team, 0 )
            break
        case eFD_Bosses.Richter:
            npc = Spawn_Richter( origin, < 0 , 0 , 0 >, team, 0 )
            break
        case eFD_Bosses.Viper:
            npc = Spawn_Viper( origin, < 0 , 0 , 0 >, team, 0 )
            break
        case eFD_Bosses.Slone:
            npc = Spawn_Slone( origin, < 0 , 0 , 0 >, team, 0 )
            break
        case eFD_Bosses.Blisk:
            npc = Spawn_Blisk( origin, < 0 , 0 , 0 >, team, 0 )
			break
		default:
			return
    }
	if ( IsValid( npc ) )
	{
		file.activeBossTitan = npc
		EnableTitanRodeo( npc )
	}

	#endif
}

void function Smite_Nade( entity weapon )
{
	vector target = weapon.GetOrigin()
	vector spawnOffset = target + < 0, 300, 0 >
	entity player = weapon.GetOwner()
	int team = player.GetTeam()
	#if SERVER
	CreateLaser( target, team )
	#endif
}

// Taken from Karma's Mod abuse mod
void function SpawnTurretTick_Frag( entity weapon )
{
	#if SERVER
	entity player = weapon.GetOwner()
	if ( !player.IsPlayer() )
		return
	int team = player.GetTeam()

	vector origin = weapon.GetOrigin();
	entity tick = CreateFragDrone( team, origin, <0,0,0> )
	SetSpawnOption_AISettings(tick, "npc_frag_drone_fd")
	tick.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_NEW_ENEMY_FROM_SOUND)
	tick.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)
	DispatchSpawn( tick )
	tick.Minimap_AlwaysShow( TEAM_IMC, null )
	tick.Minimap_AlwaysShow( TEAM_MILITIA, null )
	tick.SetValueForModelKey( $"models/robots/drone_frag/drone_frag.mdl" )
	StatusEffect_AddEndless( tick, eStatusEffect.speed_boost, 1 )

	tick.SetTitle( "The Fuck You Tick" )
	// tick.SetTakeDamageType( DAMAGE_NO )
	tick.SetDamageNotifications( false )
	tick.SetNPCMoveSpeedScale( 10.0 )
	ShowName( tick )


	entity turret = CreateEntity( "npc_turret_sentry" )
	turret.SetOrigin( origin + <0,0,30> )
	turret.SetAngles( <0,0,0> )
	turret.SetBossPlayer( player )
	turret.ai.preventOwnerDamage = true
	turret.StartDeployed()
	SetTeam( turret, team )

	SetSpawnOption_AISettings( turret, "npc_turret_sentry_burn_card_ap_fd" )
	turret.SetParent( tick )
	DispatchSpawn( turret )
	turret.SetMaxHealth(500)
	turret.SetHealth(turret.GetMaxHealth())

	array<entity> players = GetPlayerArrayOfEnemies( tick.GetTeam() )
	if ( players.len() != 0 )
	{
		entity player = GetClosest2D( players, tick.GetOrigin() )
		tick.AssaultPoint( player.GetOrigin() )
	}
	UpdateEnemyMemoryWithinRadius( tick, 1000 )
	thread TickThink( tick )
	#endif
}

#if SERVER
void function TickThink( entity tick )
{
	array<entity> players
	while( IsAlive( tick ) )
	{
		players = GetPlayerArrayOfEnemies( tick.GetTeam() )
		if ( players.len() != 0 )
		{
			entity player = GetClosest2D( players, tick.GetOrigin() )
			tick.AssaultPoint( player.GetOrigin() )
		}
		wait RandomFloatRange(10.0,20.0)
	}
}
#endif

//////////////////////////////////////////

void function SpawnReaper_ForPlayer( entity weapon )
{
	#if SERVER
    entity player = weapon.GetOwner()
	if ( !IsValid(player) )
		return
    int team = player.GetTeam()
    vector origin = weapon.GetOrigin();

	entity reaper = CreateSuperSpectre( team, origin, < 0, 0, 0 > )
	if ( player.IsPlayer() )
	    reaper.SetBossPlayer( player )
    SetTeam( reaper, team )
    DispatchSpawn( reaper )
	reaper.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	reaper.kv.AccuracyMultiplier = 1.0
	reaper.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
	reaper.SetAllowSpecialJump( true )
	reaper.SetBehaviorSelector( "behavior_super_spectre" )
	reaper.Minimap_AlwaysShow( team, null )
	thread SuperSpectre_WarpFall( reaper )
	AddReaper( reaper )
	#endif
}


void function Rocket_Smite( entity weapon )
{
	vector origin = weapon.GetOrigin()
	entity owner = weapon.GetOwner()
#if SERVER
	//thread CreateLaser( origin, team )
	int numRockets = RandomIntRange( 12, 45 )
	thread OrbitalStrike( owner, origin, numRockets, numRockets * 5.0 )
#endif
}

void function NuclearDetonation( entity weapon )
{
	#if SERVER
	RadiusDamageData radiusDamage
	radiusDamage.explosionDamage = 47 // Same formula as explosionDamageHeavyArmor, just using 75 instead of 2500 for the base damage amount
	radiusDamage.explosionDamageHeavyArmor = 1562 // NPC nuke titan damage is caluclated from the formula ( playerExplosionCount / actualExplosionCount ) * 2500 where 2500 is the default amount per explosion with 10 explosions from a normal nuclear payload
	radiusDamage.explosionRadius = 675 // Nuclear payload outer radius for players starts at 600 for the first impact, then expands outwards to 750. 675 is the average
	radiusDamage.explosionInnerRadius = 350

	thread DoNuclearExplosion( weapon, eDamageSourceId.mp_weapon_frag_grenade, radiusDamage )
	#endif
}

#if SERVER
/*
void function SpawnCombatMRVN( entity weapon )
{
	entity player = weapon.GetOwner()
	vector origin = weapon.GetOrigin()
	int team = player.GetTeam()
	if ( !IsValid(player) )
		return
	if ( !player.IsPlayer() )
		return
	entity mrvn = CreateEntity( "npc_soldier" )
	SetTeam( mrvn, team )
	mrvn.SetOrigin( origin )
	mrvn.SetOwner( player )
	SetSpawnOption_Weapon( mrvn, "mp_weapon_lmg" )
	mrvn.SetBossPlayer( player )
	SetSpawnOption_AISettings( mrvn, "npc_marvin_combat" )
	DispatchSpawn( mrvn )
	mrvn.kv.WeaponProficiency = eWeaponProficiency.PERFECT
	mrvn.SetBehaviorSelector( "behavior_spectre" )
	mrvn.SetModel( $"models/robots/marvin/marvin.mdl" )

}
*/

void function CreateLaser( vector origin, int team )
{
	entity bullseye = SpawnBullseye( team )
	bullseye.SetOrigin( origin )
	vector beamOffset = origin + < 0, 0, 1000 >
	vector angles = CalcRelativeAngles( beamOffset, origin )
	entity npc = CreateNPCTitan( "titan_atlas", team, beamOffset, angles )
	npc.EndSignal( "CoreEnd" )
    SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd_elite" )
    SetTitanAsElite( npc )

	SetTeam( npc, GetOtherTeam( team ) )
	DispatchSpawn( npc )

	//npc.Hide()
	npc.LockEnemy( bullseye )
	entity soul = npc.GetTitanSoul()
	SoulTitanCore_SetNextAvailableTime( soul, 1.0 )
	npc.kv.gravity = 0.0

	/*
	OnThreadEnd(
	function() : ( bullseye, npc )
		{
			if ( IsValid( npc ) )
				npc.Destroy()
			if ( IsValid( bullseye ) )
				bullseye.Destroy()
		}
	)
	*/
}

array<entity> function GetEnemiesForSingularityEvent( entity projectile )
{
	int team = projectile.GetTeam()
	entity owner = projectile.GetOwner()
	vector origin = projectile.GetOrigin()
	array<entity> nearbyEnemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, -1 )

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		//if ( IsEnemyTeam( team, guy.GetTeam() ) )
		nearbyEnemies.append( guy )
	}

	array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, -1 )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			nearbyEnemies.append( guy )
	}

	return nearbyEnemies
}

void function Proto_SetEnemyVelocity_Pull( entity enemy, vector projOrigin )
{
	if( !IsValid( enemy ) || !IsAlive( enemy ) )
		return
	if ( enemy.IsPhaseShifted() )
		return
	vector enemyOrigin = enemy.GetOrigin()
	vector dir = Normalize( projOrigin - enemy.GetOrigin() )
	float dist = Distance( enemyOrigin, projOrigin )
	float distZ = enemyOrigin.z - projOrigin.z
	vector newVelocity = enemy.GetVelocity() * GraphCapped( dist, 50, PULL_RANGE, 0, 1 ) + dir * GraphCapped( dist, 50, PULL_RANGE, 0, PULL_STRENGTH_MAX ) + < 0, 0, GraphCapped( distZ, -50, 0, PULL_VERT_VEL, 0 )>
	enemy.SetVelocity( newVelocity )
}

void function SpawnClusterMissile_frag( ProjectileCollisionParams params )
{
	entity rocket = params.projectile
	vector normal = params.normal
	vector pos = params.pos
	float explosionDelay = 0

	entity owner = rocket.GetOwner()
	if ( !IsValid( owner ) )
		return

	int count
	float duration
	float range

	array<string> mods = rocket.ProjectileGetMods()
	count = CLUSTER_ROCKET_BURST_COUNT
	duration = 3.0
	range = CLUSTER_ROCKET_BURST_RANGE

	PopcornInfo popcornInfo

	popcornInfo.weaponName = "mp_weapon_frag_grenade"
	popcornInfo.weaponMods = []
	popcornInfo.damageSourceId = eDamageSourceId.mp_weapon_frag_grenade
	popcornInfo.count = 15
	popcornInfo.delay = 0.2
	popcornInfo.offset = CLUSTER_ROCKET_BURST_OFFSET
	popcornInfo.range = range
	popcornInfo.normal = normal
	popcornInfo.duration = duration
	popcornInfo.groupSize = 4
	popcornInfo.hasBase = true

	thread StartClusterExplosions( rocket, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
	CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, pos, ( duration + explosionDelay ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
}

void function TempDisableControls_Threaded( array< entity > players, float duration )
{
	DisablePlayersControls( players )
	wait duration
	EnablePlayersControls( players )
}

void function DisablePlayersControls( array< entity > players )
{
	foreach( entity player in players )
	{
		player.MovementDisable()
        player.ConsumeDoubleJump()
        player.DisableWeaponViewModel()
	}
}

void function EnablePlayersControls( array< entity > players )
{
	foreach( entity player in players )
	{
		player.MovementEnable()
        player.EnableWeaponViewModel()
	}
}

#endif