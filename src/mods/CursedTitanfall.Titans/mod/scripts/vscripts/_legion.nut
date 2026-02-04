global function Init_Legion

const LEGION_SPINUP_STIM_SEVERITY = 2.75

void function Init_Legion()
{
    #if SERVER
    AddCallback_OnPrimaryAttack_titanability_power_shot( ReloadPrimary_On_PowerShot )
    AddCallback_OnStartZoomIn_titanweapon_predator_cannon( StartZoomIn_titanweapon_predator_cannon )
    AddCallback_OnStartZoomOut_titanweapon_predator_cannon( StartZoomOut_titanweapon_predator_cannon )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_predator_cannon, RefundAmmoOnCrit )
    AddCallback_OnPilotBecomesTitan( Apply_LegionAmmoAbsorber )
    AddCallback_OnTitanBecomesPilot( Cleanup_LegionAmmoAbsorber )
    #endif
}

#if SERVER
void function StartZoomIn_titanweapon_predator_cannon( entity weapon )
{
    entity owner = weapon.GetOwner()
    if( !IsValid( owner ) || !IsAlive( owner ) )
        return
    if( !weapon.HasMod( "pas_legion_spinup" ) )
        return

    EndlessStimBegin( owner, LEGION_SPINUP_STIM_SEVERITY )
}

void function StartZoomOut_titanweapon_predator_cannon( entity weapon )
{
    entity owner = weapon.GetOwner()
    if( !IsValid( owner ) || !IsAlive( owner ) )
        return
    if( !weapon.HasMod( "pas_legion_spinup" ) )
        return

    EndlessStimEnd( owner )
}

void function ReloadPrimary_On_PowerShot( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity owner = weapon.GetOwner()
    if ( !IsValid( owner ) )
        return
    if ( !owner.IsPlayer() )
        return

    array<entity> weapons = GetPrimaryWeapons( owner )
	entity primaryWeapon = weapons[0]
    if( !weapon.HasMod( "pas_legion_chargeshot" ) )
        return
    primaryWeapon.SetWeaponPrimaryClipCount( primaryWeapon.GetWeaponPrimaryClipCountMax() )
}

void function RefundAmmoOnCrit( entity target, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    if ( !IsValid( weapon ) )
        return
    entity owner = weapon.GetOwner()
    entity soul = owner.GetTitanSoul()
    if ( !IsValid( owner ) || !IsValid( soul) )
        return
    if ( !IsAlive( owner) )
        return

    if( !SoulHasPassive( soul, ePassives.PAS_LEGION_SMARTCORE ) )
        return
	float damage = DamageInfo_GetDamage( damageInfo )
	bool isCrit = IsCriticalHit( DamageInfo_GetAttacker( damageInfo ), target, DamageInfo_GetHitBox( damageInfo ), damage, DamageInfo_GetDamageType( damageInfo ) )
	if( !IsValid( weapon ) || !isCrit )
		return
    if ( !weapon.HasMod( "LongRangeAmmo" ) )
        return
	int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
	int currentAmmo = weapon.GetWeaponPrimaryClipCount()
	int newAmmoCount = currentAmmo + weapon.GetAmmoPerShot()
	if ( newAmmoCount >= maxAmmo )
		weapon.SetWeaponPrimaryClipCount( maxAmmo )
	else
		weapon.SetWeaponPrimaryClipCount( newAmmoCount )
}

void function Apply_LegionAmmoAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) )
        return
    if ( GetTitanCharacterName( titan ) == "legion" )
        AddEntityCallback_OnDamaged( player, PlayerTitan_TookDamage )
}

void function Cleanup_LegionAmmoAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) || !IsAlive( titan ) )
        return
    if ( GetTitanCharacterName( titan ) == "legion" )
        RemoveEntityCallback_OnDamaged( player, PlayerTitan_TookDamage )
}

void function PlayerTitan_TookDamage( entity titan, var damageInfo )
{
    entity soul = titan.GetTitanSoul()
    float damage = DamageInfo_GetDamage( damageInfo )
    if ( !IsValid( soul ) || !IsValid( titan ) || !titan.IsPlayer() || damage <= 0 )
        return
    int divisor = 100
    if ( titan.GetShieldHealth() > 0 )
        divisor = 10

    int ammoToAdd = int( damage / divisor )
    DamageInfo_ScaleDamage( damageInfo, 0.6 )
    array<entity> weapons = titan.GetMainWeapons()
    if ( weapons.len() > 0 )
    {
        entity weapon = weapons[0]
        int currentAmmo = weapon.GetWeaponPrimaryClipCount()
        int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
        if( currentAmmo + ammoToAdd < maxAmmo )
            weapon.SetWeaponPrimaryClipCount( currentAmmo + ammoToAdd )
        else
            weapon.SetWeaponPrimaryClipCount( maxAmmo )
        //printt( weapon.GetWeaponPrimaryAmmoCount() )
    }
}
#endif