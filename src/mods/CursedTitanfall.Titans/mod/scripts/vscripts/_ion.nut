global function Init_Ion

void function Init_Ion()
{
    #if SERVER
    AddCallback_OnTitanGetsNewTitanLoadout( ApplyPassiveOnLoadoutUpdate )
    AddCallback_OnPilotBecomesTitan( Apply_IonEnergyAbsorber )
    AddCallback_OnTitanBecomesPilot( Cleanup_IonEnergyAbsorber )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_particle_accelerator, RechargeEnergy_OnHit )
    #endif
}

#if SERVER
void function ApplyPassiveOnLoadoutUpdate( entity titan, TitanLoadoutDef loadout )
{
    entity soul = titan.GetTitanSoul()
    entity owner = titan.GetOwner()
	if ( loadout.titanClass != "ion" || !IsValid( soul ) || !titan.IsTitan() )
		return
    AddEntityCallback_OnDamaged( titan, FilterEnergyDamage )
}

void function Apply_IonEnergyAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) )
        return
    if ( GetTitanCharacterName( titan ) == "ion" )
        AddEntityCallback_OnDamaged( player, FilterEnergyDamage )
}

void function Cleanup_IonEnergyAbsorber( entity player, entity titan )
{
    if ( !IsValid(titan) || !IsAlive( titan ) )
        return
    if ( GetTitanCharacterName( titan ) == "ion" )
        RemoveEntityCallback_OnDamaged( player, FilterEnergyDamage )
}

void function FilterEnergyDamage( entity titan, var damageInfo )
{
    int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
    int damageFlags = DamageInfo_GetDamageFlags( damageInfo )
    int damageType = DamageInfo_GetDamageType( damageInfo )
    bool absorbDamage = false
    switch ( damageSourceId )
    {
        case eDamageSourceId.mp_titanweapon_particle_accelerator:
        case eDamageSourceId.mp_titanweapon_laser_lite:
        case eDamageSourceId.mp_titancore_laser_cannon:
        case eDamageSourceId.titanEmpField:
        case eDamageSourceId.mp_titanweapon_arc_wave:
        //case eDamageSourceId.mp_titanability_electric_smoke:
        case eDamageSourceId.mp_weapon_arc_launcher:
        case eDamageSourceId.mp_turretweapon_plasma:
        case eDamageSourceId.mp_weapon_arc_trap:
        case eDamageSourceId.mp_weapon_defender:
        case eDamageSourceId.mp_weapon_dronebeam:
        case eDamageSourceId.mp_weapon_droneplasma:
        case eDamageSourceId.mp_weapon_esaw:
        case eDamageSourceId.mp_weapon_epg:
        case eDamageSourceId.mp_weapon_grenade_electric_smoke:
        case eDamageSourceId.mp_weapon_grenade_emp:
        case eDamageSourceId.mp_weapon_lstar:
        case eDamageSourceId.mp_weapon_super_spectre:
        case eDamageSourceId.mp_weapon_turretplasma:
        case eDamageSourceId.mp_weapon_turretplasma_mega:
        //case eDamageSourceId.mp_weapon_turretlaser_mega:
        case eDamageSourceId.mp_weapon_pulse_lmg:
            absorbDamage = true
        default:
            return
    }
    if ( absorbDamage )
    {
        float damage = DamageInfo_GetDamage( damageInfo )
        titan.AddSharedEnergy( int( damage / 10 ) )
        DamageInfo_ScaleDamage( damageInfo, 0.4 )
    }

}

void function RechargeEnergy_OnHit( entity target, var damageInfo )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return
	if ( !inflictor.IsProjectile() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) || attacker.IsProjectile() ) //Is projectile check is necessary for when the original attacker is no longer valid it becomes the projectile.
		return

	if ( attacker.GetSharedEnergyTotal() <= 0 )
		return

	if ( attacker.GetTeam() == target.GetTeam() )
		return

	entity soul = attacker.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
    float damage = DamageInfo_GetDamage( damageInfo )
    attacker.AddSharedEnergy( int ( damage / 20 ) )
}
#endif