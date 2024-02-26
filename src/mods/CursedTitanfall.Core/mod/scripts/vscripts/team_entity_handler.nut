global struct EntityStack {
    array<entity> entities
    int maxEntities = 10
}

global EntityStack prowlerStack
global EntityStack reaperStack
global EntityStack tickStack

global function AddProwler
global function AddTick
global function AddReaper
global function Init_TeamEntityStacks

const int MAX_ENTITIES_PER_STACK = 10

void function Init_TeamEntityStacks()
{
    tickStack.maxEntities = 25
    reaperStack.maxEntities = 4
}

void function RemoveFromStack( EntityStack stack )
{
    if ( stack.entities.len() > stack.maxEntities )
    {
        entity target = stack.entities.remove( 0 )
        if ( IsValid( target ) )
        {
            target.Destroy()
        }
        else
        {
            RemoveFromStack( stack )
        }
    }
}

void function AddProwler( entity prowler )
{
    prowlerStack.entities.append(prowler)
    RemoveFromStack( prowlerStack )
}

void function AddReaper( entity reaper )
{
    reaperStack.entities.append(reaper)
    RemoveFromStack( reaperStack )
}

void function AddTick( entity tick )
{
    tickStack.entities.append( tick )
    RemoveFromStack( tickStack )
}
