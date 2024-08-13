global function Init_Monarch_Healing_Shots

#if CLIENT
global function Server_UpdateClientHealthPool
#endif

const RESERVE_HEALTH_POOL_MAX_VALUE = 4000
const WEAPON_BASE_HEAL_COST = 40

#if SERVER
struct ReserveHealthPool {
    float current
    int totalUsed
    float max = 4000
    bool hasChanged = true
    string msgId
}

struct {
    table< entity, ReserveHealthPool > healthPools
} file
#endif

#if CLIENT
struct {
    var energyBarRui = null
    float currentHealthPool = 0
} file
#endif

void function Init_Monarch_Healing_Shots( )
{
    #if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_xo16_vanguard, Energy_Transfer_Primary_Weapon_Callback )
    AddCallback_OnPilotBecomesTitan( Healer_InitPlayer )
    AddCallback_OnTitanBecomesPilot( Healer_CleanupPlayer )
    AddCallback_OnPrimaryAttackPlayer_titancore_upgrade( UpgradeCore_ReInitPlayer )
    //RegisterNetworkedVariable( "monarch_reserve_health", SNDC_PLAYER_GLOBAL, SNVT_FLOAT_RANGE, 0.0, 0.0, 20000.0 )
    #endif
    // TODO Implement a bar similar to Ion's energy bar for this to display available health pool.
    //AddCallback_OnRegisteringCustomNetworkVars( RegisterNetworkVars )

    #if CLIENT
    //AddTitanCockpitManagedRUI( Monarch_CreateHealPoolBar, Monarch_DestroyHealPoolBar, Monarch_ShouldCreateHealPoolBar, RUI_DRAW_COCKPIT)
    #endif
}

void function RegisterNetworkVars()
{

    Remote_RegisterFunction( "Server_UpdateClientHealthPool" )
}

#if SERVER
void function Energy_Transfer_Primary_Weapon_Callback( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity offhandWeapon = attacker.GetOffhandWeapon( OFFHAND_LEFT )
    if ( !attacker.IsPlayer() || !offhandWeapon.HasMod("energy_transfer") )
        return
    if ( attacker.GetTeam() == target.GetTeam() && target.IsTitan())
        Heal_Teammate( target, damageInfo )
    else if (attacker.GetTeam() == target.GetTeam())
        return
    else
        Charge_Meter( damageInfo )

    //Remote_CallFunction_Replay( attacker, "Server_UpdateClientHealthPool", file.healthPools[attacker].current)
}

void function UpgradeCore_ReInitPlayer( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity player = weapon.GetWeaponOwner()
    entity titan = player.GetTitanSoul()
    Healer_InitPlayer( player, titan )
}

void function Healer_InitPlayer( entity player, entity titan )
{
    if ( !player.IsTitan() )
        return

    ReserveHealthPool healthPool
    if ( player in file.healthPools )
    {
        healthPool = file.healthPools[player]
    }
    else
    {
        healthPool.current = 0
        healthPool.totalUsed = 0
    }

    healthPool.max = float( player.GetMaxHealth() )
    file.healthPools[player] <- healthPool
    entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_LEFT )
    if ( offhandWeapon.HasMod("energy_transfer") )
        CreateHealthPoolRui( player )
}

void function Healer_CleanupPlayer( entity player, entity titan )
{
    entity offhandWeapon = titan.GetOffhandWeapon( OFFHAND_LEFT )
    if ( offhandWeapon.HasMod("energy_transfer") )
        DeleteHealthPoolRui( player )
}

void function Charge_Meter( var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    float rechargeAmount = DamageInfo_GetDamage( damageInfo ) / 2
    float reserveHealthPoolMax = file.healthPools[attacker].max
    if ( file.healthPools[attacker].current + rechargeAmount < reserveHealthPoolMax )
    {
        file.healthPools[attacker].current += rechargeAmount
        file.healthPools[attacker].hasChanged = true
    }
    else
    {
        file.healthPools[attacker].current = reserveHealthPoolMax
        if ( file.healthPools[attacker].hasChanged )
        {
            NSSendPopUpMessageToPlayer(attacker, "Maximum reserve heal points reached. Shoot a friendly titan to heal them!")
            file.healthPools[attacker].hasChanged = false
        }
    }
    UpdateHealthPoolRui( attacker )
    printt("Current health pool for player: '" + attacker.GetPlayerName() + "' - " + file.healthPools[attacker].current)
}

