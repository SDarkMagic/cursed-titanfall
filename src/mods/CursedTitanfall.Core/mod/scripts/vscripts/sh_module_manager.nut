global function Init_ModuleManager
global function LoadModule
global function UnloadModule
global function GetLoadedModules
global function IsModuleLoaded

struct {
    array< string > loadedModules
} file

void function Init_ModuleManager()
{
    LoadModule( "cs.core" )
}

bool function IsModuleLoaded( string moduleName )
{
    return file.loadedModules.contains( moduleName )
}

void function LoadModule( string moduleName )
{
     Assert( !file.loadedModules.contains( moduleName ), "Already added " + moduleName + " to loaded modules"  )
     file.loadedModules.append( moduleName )
}

void function UnloadModule( string moduleName )
{
    Assert( file.loadedModules.contains( moduleName ), moduleName + " is not currently loaded"  )
    int index = file.loadedModules.find( moduleName )
    file.loadedModules.remove( index )
}

array< string > function GetLoadedModules()
{
    return file.loadedModules
}