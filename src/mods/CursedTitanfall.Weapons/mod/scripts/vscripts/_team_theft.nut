global function LeechGeneric

struct LeechFuncInfo
{
	string classname
	void functionref(entity,entity) DoLeech
	void functionref(entity,entity) LeechStart
	void functionref(entity,entity) LeechAbort
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
void function LeechGeneric( entity self, entity leecher )
{
	thread LeechGenericThread( self, leecher )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Run after the npc is successfully leeched
// HACK: Should make this used by all leeched ents to avoid copy/pasted duplication. Will switch Spectre over to use this soon
void function LeechGenericThread( entity self, entity leecher )
{
	Assert( IsValid( self ) )
	self.EndSignal( "OnDestroy" )
	self.EndSignal( "OnDeath" )
	self.EndSignal( "OnLeeched" )

	Assert( leecher.IsPlayer() )
	leecher.EndSignal( "OnDestroy" )

	string leechSound
	float timerCredit

	//--------------------------------------------
	// Handle class-specific stuff
	//---------------------------------------------
	switch ( self.GetClassName() )
	{
		case "npc_spectre":
			leechSound = MARVIN_EMOTE_SOUND_HAPPY
			AddPlayerScore( leecher, "LeechSpectre" )
			timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
			if ( PlayerHasServerFlag( leecher, SFLAG_HUNTER_SPECTRE ) )
				timerCredit *= 2.5
			break
		case "npc_super_spectre":
			leechSound = MARVIN_EMOTE_SOUND_HAPPY
			AddPlayerScore( leecher, "LeechSuperSpectre" )
			timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
			break
		case "npc_drone":
			leechSound = MARVIN_EMOTE_SOUND_HAPPY
			AddPlayerScore( leecher, "LeechDrone" )
			timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
			break
		case "npc_gunship":
			leechSound = MARVIN_EMOTE_SOUND_HAPPY
			timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
			break
		default:
			Assert( 0, "Unhandled hacked entity: " + self.GetClassName() )
	}

	EmitSoundOnEntity( self, leechSound )
	DecrementBuildTimer( leecher, timerCredit )

	// Multiplayer the leeched NPCs still follow the player, but in SP we don't want them to
	if ( IsMultiplayer() )
		NPCFollowsPlayer( self, leecher )

	//--------------------------------------------
	// Any leech custom callback funcs?
	//---------------------------------------------
	foreach ( callbackFunc in svGlobal.onLeechedCustomCallbackFunc )
	{
		callbackFunc( self, leecher )
	}

}

/////////////////////////////////////////////////////////////////////////////////////
void function LeechStartGeneric( entity self, entity leecher )
{
	string leechStartSound

	switch( self.GetClassName() )
	{
		case "npc_spectre":
			leechStartSound = MARVIN_EMOTE_SOUND_PAIN
			break
		case "npc_super_spectre":
			leechStartSound = MARVIN_EMOTE_SOUND_PAIN
			break
		case "npc_drone":
			leechStartSound = MARVIN_EMOTE_SOUND_PAIN
			break
		case "npc_gunship":
			leechStartSound = MARVIN_EMOTE_SOUND_PAIN
			break
	}
	Assert( leechStartSound != "", "Couldn't find leechStartSound for: " + self )

	EmitSoundOnEntity( self, leechStartSound )
}
/////////////////////////////////////////////////////////////////////////////////////
void function LeechAbortGeneric( entity self, entity leecher )
{
	string leechAbortSound

	switch( self.GetClassName() )
	{
		case "npc_spectre":
			leechAbortSound = MARVIN_EMOTE_SOUND_SAD
			break
		case "npc_super_spectre":
			leechAbortSound = MARVIN_EMOTE_SOUND_SAD
			break
		case "npc_drone":
			leechAbortSound = MARVIN_EMOTE_SOUND_SAD
			break
		case "npc_gunship":
			leechAbortSound = MARVIN_EMOTE_SOUND_SAD
			break
	}
	Assert( leechAbortSound != "", "Couldn't find leechAbortSound for: " + self )

	EmitSoundOnEntity( self, leechAbortSound )

}

// --- END CLASS SPECIFIC LEECH FUNCTIONS ---