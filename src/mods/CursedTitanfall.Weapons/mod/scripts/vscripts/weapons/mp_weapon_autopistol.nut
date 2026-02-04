global function OnWeaponActivate_weapon_autopistol
global function OnWeaponDeactivate_weapon_autopistol

const float STIM_SEVERITY = 0.3


void function MpWeaponAutopistol_Init()
{
    // Use this later to return bullets to mag and add stacking dmg buff when landing shots
}

void function OnWeaponActivate_weapon_autopistol( entity weapon )
{
#if SERVER
    entity owner = weapon.GetWeaponOwner()
    if ( !IsValid(owner) || !IsAlive(owner) )
        return
    if ( !owner.IsPlayer() )
        return
    EndlessStimBegin( owner, STIM_SEVERITY )
#endif
}

void function OnWeaponDeactivate_weapon_autopistol( entity weapon )
{
#if SERVER
    entity owner = weapon.GetWeaponOwner()
    if ( !IsValid(owner) || !IsAlive(owner) )
        return
    if ( !owner.IsPlayer() )
        return
    EndlessStimEnd( owner )
#endif
}