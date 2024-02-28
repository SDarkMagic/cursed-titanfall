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
    if ( damageType == DF_DISSOLVE || damageType == DF_ELECTRICAL )
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
    array<string> mods = inflictor.ProjectileGetMods()
    if ( mods.contains( "fd_split_shot_cost" ) )
    {
        float damage = DamageInfo_GetDamage( damageInfo )
        attacker.AddSharedEnergy( int ( damage / 10 ) )
    }
}
#endif