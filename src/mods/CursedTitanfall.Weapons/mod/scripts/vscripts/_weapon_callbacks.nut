global function Init_Custom_Weapon_Callbacks

#if SERVER
global function KillTargetThenExplode
#endif

void function Init_Custom_Weapon_Callbacks()
{
    printt("Initializing Custom weapon callback functions...")
    #if SERVER
    AddCallback_OnProjectileCollision_weapon_epg(Weapon_Epg_Collision)
    AddCallback_OnPrimaryAttackPlayer_weapon_defender(Dash_Player)
    AddCallback_OnProjectileCollision_weapon_softball(Softball_ESmoke)
    AddCallback_OnProjectileCollision_weapon_wingman(Wingman_Teleport)
	AddCallback_OnProjectileCollision_weapon_smr( SpawnClusterMissile_smr )
	AddCallback_OnProjectileCollision_weapon_wingman(DisplayPlayerCoords)
    AddCallback_OnPrimaryAttackPlayer_weapon_sniper(Russian_Roulette)
	AddCallback_OnProjectileCollision_weapon_mgl( SpawnTick )
    //AddCallback_OnPrimaryAttackPlayer_weapon_lmg(Thread_PreventCamping)

	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_emp, Grenade_Emp_Hack )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_semipistol, Pistol_Callback )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_car, PushEnt_WhenHit_Callback )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_r97, DetonateOnDeath )

	AddCallback_NPCLeeched( ReaperLeeched )
    #endif
}

#if SERVER
void function Weapon_Epg_Collision( ProjectileCollisionParams params )
{
    entity prowler = CreateEntity( "npc_prowler" )
    entity player = params.projectile.GetOwner()
	if ( !IsValid(player) )
		return
    int team = player.GetTeam()
    vector spawnOffset = -150 * Normalize(params.projectile.GetVelocity()) // Move the spawn point back by 150 units of the projectile's velocity vector

    prowler.SetOrigin(params.pos + spawnOffset)
    prowler.SetAngles(params.projectile.GetAngles())
	if ( player.IsPlayer() )
	    prowler.SetBossPlayer(player)
    SetTeam(prowler, team)
    DispatchSpawn(prowler)
    AddProwler(prowler)
    return
}

void function Dash_Player(entity weapon, WeaponPrimaryAttackParams attackParams)
{
	printt("Called Dash_Player function")
	entity player = weapon.GetWeaponOwner()
	//if ( !player.IsPlayer() )
	//	return
	float speedModifier = -600
	vector viewDirection = player.GetPlayerOrNPCViewVector()
	vector appliedVelocity = viewDirection * (speedModifier * weapon.GetWeaponChargeTime()) // Scale the applied velocity based on how long the weapon needs to charge for. Then create apply the speed modifier to the velocity vector to get the applied force.

	player.SetVelocity(player.GetVelocity() + appliedVelocity)
    return
}

void function Softball_ESmoke( ProjectileCollisionParams params )
{
    entity hitEnt = params.hitEnt
    entity projectile = params.projectile
    if ( IsValid( hitEnt ) && ( hitEnt.IsPlayer() || hitEnt.IsTitan() || hitEnt.IsNPC() ) )
		{
			ElectricGrenadeSmokescreen( projectile, FX_ELECTRIC_SMOKESCREEN_PILOT_AIR )
		}
		else
		{
			ElectricGrenadeSmokescreen( projectile, FX_ELECTRIC_SMOKESCREEN_PILOT )
		}
    return
}

void function Wingman_Teleport( ProjectileCollisionParams params )
{
    entity projectile = params.projectile
	entity player = projectile.GetOwner()
	if ( !player.IsPlayer() )
		return
    vector spawnOffset = -150 * Normalize(projectile.GetVelocity()) // Move the spawn point back by 150 units of the projectile's velocity vector

    player.SetOrigin(params.pos + spawnOffset)
    return
}

void function Russian_Roulette( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return
    if (RandomInt(15) == 5)
	{
		player.TakeDamage( player.GetHealth(), null, null, { weapon = weapon, damageSourceId = eDamageSourceId.mp_weapon_sniper } )
        Explosion_DamageDefSimple(
            damagedef_titan_hotdrop,
            weapon.GetOrigin(),
            player,
            null,
            weapon.GetOrigin()
        )
	}
}

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

void function PreventCamping( entity weapon, WeaponPrimaryAttackParams attackParams )
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

void function Thread_PreventCamping( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    thread PreventCamping(weapon, attackParams)
}

void function Grenade_Emp_Hack( entity target, var damageInfo )
{
	string className = target.GetClassName()
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker) || !attacker.IsPlayer() )
		return
	DamageInfo_SetDamage( damageInfo, 0 )
	switch ( className )
	{
		case "npc_spectre":
			LeechSurroundingSpectres( target.GetOrigin(), attacker ) // if it's a spectre group, try to hack the whole group. Otherwise, hack just the entity that was hit
		case "npc_super_spectre":
		case "npc_drone":
			LeechGeneric( target, attacker )
	}
}

void function ReaperLeeched( entity victim, entity attacker )
{
	if ( !victim.IsNPC() || victim.GetClassName() != "npc_super_spectre" )
		return
	switch ( GameRules_GetGameMode() )
	{
		case "fd_easy":
		case "fd_normal":
		case "fd_hard":
		case "fd_master":
		case "fd_insane":
		case "fd":
			attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_SPECTRE )
			AddMoneyToPlayer( attacker, 20 )

	}
	AddReaper( victim )
	victim.kv.AccuracyMultiplier = 1.0
	victim.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
	victim.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	victim.SetBehaviorSelector( "behavior_super_spectre" )
	victim.Minimap_AlwaysShow( TEAM_MILITIA, null )
}

