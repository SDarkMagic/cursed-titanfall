global function OnWeaponPrimaryAttack_weapon_dmr_laser

#if SERVER
global function OnWeaponNPCPrimaryAttack_weapon_dmr_laser
#endif

var function OnWeaponPrimaryAttack_weapon_dmr_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
    return 1
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_weapon_dmr_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    return OnWeaponPrimaryAttack_weapon_dmr_laser( weapon, attackParams )
}
#endif