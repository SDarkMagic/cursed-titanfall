global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )

    PlaceFDShop( < 269, -3384, 768 >, < 0, 45, 0 > )
	SetFDGroundSpawn( < -9, -2535, 520 >, < 0, -170, 0 > )
	OverrideFDHarvesterLocation( < -760, -3900, 512>, < 0, 85, 0 > )

	AddFDDropPodSpawn( < -614, -3150, 512 > )
	AddFDDropPodSpawn( < -998, -1289, 512 > )
	AddFDDropPodSpawn( < -668, -1810, 512> )
	// These are all set now for Cursed Titanfall


	AddWaveAnnouncement( "fd_introMedium" )
	AddWaveAnnouncement( "fd_waveTypeTitanReg" )
	AddWaveAnnouncement( "fd_waveTypeCloakDrone" )
	AddWaveAnnouncement( "fd_waveComboArcNuke" )
	AddWaveAnnouncement( "fd_waveComboMultiMix" )

	/*
	 __      __                 _
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|

	*/

    array<WaveSpawnEvent> wave1
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 842, 1250, 558 >, -171, "", 1.0 )
	for ( int i = 0; i < 3; i++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1500, 1200, 560 >, 0.0, "", 0.3, "" )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2000, 1200, 560 >, 0.0, "", 0.2, "" )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1000, 1200, 560 >, 0.0, "", 0.3, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 8 )
	} // 12 grunt droppod spawns in the same area
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )

	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6854, -1170, 516 >, 0.0, "", 0.0, "fd_waveTypeInfantry" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -7018, -1042, 516 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1500, 1200, 560 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2000, 1200, 560 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1000, 1200, 560 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6534, 505, 576 >, 0.0, "westApproach_InfantryTick", 0.1 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6245, 461, 576 >, 0.0, "westApproach_InfantryTick", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6471, 216, 576 >, 0.0, "westApproach_InfantryTick", 0.3 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 16 )

	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -9178, -4089, 580. >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker" , < -9322, -3776, 580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -17, 1044, 565 >, 0.0, "", 0.5, "fd_waveTypeMortarSpectre" )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -1783, 745, 564 >, 0.0, "", 0.4 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )

	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -9542, -3971, 580 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -9443, -4210, 580 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 12 )

	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -7901, -940, 632 >, 0.0, "", 0.6)
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6534, 505, 576 >, 0.0, "", 0.3 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -17, 1044, 565 >, 45, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6245, 461, 576 >, 0.0, "westApproach_InfantryTick", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6471, 216, 576 >, 0.0, "westApproach_InfantryTick", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -1783, 745, 564 >, 0.0, "", 0.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6854, -1170, 516 >, 0.0, "westApproach_InfantryTick", 0.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -7018, -1042, 516 >, 0.0, "", 0.2 )

	WaveSpawnEvents.append( wave1 )

	/*
	 __      __                 ___
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / /
	   \_/\_/ \__,_| \_/ \___| /___|

	*/
	array<WaveSpawnEvent> wave2
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -9161, -4266, 580 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -9280, -4040, 580 >, 0.0, "", 0.1 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -9199, -4814, 572 >, 90, "", 0.2)
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -9371, -3861, 580 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -801, -375, 591 >, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1328, -382, 520 >, 0.0, "", 0.3 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 16 )

	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1343, 59, 520 >, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1393, 438, 558 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -932, 509, 591>, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1064, 146, 520 >, 0.0, "", 0.3 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -4402, -4580, 645 >, -45, "", 0.6 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -3838, -4621, 632 >, 45, "", 1.4 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )

	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -2908, -1900, 668 >, 90, "", 0.2)
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -9706, -3961, 580 >, 30, "", 0.4 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -9379, -4448, 580 >, 30, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -7692, -456, 584 >, -45, "westApproach_InfantryTick", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -7362, 8, 584 >, -45, "westApproach_InfantryTick", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -6691, 334, 576>, -45, "westApproach_InfantryTick", 0.2 )

	WaveSpawn_Announce( wave2, "PreNukeTitan", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -892, 1084, 558 >, -90, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -801, -375, 591 >, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1328, -382, 520 >, 0.0, "", 0.3 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3389, -2257, 716 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3771, -2085, 716 >, 0.0, "", 0.3 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -1116, 426, 558 >, -90, "", 0.8 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 4 )

	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -7857, -1006, 632 >, -40, "", 0.2)
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -6649, -981, 524 >, 0.0, "", 0.0 )
	WaveSpawn_BossTitanSpawn_Random( wave2, [ eFD_Bosses.Kane ], < -7468, -612, 576>, 0.0, "", 4.2 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -3813, -2362, 714 >, 15, "", 0.4 )
	WaveSpawn_TitanSpawn( wave2, "Ronin", < -4091, -4682, 645 >, 45, "", 1.3 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -7271, -277, 632 >, -45, "central", 0.2 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -6486, 397, 576>, -45, "central", 0.1 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -6920, -57, 576 >, -45, "central", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3389, -2257, 716 >, -90, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3771, -2085, 716 >, -90, "", 0.2 )

	WaveSpawnEvents.append( wave2 )

	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/

	*/
	array<WaveSpawnEvent> wave3

	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -925, -567, 568 >, -90, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -3782, -4565, 632 >, -45, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -4202, -4732, 645 >, -45, "", 0.2 )
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -3126, -2052, 691 >, -0.0, "", 1.6 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -2785, -1888, 652>, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -2991, -1875, 676>, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -3698, -2540, 716 >, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -4047, -2467, 716 >, 0.0, "", 0.3 ) // 26 entities
	WaveSpawn_TitanSpawn( wave3, "Ronin", < -3753, -4501, 645 >, 45, "", 0.4 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -705, 1235, 558 >, -90, "", 0.1 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -1156, 1119, 558 >, -90, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -1785, 1351, 1116 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -345, 1846, 1616 >, 0.0, "", 0.2 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 16 )

	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -617, -398, 584 >, -90, "", 0.3 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -9456, -3842, 580 >, 30, "", 0.2 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -1321, -483, 520 >, -90, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -9456, -3842, 1687 >, 0.0, "", 0.1 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -9123, -4327, 580 >, 30, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -9235, -4727, 1243 >, 0.0, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -4650, -4357, 644 >, 135, "", 0.6, "fd_waveTypeReaperTicks" )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -4319, -4679, 644 >, 135, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -841, 653, 591>, -90, "", 0.3, "fd_nagKillTitanEMP" )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < -4487, -4554, 659 >, 45, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < -2124, 664, 563>, -90, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -2277, 1456, 984 >, 0.0, "", 0.4 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 10 )

	WaveSpawn_SmokeWall( wave3, < -1583, -931, 519 >, 0.7 )
	WaveSpawn_SmokeWall( wave3, < -791, -653, 568>, 2.0 )
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < -4487, -4554, 659 >, 45, "", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -5351, -2445, 692 >, 0.0, "", 0.1 )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -4433, -2683, 718 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 345, 1239, 558 >, 180, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < 573, 1320.41, 1000 >, 0.0, "", 0.1 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -7863, -990, 632 >, -45, "central", 0.2 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -7262, -281, 632 >, -45, "westApproach", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -7863, -990, 1132 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone",  < -7262, -281, 1132 >, 0.0, "", 0.1 )
	WaveSpawn_EliteArcSpawn( wave3, < -7277, -799, 580 >, -45, "central", 0.6 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 26 )
	WaveSpawn_BossTitanSpawn_Random( wave3, [ eFD_Bosses.Ash ], < -941, 668, 568 >, -90, "", 0.2 )

	WaveSpawnEvents.append( wave3 )

	/*
	 __      __                 _ _
	 \ \    / /__ _ __ __ ___  | | |
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_|

	*/
	array<WaveSpawnEvent> wave4
	/*
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -856, -2884, 512 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -1111, 647, 558 >, -90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -604, -3121, 512 >, 180, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -826, 462, 590 >, -90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -599, -2751, 512 >, 180, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -633, 1101, 558 >, -90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -896, -3245, 512 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -426, 624, 590 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -1520, 474, 558 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -895, -2610, 512 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )

	WaveSpawn_TitanSpawn( wave4, "Northstar", < -9459, -4402, 582 >, 45, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < 952, 1284, 558 >, 180, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2343, -2073, 643 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -2505, -1926, 643 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -2505, -2192, 643 >, 180, "", 3.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2390, -44, 728 >, 0, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -599, -2751, 512 >, 180, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -604, -3121, 512 >, 180, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2196, -44, 728 >, 0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2196, -44, 728 >, 0, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -633, 1101, 558 >, -90, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -4650, -4357, 644 >, 135, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -4319, -4679, 644 >, 135, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -415, -2885, 521 >, 180, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -485, -3730, 520 >, 180, "", 0.6 )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )

	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -924, -3300, 512 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -4299, -4706, 644 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -4634, -4379, 644 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -9489, -4627, 574 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -9663, -4165, 581 >, 45, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -9222, -4877, 573 >, 45, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -8976, -4400, 585 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -9543, -3749, 580 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -9166, -5069, 573 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -1959, 993, 558 >, -45, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -1756, 1230, 559 >, -45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -2196, 803, 558 >, -45, "", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )

	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -611, -2786, 512 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -611, -3086, 512 >, 180, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -1066, 1232, 558 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -771, 1232, 558 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2453, 389, 558 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2453, 615, 558 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2377, -1932, 643 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2377, -2208, 643 >, 180, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2551, 375, 559 >, 0, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2292, 436, 558 >, 0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2390, -44, 728 >, 0, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -871, -2910, 512 >, 180, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -431, -3372, 519 >, 180, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -856, -3282, 512 >, 180, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -440, -2541, 519 >, 180, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )

	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2377, -1932, 643 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2377, -2208, 643 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2453, 389, 558 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2453, 615, 558 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -9489, -4627, 574 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -9663, -4165, 581 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -9222, -4877, 573 >, 45, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -8976, -4400, 585 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -9543, -3749, 580 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -9166, -5069, 573 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -4299, -4706, 644 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -4634, -4379, 644 >, 0.0, "", 2.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )

	WaveSpawn_TitanSpawn( wave4, "Ion", < -2453, 389, 558 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -2453, 615, 558 >, 0, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -2377, -1932, 643 >, 180, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -2377, -2208, 643 >, 180, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -611, -2786, 512 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -611, -3086, 512 >, 180, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -1066, 1232, 558 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -771, 1232, 558 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1744, 537, 558 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -2004, 469, 558 >, 0.0, "", 1.0 )
	*/
	//WaveSpawnEvents.append( wave4 )

	/*
	 __      __                 ___
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/

	*/
	array<WaveSpawnEvent> wave5
	/*
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1192, 255, 520 >, -90, "roadTunnel", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1517, 468, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -841, 489, 591 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1108, 648, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1941, 752, 563 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1068, 1248, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -402, 750, 593 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1751, 1267, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -253, 1349, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < 250, 1307, 558 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < 741, 1321, 558 >, -90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -2418, -40, 728 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )

	WaveSpawn_TitanSpawn( wave5, "Legion", < -1192, 255, 520 >, -90, "roadTunnel", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1517, 468, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -841, 489, 591 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1108, 648, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1941, 752, 563 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1068, 1248, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -402, 750, 593 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1751, 1267, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -253, 1349, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 250, 1307, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 741, 1321, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -493, -2669, 516 >, 180, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )

	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1192, 255, 520 >, -90, "roadTunnel", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1517, 468, 558 >, -90, "roadTunnel", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -841, 489, 591 >, -90, "roadTunnel", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1108, 648, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1941, 752, 563 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1068, 1248, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -402, 750, 593 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1751, 1267, 559 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -253, 1349, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 250, 1307, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 741, 1321, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "roadTunnel", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -499, -3707, 520 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "roadTunnel", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )

	WaveSpawn_TitanSpawn( wave5, "Northstar", < -4315, -2855, 715 >, 90, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < -4760, -2874, 716 >, 90, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -9489, -4627, 574 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -9663, -4165, 581 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -9222, -4877, 573 >, 45, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -856, -2884, 512 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1111, 647, 558 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2515, 501, 558 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "PodGrunt", < -4299, -4706, 644 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave5, "PodGrunt", < -4634, -4379, 644 >, 0.0, "", 2.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )

	WaveSpawn_TitanSpawn( wave5, "Legion", < -1192, 255, 520 >, -90, "ringsideMain", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1517, 468, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -841, 489, 591 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1108, 648, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1941, 752, 563 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1068, 1248, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -402, 750, 593 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1751, 1267, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -253, 1349, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 250, 1307, 558 >, -90, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 741, 1321, 558 >, -90, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -2418, -40, 728 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "ringsideMain", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "ringsideMain", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )

	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1192, 255, 520 >, -90, "ringsideMain", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1517, 468, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -841, 489, 591 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1108, 648, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1941, 752, 563 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1068, 1248, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -402, 750, 593 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1751, 1267, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -253, 1349, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 250, 1307, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 741, 1321, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -493, -2669, 516 >, 180, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "ringsideMain", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "ringsideMain", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )

	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1192, 255, 520 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1517, 468, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -841, 489, 591 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1108, 648, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1941, 752, 563 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1068, 1248, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -402, 750, 593 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1751, 1267, 559 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -253, 1349, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 250, 1307, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 741, 1321, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -634, 1035, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1215, 1125, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1740, 1282, 558 >, -90, "ringsideMain", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -499, -3707, 520 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1675, 226, 558 >, 0.0, "ringsideMain", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -798, -348, 590 >, 0.0, "ringsideMain" )
	*/
	// Wave 5 Blisk Spawn
	//WaveSpawnEvents.append( wave5 )
}

