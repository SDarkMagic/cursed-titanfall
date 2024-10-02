global function FragIgnite_RandomEvent_Callback
global function AddRandomEventCallback_FragGrenade
global function DEV_TestFragCallbacks

struct {
    array< void functionref( entity ) > randomEvents
} file

void function AddRandomEventCallback_FragGrenade( void functionref( entity ) callback )
{
    Assert( !file.randomEvents.contains( callback ), "Already added " + string( callbackFunc ) + " with AddRandomEventCallback_FragGrenade"  )
	file.randomEvents.append( callback )
}

void function FragIgnite_RandomEvent_Callback( entity weapon )
{
    entity owner = weapon.GetOwner()
    if( !owner.IsPlayer() )
        return
    int index = RandomInt( file.randomEvents.len() )
    printt( "Calling random frag callback for ", owner, "; ", string( file.randomEvents[index] ), weapon )
    file.randomEvents[index]( weapon )
}

void function DEV_TestFragCallbacks( )
{
    #if SERVER
    entity basePlayer = GetPlayerArray()[0]
    vector origin = basePlayer.GetOrigin()
    entity testDummy = CreateEntity( "npc_marvin" )
    testDummy.SetTitle( "Test Dummy" )
    testDummy.SetOwner( basePlayer )
    SetSpawnOption_Weapon( testDummy, "mp_weapon_softball" )
    testDummy.SetInvulnerable()
    testDummy.SetOrigin( origin )
    SetTeam( testDummy, basePlayer.GetTeam() )
    DispatchSpawn( testDummy )
    entity weapon = testDummy.GetActiveWeapon()
    weapon.SetOwner( basePlayer )
    vector angularVelocity = Vector( RandomFloatRange( -1200, 1200 ), 100, 0 )
	int damageType = DF_RAGDOLL
	entity nade = weapon.FireWeaponGrenade( origin, basePlayer.GetViewVector(), angularVelocity, 0.0 , damageType, damageType, false, true, false )
    foreach( callback in file.randomEvents )
    {
        printt( "Testing function ", string( callback ) )
        callback( nade )
        nade.Destroy()
    }
    testDummy.Destroy()
    #endif
}
