globalize_all_functions

struct {
    table< string, void functionref( entity ) > generators
    array< string > classNames
} file

void function Init_WeaponGenerators()
{
    file.generators.mp_weapon_softball <- FullAuto_Softball
    file.classNames.push( "mp_weapon_softball" )
    file.generators.mp_weapon_semipistol <- GuaranteedWipe_Semipistol
    file.classNames.push( "mp_weapon_semipistol" )
}

string function GetRandomWeaponClass_ForGenerator()
{
    int len = file.classNames.len()
    if ( len <= 0 )
        return ""
    string weaponClass = file.classNames[ RandomInt( len ) ]
    return weaponClass
}

void functionref( entity ) function GetGenerator_FromClass( string weaponClass )
{
    Assert( file.generators.contains( weaponClass ), weaponClass + " could not be found in the available generators. Please try again with a valid weapon class" )

    return file.generators[ weaponClass ]
}


// Generator setup functions for individual weapons
void function FullAuto_Softball( entity weapon )
{
    array< string > mods = [ "full_auto", "pas_fast_reload", "pas_fast_swap", "pas_run_and_gun" ]
    weapon.SetMods( mods )
    weapon.SetTitle( "Full Auto Softball" )
}

void function GuaranteedWipe_Semipistol( entity weapon )
{
    array< string > mods = [ "guarantee_wipe" ]
    weapon.SetMods( mods )
    weapon.SetTitle( "Wipe Enemy Team" )
}