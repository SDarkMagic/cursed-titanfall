global function Boomer_Setup
void function Boomer_Setup()
{

 ModdedTitanData boomer
 boomer.Name = "#DEFAULT_TITAN_BOOMER"
 boomer.Tag = "Stryder" //The tag is displayed in the selection menu if groupsettings.showtagasprefix /suffix is enabled
 //can be used to give an alternate name to a titan in selection vs actual use
 boomer.Description = "This is the description for boomer"
 boomer.BaseSetFile = "titan_atlas_tracker"
 boomer.BaseName = "tone" //we will use monarchs model
 boomer.altChassisType = frameworkAltChassisMethod.ALT_TITAN
 boomer.titanHints = [
 "#DEATH_HINT_BOOMER_001",
 "#DEATH_HINT_BOOMER_002",
 "#DEATH_HINT_BOOMER_003",
 "#DEATH_HINT_BOOMER_004",
 "#DEATH_HINT_BOOMER_005",
 "#DEATH_HINT_BOOMER_006"
 ]
 #if UI
 boomer.loadoutsMenuControllerFunc = boomerPreviewController
 #endif
 boomer.groupSettings.Name = "#BOOMERCATEGORY"
 boomer.groupSettings.showTagAsSuffix = true
 boomer.groupSettings.showName = false //Only show the chassis type in selection menu


 ModdedTitanWeaponAbilityData GenericWeaponMount
 GenericWeaponMount.weaponName = "mp_titanweapon_xo16_vanguard" //Custom weapons can actually use default weapons as the item
 boomer.Primary = GenericWeaponMount

 ModdedTitanWeaponAbilityData GenericDefensiveMount
 GenericDefensiveMount.weaponName = "mp_titanability_particle_wall"
 boomer.Left = GenericDefensiveMount

 ModdedTitanWeaponAbilityData DefaultCore
 DefaultCore.weaponName = "mp_titancore_salvo_core" //We only have 6 passive slots, 2 are universal and 4 are titan unique
    //So we can only really use 4 Generic slots meaning we cant make all items (gun, core, abilities) generic
 boomer.Core = DefaultCore

 ModdedTitanWeaponAbilityData GenericOffensiveMount
 GenericOffensiveMount.weaponName = "mp_titanweapon_salvo_rockets"
 boomer.Right = GenericOffensiveMount

 ModdedTitanWeaponAbilityData GenricUtilityMount
 GenricUtilityMount.weaponName = "mp_titanability_phase_dash"

 boomer.Mid = GenricUtilityMount

 CustomPersistentVar Primary
 Primary.property = "primary"
 Primary.defaultValue = "mp_titanweapon_xo16_vanguard" //<- this value is actually not err, used. i need to setup "true" custom values first
 Primary.passiveItemsMethod = eItemsMethod.FIND_ALL_TYPE //FIND_ALL_TYPE will setup all items matching itemTypeOverride as accepted items
 Primary.itemTypeOverride = eItemTypes.TITAN_PRIMARY

 boomer.ValidationOverrides["primary"] <- Primary

    /*
    ========Defining Passive4, or Defensive=======
    */

 CustomPersistentVar Defensive
 Defensive.property = "special"
 Defensive.defaultValue = "mp_titanability_particle_wall"
 Defensive.passiveItemsMethod = eItemsMethod.FIND_FORCE//Forces the game to use the exact list of refs we provide
 //In this case FIND Seems like it would work initially, however mp_titanweapon_stun_laser is also of type TITAN_ORDNANCE, but is unique in that it fits a different slot
 //therefor it must be in the utility slot
 //however FIND For this slot would still discover it, and add it to the list of accepted items
 Defensive.itemTypeOverride = eItemTypes.TITAN_SPECIAL
 //Defensive.validationFunc = IsValidboomerSpecial

 boomer.ValidationOverrides["special"] <- Defensive

 ModdedPassiveData ParticleWall
 ParticleWall.Name = "mp_titanability_particle_wall"//Basegame localised names/descriptions can be used
 //This may cause issues with other mods that do this as these names are both display names
 //and internal names, This may change in the future
 ParticleWall.description = "#WPN_TITAN_SHIELD_WALL_DESC"
 ParticleWall.image = $"rui/titan_loadout/defensive/titan_defensive_particle_wall_menu"
 boomer.ValidationOverrides["special"].acceptedItems.append(ParticleWall)

 ModdedPassiveData HeatShield
 HeatShield.Name = "mp_titanweapon_heat_shield"
 HeatShield.description = "#WPN_TITAN_HEAT_SHIELD_DESC"
 HeatShield.image = $"rui/titan_loadout/defensive/titan_defensive_heat_shield_menu"
 boomer.ValidationOverrides["special"].acceptedItems.append(HeatShield)

 ModdedPassiveData VortexShield
 VortexShield.Name = "mp_titanweapon_vortex_shield_ion"
 VortexShield.description = "WPN_TITAN_VORTEX_SHIELD_DESC"
 VortexShield.image = $"rui/titan_loadout/defensive/titan_defensive_vortex_menu"
 boomer.ValidationOverrides["special"].acceptedItems.append(VortexShield)
    /*
    =======Defining Passive5, or utility==========
    */

 CustomPersistentVar Utility
 Utility.property = "antirodeo"
 Utility.defaultValue = "mp_titanability_phase_dash"
 Utility.passiveItemsMethod = eItemsMethod.FIND_FORCE //Not all abilities we have in this slot share a type, so we use FIND_FORCE to specify an exact list of refs
 Utility.itemTypeOverride = eItemTypes.TITAN_ANTIRODEO
 //Utility.validationFunc = IsValidboomerAntirodeo

 boomer.ValidationOverrides["antirodeo"] <- Utility


 /*
 =======Defining Passive6, or Offensive========
 */
 CustomPersistentVar ordnanceSlot
 ordnanceSlot.property = "ordnance"
 ordnanceSlot.defaultValue = "mp_titanweapon_laser_lite"
 ordnanceSlot.passiveItemsMethod = eItemsMethod.FIND
 ordnanceSlot.itemTypeOverride = eItemTypes.TITAN_ORDNANCE
 //ordnanceSlot.validationFunc = IsValidboomerOrdnance

 boomer.ValidationOverrides["ordnance"] <- ordnanceSlot


 CustomPersistentVar coreAbility
 coreAbility.property = "coreAbility"
 coreAbility.defaultValue = "mp_titancore_salvo_core"
 coreAbility.passiveItemsMethod = eItemsMethod.FIND //These all match the same type, but we dont want ALL titan cores
 coreAbility.itemTypeOverride = eItemTypes.TITAN_CORE_ABILITY
 //coreAbility.validationFunc = IsValidboomerCore

 boomer.ValidationOverrides["coreAbility"] <- coreAbility

 ModdedPassiveData SalvoCore
 SalvoCore.Name = "mp_titancore_salvo_core"
 SalvoCore.customIcon = true //Icons arent actually custom, but hardcoded ui atlas' arent meant to display these icons on passive icons
 boomer.ValidationOverrides["coreAbility"].acceptedItems.append(SalvoCore)

 ModdedPassiveData LaserCore
 LaserCore.Name = "mp_titancore_laser_cannon"
 LaserCore.customIcon = true
 boomer.ValidationOverrides["coreAbility"].acceptedItems.append(LaserCore)

 ModdedPassiveData FlameCore
 FlameCore.Name = "mp_titancore_flame_wave"
 FlameCore.customIcon = true
 boomer.ValidationOverrides["coreAbility"].acceptedItems.append(FlameCore)

 ModdedPassiveData DashCore
 DashCore.Name = "mp_titancore_dash_core"
 DashCore.customIcon = true
 boomer.ValidationOverrides["coreAbility"].acceptedItems.append(DashCore)

 ModdedPassiveData ampCore
 ampCore.Name = "mp_titancore_amp_core"
 ampCore.customIcon = true
 boomer.ValidationOverrides["coreAbility"].acceptedItems.append(ampCore)

 FrameworkChassisStruct Ogre
 Ogre.name = "Ogre"
 Ogre.setFile = "titan_ogre_minigun"
 Ogre.executionAnimationType = 57
 #if CLIENT || SERVER
 PrecacheModel($"models/titans/heavy/titan_heavy_ogre_base.mdl")
 #endif
 Ogre.modelOverride = $"models/titans/heavy/titan_heavy_ogre_base.mdl"

 boomer.altChassisArray.append(Ogre)

 FrameworkChassisStruct Atlas
 Atlas.name = "Atlas"
 Atlas.setFile = "titan_atlas_tracker"
 Atlas.executionAnimationType = 55
 //#if CLIENT || SERVER //Removed temporarily because animations crash server
 //PrecacheModel($"models/titans/medium/titan_medium_atlas_base.mdl")
 //#endif
 //Atlas.modelOverride = $"models/titans/medium/titan_medium_atlas_base.mdl"

 boomer.altChassisArray.append(Atlas)

 FrameworkChassisStruct Stryder
 Stryder.name = "Stryder"
 Stryder.setFile = "titan_stryder_leadwall"
 Stryder.executionAnimationType = 52
 #if CLIENT || SERVER
 PrecacheModel($"models/titans/light/titan_light_stryder_base.mdl")
 #endif
 Stryder.modelOverride = $"models/titans/light/titan_light_stryder_base.mdl"

 boomer.altChassisArray.append(Stryder)

 CreateModdedTitanSimple(boomer)//Ah yes """"""""""""Simple""""""""""""


 #if CLIENT
 RegisterTitanAudioFunctionByTitan("#DEFAULT_TITAN_boomer", boomerHandleVoice)
 #endif

}