void function Heal_Teammate( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
    int targetCurrentHealth = target.GetHealth()
    int targetMaxHealth = target.GetMaxHealth()
    int cost = WEAPON_BASE_HEAL_COST
    float currentEnergy = file.healthPools[attacker].current
    int restoreAmount = int( (cost / 2) + ( DamageInfo_GetDamage( damageInfo ) * 0.1 ) )

    if ( currentEnergy <= 0 )
    {
        if ( file.healthPools[attacker].hasChanged )
        {
            NSSendPopUpMessageToPlayer(attacker, "Reserve heal points depleted. Attack enemies with your primary weapon to recharge!")
            file.healthPools[attacker].hasChanged = false
        }
    }
    else if ( targetCurrentHealth < targetMaxHealth )
    {
        if ( targetCurrentHealth + restoreAmount > targetMaxHealth )
        {
            restoreAmount = targetMaxHealth - targetCurrentHealth
            cost = restoreAmount * 2
        }
        //printt("Restoring " + restoreAmount + " HP to " + target.GetPlayerName() + " from " + attacker.GetTargetName() + "'s' shared energy pool with cost " + cost)
        target.SetHealth( targetCurrentHealth + restoreAmount )
        file.healthPools[attacker].current = currentEnergy - cost
        file.healthPools[attacker].totalUsed += cost
        file.healthPools[attacker].hasChanged = true
        UpdateHealthPoolRui( attacker )
    }
}

void function CreateHealthPoolRui( entity player )
{
    if ( !IsValid( player ) || !player.IsPlayer() )
        return
    ReserveHealthPool playerPool = file.healthPools[ player ]
    if ( playerPool.msgId != "" )
        return
    string id = UniqueString("reserveHealthPoints")
    playerPool.msgId = id
    string currentPool = string(playerPool.current) + "/" + string(playerPool.max)
    NSCreateStatusMessageOnPlayer( player, "Res. hp", currentPool, id )
}

void function UpdateHealthPoolRui( entity player )
{
    if ( !IsValid( player ) || !player.IsPlayer() )
        return
    ReserveHealthPool playerPool = file.healthPools[ player ]
    string id = playerPool.msgId
    string currentPool = string(playerPool.current) + "/" + string(playerPool.max)
    NSEditStatusMessageOnPlayer( player, "Res. hp", currentPool, id )
    return
}

void function DeleteHealthPoolRui( entity player )
{
    if ( !IsValid( player ) || !player.IsPlayer() )
        return
    ReserveHealthPool playerPool = file.healthPools[ player ]
    string id = playerPool.msgId
    NSDeleteStatusMessageOnPlayer( player, id )
    playerPool.msgId = ""
}

#endif

#if CLIENT
void function Server_UpdateClientHealthPool( float healthPool )
{
    file.currentHealthPool = healthPool
    printt("Client health pool set to ", file.currentHealthPool)
    if ( file.energyBarRui == null )
        return
    RuiSetFloat( file.energyBarRui, "energy", file.currentHealthPool )
}

var function Monarch_CreateHealPoolBar()
{
	Assert( file.energyBarRui == null )

	entity player = GetLocalViewPlayer()
	float energyMax = float( RESERVE_HEALTH_POOL_MAX_VALUE )
	var rui = CreateTitanCockpitRui( $"ui/ion_energy_bar_Fd.rpak" )

	file.energyBarRui = rui

	RuiSetFloat( file.energyBarRui, "energyMax", energyMax )
    RuiSetFloat( file.energyBarRui, "energy", file.currentHealthPool )
	return file.energyBarRui
}

void function Monarch_DestroyHealPoolBar()
{
	TitanCockpitDestroyRui( file.energyBarRui )
	file.energyBarRui = null
}

bool function Monarch_ShouldCreateHealPoolBar()
{
	entity player = GetLocalViewPlayer()
    printt("Checking if need create health pool bar rui")
	if ( !IsAlive( player ) )
		return false

    if ( !player.IsTitan() )
        return false

	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_LEFT )
	if ( !offhandWeapon.HasMod("energy_transfer") )
		return false

	return true
}
#endif