global struct ProjectileCollisionParams {
    entity projectile
    vector pos
    vector normal
    entity hitEnt
    int hitbox
    bool isCritical
}

global struct GravFieldParams {
    float pull_range
    float pull_strength_max
    int team
    float duration = -1.0
    bool pull_owner = false
}