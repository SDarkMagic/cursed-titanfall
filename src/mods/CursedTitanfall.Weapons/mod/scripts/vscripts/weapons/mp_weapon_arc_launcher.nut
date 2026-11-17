global function OnWeaponPrimaryAttack_weapon_arc_launcher
const ARC_LAUNCHER_ZAP_DAMAGE = 350
const float PULL_RANGE = 250.0
const float PULL_STRENGTH_MAX = 500.0

var function OnWeaponPrimaryAttack_weapon_arc_launcher( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( weaponOwner.IsPlayer() )
	{
		float zoomFrac = weaponOwner.GetZoomFrac()
		if ( zoomFrac < 1 )
			return 0
	}

	#if SERVER
		if ( weaponOwner.IsPlayer() )
		{
			vector angles = VectorToAngles( weaponOwner.GetViewVector() )
			vector up = AnglesToUp( angles )

			if ( weaponOwner.GetTitanSoulBeingRodeoed() != null )
				attackParams.pos = attackParams.pos + up * 20
		}
	#endif

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	float speed = 450.0

	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir

	entity arcBall = FireArcBall( weapon, attackPos, attackDir, shouldPredict, ARC_LAUNCHER_ZAP_DAMAGE )
	#if SERVER
	//thread ProjectileEMPFieldThinkConstant( arcBall )
	GravFieldParams params
	params.pull_range = PULL_RANGE
	params.pull_strength_max = PULL_STRENGTH_MAX
	array<string> mods = weapon.GetMods()
	if ( mods.find( "pro_screen" ) >= 0 )
		params.pull_owner = true

	thread CreateGravFieldOnEnt( arcBall, params )
	#endif
	weapon.EmitWeaponSound_1p3p( "Weapon_ArcLauncher_Fire_1P", "Weapon_ArcLauncher_Fire_3P" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return 1
}