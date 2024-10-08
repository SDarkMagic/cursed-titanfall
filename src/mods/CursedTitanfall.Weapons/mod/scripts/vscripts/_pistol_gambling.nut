global function Init_Pistol_Gambling_Callbacks

void function Init_Pistol_Gambling_Callbacks()
{
    printt("Initializing Gambling...")
    #if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_semipistol, Pistol_Callback )
    #endif
}

const GRACE_PERIOD = 2.5

struct GamblerData {
    float lastFireTime
    float currentMultiplier = 4.0
    int risk = 0
}

struct {
    table< entity, GamblerData > gamblers
} file

#if SERVER
void function Pistol_Callback( entity target, var damageInfo )
{
	entity player = DamageInfo_GetAttacker(damageInfo)
    int team = player.GetTeam()
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    GamblerData probabilityModifiers
	if ( !IsValid( weapon ) )
		return
	if ( player.IsNPC() && !target.IsPlayer() )
		return
	DamageInfo_SetDamage( damageInfo, 0 )
    float multiplier = 4.0

    if( player.IsPlayer() )
    {
        probabilityModifiers = expect GamblerData( GetGamblerData( player ) )
        float now = Time()
        float timeDiff = now - probabilityModifiers.lastFireTime
        if( timeDiff > GRACE_PERIOD )
            probabilityModifiers.currentMultiplier = 4.0 // Reset the base multiplier if the player hasn't shot at all during the grace period. This is to prevent rapid firing
        else
            probabilityModifiers.currentMultiplier += timeDiff
        multiplier = probabilityModifiers.currentMultiplier + ( probabilityModifiers.risk * 10 )

        if( probabilityModifiers.currentMultiplier >= 10.0 )
        {
            probabilityModifiers.risk += 1 // Risk never gets reset within a match, so it's a more permanent punishment for players spamming
            probabilityModifiers.currentMultiplier = 4.0
        }
        probabilityModifiers.lastFireTime = now
        SetGamblerData( player, probabilityModifiers )
        printt("Current multiplier for ", player, multiplier)
    }

	int probabilityCeiling = int( weapon.GetWeaponPrimaryClipCountMax() * multiplier )
	int chance = RandomInt( probabilityCeiling )
	if ( chance == 3 || ( IsPlayerAdmin( player ) && weapon.HasMod( "pro_screen" ) ) || weapon.HasMod( "guarantee_wipe" ) )
	{
		printt("Wiping enemy team. Get rekt")
        array<entity> enemies = GetPlayerArrayOfEnemies(team)
        enemies.extend( GetNPCArrayOfEnemies(team) )
        array<entity> titans = GetTitanArrayOfEnemies(team)
        enemies.extend(titans)
		foreach (entity enemy in enemies)
		{
			if ( !IsValid(enemy) || !IsAlive(enemy) )
				continue
			if ( enemy.IsTitan() )
			{
				entity soul = enemy.GetTitanSoul()
				if ( !soul.IsDoomed() )
					soul.EnableDoomed()
			}
			//enemy.Die() // This will bypass any damage scaling, however the damagesourceid for the obituary could be weird to handle. Not implementing this method for now
			enemy.TakeDamage( enemy.GetHealth(), player, null, { damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } )
		}
	}
	else if ( chance > probabilityCeiling * 0.85 )
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

GamblerData ornull function GetGamblerData( entity player )
{
    if( !IsValid( player ) || !IsAlive( player ) )
        return
    if( !( player in file.gamblers ) )
    {
        GamblerData data
        data.lastFireTime = Time()
        SetGamblerData( player, data )
    }
    return file.gamblers[player]
}

void function SetGamblerData( entity player, GamblerData data )
{
    if( !IsValid( player ) || !IsAlive( player ) )
        return
    GamblerData defaultData
    if ( !( player in file.gamblers ) )
        file.gamblers[player] <- defaultData

    file.gamblers[player] = data
}
#endif