void function Pistol_Callback( entity target, var damageInfo )
{
	entity player = DamageInfo_GetAttacker(damageInfo)
	//if ( !player.IsPlayer() )
	//	return
    int team = player.GetTeam()
    array<entity> enemies = GetPlayerArrayOfEnemies(team)
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	if ( !IsValid( weapon ) )
		return
	enemies.extend( GetNPCArrayOfEnemies(team) )
	array<entity> titans = GetTitanArrayOfEnemies(team)
	enemies.extend(titans)
	DamageInfo_SetDamage( damageInfo, 0 )
	int probabilityCeiling = weapon.GetWeaponPrimaryClipCountMax() * 4
	int chance = RandomInt( probabilityCeiling )
	if ( chance == 3 || IsPlayerAdmin( player ) )
	{
		printt("Wiping enemy team. Get rekt")
		foreach (entity enemy in enemies)
		{
			if ( !IsValid(enemy) || !IsAlive(enemy) )
				continue
			if ( enemy.IsTitan() )
			{
				entity soul = enemy.GetTitanSoul()
				//if ( !soul.IsDoomed() )
					//enemy.TakeDamage( enemy.GetHealth(), player, null, { weapon = weapon } )
			}
			enemy.TakeDamage( enemy.GetHealth(), player, null, { damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } )
		}
	}
	else if ( chance > probabilityCeiling * 0.8 )
	{
		if ( !player.IsPlayer() )
			return
		player.TakeDamage( player.GetHealth(), player, null, { damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } ) //50% chance of killing the player on failure
		string publicShaming = player.GetPlayerName() + " gambled their life away"
		foreach ( entity guy in GetPlayerArray() )
		{
			NSSendAnnouncementMessageToPlayer( guy, publicShaming, "Don't be like them. Use a good secondary.", <1,1,0>, 1, 1 )
		}
	}

}

void function DisplayPlayerCoords( ProjectileCollisionParams params )
{
	entity projectile = params.projectile
	entity player = projectile.GetOwner()
	if ( !player.IsPlayer() )
		return
    printt("routes[ \"\" ].append( " + params.pos + " )")
}

void function SpawnClusterMissile_smr( ProjectileCollisionParams params )
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
	duration = 0.5
	range = CLUSTER_ROCKET_BURST_RANGE

	PopcornInfo popcornInfo

	popcornInfo.weaponName = "mp_weapon_smr"
	popcornInfo.weaponMods = []
	popcornInfo.damageSourceId = eDamageSourceId.mp_weapon_smr
	popcornInfo.count = 3
	popcornInfo.delay = 0.2
	popcornInfo.offset = CLUSTER_ROCKET_BURST_OFFSET
	popcornInfo.range = range
	popcornInfo.normal = normal
	popcornInfo.duration = duration
	popcornInfo.groupSize = 3
	popcornInfo.hasBase = true

	thread StartClusterExplosions( rocket, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
	CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, pos, ( duration + explosionDelay ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
}

void function PushEnt_WhenHit_Callback( entity target, var damageInfo )
{
	int source = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	switch ( source )
	{
 		case eDamageSourceId.mp_titanweapon_vortex_shield:
  		case eDamageSourceId.mp_titanweapon_vortex_shield_ion:
			return
	}

	entity projectile = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( projectile ) )
		return

	vector attackDirection = Normalize( projectile.GetPlayerOrNPCViewVector() )
	float damage = DamageInfo_GetDamage( damageInfo )

	PushEntWithDamageFromDirection( target, damage, attackDirection, 7.5, 1.0 )
}

void function SpawnTick( ProjectileCollisionParams params )
{
    entity player = params.projectile.GetOwner()
	if ( !IsValid(player) )
		return
    int team = player.GetTeam()
    vector spawnOffset = -150 * Normalize( params.projectile.GetVelocity() ) // Move the spawn point back by 150 units of the projectile's velocity vector
	vector origin = params.pos + spawnOffset
	vector angles = <0,0,0>

	entity npc = CreateNPC( "npc_frag_drone", team, origin, angles )
	if ( player.IsPlayer() )
	    npc.SetBossPlayer(player)
    DispatchSpawn(npc)
	params.projectile.Destroy()
	AddTick( npc )
	return
}

void function DetonateOnDeath( entity target, var damageInfo )
{
	if ( !IsValid( target ) || !IsAlive( target ) )
		return
	float damage = DamageInfo_GetDamage( damageInfo )
	int damageFlags = DamageInfo_GetDamageFlags( damageInfo )
    int targetHealth = target.GetHealth()
	int targetMaxHealth = target.GetMaxHealth()
    if ( ( targetHealth - damage > 0 && targetHealth > 0 ) || target.IsTitan() )
        return

	int dmgSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	vector origin = target.GetOrigin()
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
	vector projectileOrigin = attacker.GetOrigin()

	int innerRad = 75
	int outerRad = 200
	int force = 1000
	KillTargetThenExplode( target, attacker, eDamageSourceId.flash_surge, targetMaxHealth * 2, targetMaxHealth * 4, innerRad, outerRad, force, damageFlags, "exp_satchel")
}

void function KillTargetThenExplode( entity target, entity attacker, int sourceId, int explosionDamage, int explosionDamageArmor, int innerRad, int outerRad, int force, int damageFlags, string effectTable )
{
	vector origin= target.GetOrigin()
	vector projectileOrigin = attacker.GetOrigin()
	int damage = target.GetHealth()
	target.TakeDamage(damage, null, null, { weapon = null, damageSourceId = sourceId })
	Explosion( origin, attacker, attacker, explosionDamage, explosionDamageArmor, innerRad, outerRad, damageFlags, projectileOrigin, force, damageFlags, sourceId, effectTable )
}

#endif