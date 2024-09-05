global function MpWeaponHemlokSmg_Init

global function OnWeaponReload_weapon_volt

const DAMAGE_THRESHHOLD_FOR_BATTERY = 2500

struct {
    table< entity, float > damageSums
} file

void function MpWeaponHemlokSmg_Init()
{
    #if SERVER
    PrecacheParticleSystem( BATTERY_FX_FRIENDLY )
    PrecacheModel( RODEO_BATTERY_MODEL )
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_hemlok_smg, TrackDamageDealt )
    #endif
}

void function OnWeaponReload_weapon_volt( entity weapon, int milestone )
{
    //printt("Attempting volt reload")
    entity owner = weapon.GetWeaponOwner()
    if ( !IsValid( owner ) || !IsAlive( owner ) )
        return
    if ( !owner.IsPlayer() || milestone != 0 ) // Since the milestone can be non-zero if the reload was interrupted, prevent this function from calling more than once if the player interrupts the reload somehow
        return
	#if SERVER
        // Logic to give the player a battery if a total damage threshold is met, then reset the cached damage sum
        if ( !( owner in file.damageSums ) )
            return
        float damageSum = file.damageSums[owner]
        if ( damageSum < DAMAGE_THRESHHOLD_FOR_BATTERY )
            return
        Burnmeter_EmergencyBattery( owner ) // Function used by emergency battery boost to give the player a battery. Located in _rodeo_titan.gnut
        file.damageSums[owner] -= DAMAGE_THRESHHOLD_FOR_BATTERY
    #endif
	return
}

void function TrackDamageDealt( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if ( !IsValid( attacker ) || !IsAlive( attacker ) || !IsValid( target ) )
        return
    if ( !attacker.IsPlayer() )
        return
    if ( !( attacker in file.damageSums ) )
        file.damageSums[attacker] <- 0.0 // Add the player to tracked damage sums if they aren't there already

    float damage = DamageInfo_GetDamage( damageInfo )
    //printt("Volt dealt damage: ", damage)
    file.damageSums[attacker] += damage
}
