global array<entity> prowler_stack
global array<entity> reaper_stack

global function add_prowler

const int MAX_ENTITIES_PER_STACK = 10

void function remove_from_stack( array<entity> stack )
{
    if ( stack.len() > MAX_ENTITIES_PER_STACK)
    {
        entity target = prowler_stack.remove(0)
        if ( IsValid(target) )
        {
            target.Destroy()
        }
        else
        {
            remove_from_stack(stack)
        }
    }
}

void function add_prowler( entity prowler )
{
    prowler_stack.append(prowler)
    remove_from_stack(prowler_stack)
}

void function add_reaper( entity reaper )
{
    reaper_stack.append(reaper)
    remove_from_stack(reaper_stack)
}
