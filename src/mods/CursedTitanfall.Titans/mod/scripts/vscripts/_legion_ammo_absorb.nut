global function Init_LegionAmmoAbsorber

void function Init_LegionAmmoAbsorber()
{
    #if SERVER
    AddCallback_OnPilotBecomesTitan( Apply_LegionAmmoAbsorber )
    AddCallback_OnTitanBecomesPilot( Cleanup_LegionAmmoAbsorber )
    #endif
}

#if SERVER
void function Apply_LegionAmmoAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) )
        return
    if ( GetTitanCharacterName( titan ) == "legion" )
        AddEntityCallback_OnDamaged( player, PlayerTitan_TookDamage )
}

void function Cleanup_LegionAmmoAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) )
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
    int ammoToAdd = int( damage / 100 )
    DamageInfo_SetDamage( damageInfo, damage / 1.6 )
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