void function RegisterCustomFDContent()
{
	array<entity> dropshipSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_dropship_start" )
	foreach ( entity dropshipSpawn in dropshipSpawns )
		dropshipSpawn.Destroy()

	array<entity> triggers = GetEntArrayByClass_Expensive( "trigger_hurt" )
	foreach ( entity trigger in triggers )
	{
		if( trigger.kv.damageSourceName == "burn" )
			trigger.kv.triggerFilterNpc = "none"
	}

	// TODO: Add logic for arc core here to allow a oncer per match 15s freeze of all enemies

	entity Prowler1 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -3148, -331, 516 >, < 0, 0, 0 > )
	entity Prowler2 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -3732, 474, 545 >, < 0, 0, 0 > )
	entity Prowler3 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -3797, -897, 597 >, < 0, 0, 0 > )
	entity Prowler4 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -3266, 239, 600 >, < 0, 0, 0 > )
	DispatchSpawn( Prowler1 )
	DispatchSpawn( Prowler2 )
	DispatchSpawn( Prowler3 )
	DispatchSpawn( Prowler4 )

	AddFDCustomShipStart( < -1960, 372, 1400 >, < 0, -90, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < -992, 531, 1400 >, < 0, -90, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < -7667, -651, 1946 >, < 0, -15, 0 >, TEAM_IMC )
	AddFDCustomShipStart( < -6585, 283, 1946 >, < 0, -135, 0 >, TEAM_IMC )

	AddFDCustomTitanStart( < -7056, 322, 696 >, < 0, -45, 0 > )
	AddFDCustomTitanStart( < -7874, -1013, 632 >, < 0, -20, 0 > )

	//SpawnFDHeavyTurret( < -6658, -75, 696 >, < 0, 135, 0 >, < -6778, -132, 580 >, < 0, 45, 0 > )

	AddStationaryAIPosition( < -673, 111, 584 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -1535, 761, 558 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -9576, -3812, 580 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -1787, -2682, 644 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -5740, -3608, 600 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -7683, -673, 576 >, eStationaryAIPositionTypes.SNIPER_TITAN )

	AddStationaryAIPosition( < -6405, -4362, 564 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -4182, -474, 662 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < 843, 1250, 558 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -3553, -4793, 773 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -4771, -4749, 773 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -2941, -1539, 647 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -7601, -1639, 588 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -3713, 560, 548 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )

	AddStationaryAIPosition( < -1886, -88, 728 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -1728, 997, 558 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -9459, -5064, 572 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -8704, -4788, 585 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -7055, -2105, 588 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -2551, 490, 558 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )

	// On top of boxes
	AddStationaryAIPosition( < -1239, 842, 752 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -320, 1049, 763 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )


	AddStationaryAIPosition( < -9360, -4420, 580 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -9177, -4900, 572 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -7632, -280, 588 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -7175, 70, 584 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -7863, -1026, 632 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -1932, 752, 563 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -765, 1185, 558 >, eStationaryAIPositionTypes.MORTAR_TITAN )

	routes[ "northDirect" ] <- []
	routes[ "northDirect" ].append( < -670, 37, 584 > )
	routes[ "northDirect" ].append( < -450, -2142, 523 > )
	routes[ "northDirect" ].append( < -596, -3616, 512> )

	routes[ "westInterior" ] <- []
	routes[ "westInterior" ].append( < -5855, 557, 580 > )
	routes[ "westInterior" ].append( < -4542, -158, 546 > )
	routes[ "westInterior" ].append( < -3873, -820, 578 > )
	// From here on is shared with central route
	routes[ "westInterior" ].append( < -3766, -2296, 714 > )
	routes[ "westInterior" ].append( < -2729, -2096, 644 > )
	routes[ "westInterior" ].append( < -2268, -2739, 644 > )
	routes[ "westInterior" ].append( < -980, -2936, 514 > )
	routes[ "westInterior" ].append( < -926, -3557, 512 > )

	routes[ "westApproach" ] <- []
	routes[ "westApproach" ].append( < -5855, 557, 580 > )
	routes[ "westApproach" ].append( < -4542, -158, 546 > )
	routes[ "westApproach" ].append( < -3849, -321, 578 > )
	routes[ "westApproach" ].append( < -2763, -363, 512 > )
	routes[ "westApproach" ].append( < -1804, -907, 512 > )
	routes[ "westApproach" ].append( < -904, -1251, 512 > )
	routes[ "westApproach" ].append( < -926, -3557, 512 > )

	routes[ "westApproach_InfantryTick" ] <- []
	routes[ "westApproach_InfantryTick" ].append( < -5855, 557, 580 > )
	routes[ "westApproach_InfantryTick" ].append( < -4542, -158, 546 > )
	// Infantry swap out this bit
	routes[ "westApproach_InfantryTick" ].append( < -4407, 166, 562 > )
	routes[ "westApproach_InfantryTick" ].append( < -3943, 76, 527 > )
	routes[ "westApproach_InfantryTick" ].append( < -3509, 116, 514 > )
	routes[ "westApproach_InfantryTick" ].append( < -3322, 109, 493 > )
	routes[ "westApproach_InfantryTick" ].append( < -2857, -322, 515 > )
	// ^ Navigate through tunnels here
	routes[ "westApproach_InfantryTick" ].append( < -1804, -907, 512 > )
	routes[ "westApproach_InfantryTick" ].append( < -1337, -1739, 520 > )
	routes[ "westApproach_InfantryTick" ].append( < -877, -2226, 512 > )
	routes[ "westApproach_InfantryTick" ].append( < -926, -3557, 512 > )

	routes[ "eastDirect" ] <- []
	routes[ "eastDirect" ].append( < -8954, -3859, 580 > )
	routes[ "eastDirect" ].append( < -7690, -4046, 582 > )
	routes[ "eastDirect" ].append( < -7018, -3876, 623 > )
	routes[ "eastDirect" ].append( < -5007, -3970, 641 > )
	routes[ "eastDirect" ].append( < -4190, -4647, 645 > )
	routes[ "eastDirect" ].append( < -2621, -3534, 644 > )
	routes[ "eastDirect" ].append( < -2018, -3433, 644 > )
	routes[ "eastDirect" ].append( < -1653, -2891, 644 > )
	routes[ "eastDirect" ].append( < -980, -2936, 514 > )
	routes[ "eastDirect" ].append( < -926, -3557, 512 > )

	routes[ "central" ] <- []
	routes[ "central" ].append( < -7334, -693, 576 > )
	routes[ "central" ].append( < -6349, -1296, 516> )
	routes[ "central" ].append( < -5066, -2626, 716 > )
	routes[ "central" ].append( < -3766, -2296, 714 > )
	routes[ "central" ].append( < -2729, -2096, 644 > )
	routes[ "central" ].append( < -2268, -2739, 644 > )
	routes[ "central" ].append( < -980, -2936, 514 > )
	routes[ "central" ].append( < -926, -3557, 512 > )
}