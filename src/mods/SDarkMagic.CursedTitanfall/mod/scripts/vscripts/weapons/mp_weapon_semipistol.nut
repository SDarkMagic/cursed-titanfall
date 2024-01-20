
global function OnWeaponPrimaryAttack_weapon_semipistol

var function OnWeaponPrimaryAttack_weapon_semipistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
    int team = player.GetTeam()
    array<entity> enemies = GetPlayerArrayOfEnemies(team)
	#if SERVER
		if (RandomIntRange(0, 4) == 3)
			foreach (entity enemy in enemies)
            {
                enemy.TakeDamage( enemy.GetHealth(), player, null, { weapon = weapon } )
            }
	#endif
	return //FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

