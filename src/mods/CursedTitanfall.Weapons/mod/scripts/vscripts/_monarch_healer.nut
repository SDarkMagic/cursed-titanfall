global function Init_Monarch_Healing_Shots

const RESERVE_HEALTH_POOL_MAX_VALUE = 4000
const WEAPON_HEAL_COST = 40

#if SERVER
struct ReserveHealthPool {
    float current
    int totalUsed
}

struct {
    table< entity, ReserveHealthPool > healthPools
} file
#endif
#if CLIENT
struct {
    var energyBarRui = null
} file
#endif

void function Init_Monarch_Healing_Shots( )
{
    #if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_xo16_vanguard, Energy_Transfer_Primary_Weapon_Callback )
    AddCallback_OnClientConnected( Healer_InitPlayer )
    #endif
}

void function Energy_Transfer_Primary_Weapon_Callback( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity offhandWeapon = attacker.GetOffhandWeapon( OFFHAND_LEFT )
    if ( !attacker.IsPlayer() || !offhandWeapon.HasMod("energy_transfer") )
        return
    #if SERVER
    if ( attacker.GetTeam() == target.GetTeam() && target.IsTitan())
        Heal_Teammate( target, damageInfo )
    else if (attacker.GetTeam() == target.GetTeam())
        return
    else
        Charge_Meter( damageInfo )
    #endif
}

#if SERVER

void function Healer_InitPlayer( entity player )
{
    ReserveHealthPool healthPool
    healthPool.current = 0
    healthPool.totalUsed = 0
    file.healthPools[player] <- healthPool
}

void function Charge_Meter( var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    float rechargeAmount = DamageInfo_GetDamage( damageInfo ) / 2
    if ( file.healthPools[attacker].current + rechargeAmount < RESERVE_HEALTH_POOL_MAX_VALUE )
        file.healthPools[attacker].current += rechargeAmount
    else
        file.healthPools[attacker].current = RESERVE_HEALTH_POOL_MAX_VALUE
    printt("Current health pool: " + file.healthPools[attacker].current)
}

void function Heal_Teammate( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
    int targetCurrentHealth = target.GetHealth()
    int targetMaxHealth = target.GetMaxHealth()
    int cost = WEAPON_HEAL_COST
    float currentEnergy = file.healthPools[attacker].current
    int restoreAmount = cost / 2
    if ( currentEnergy <= 0)
        return

    if ( targetCurrentHealth < targetMaxHealth )
    {
        if ( targetCurrentHealth + restoreAmount > targetMaxHealth )
        {
            restoreAmount = targetMaxHealth - targetCurrentHealth
            cost = restoreAmount * 2
        }
        printt("Restoring " + restoreAmount + " HP to target from shared energy pool with cost " + cost)
        target.SetHealth( targetCurrentHealth + restoreAmount )
        file.healthPools[attacker].current = currentEnergy - cost
        file.healthPools[attacker].totalUsed += cost
    }
}
#endif
