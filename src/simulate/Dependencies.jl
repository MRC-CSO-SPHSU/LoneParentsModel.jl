module Dependencies
    

using Utilities

using ChangeEvents

using BasicInfoAM, KinshipAM, WorkAM #, DemoPerson
using DependenciesIM
using Age, Death, MoveHouse 


export selectAssignGuardian, assignGuardian!, findFamilyGuardian, findOtherGuardian
export DependenciesT

struct DependenciesT end

function ChangeEvents.process!(::ChangeAge1Yr, ::DependenciesT, person, model, pars)
    if person.age == pars.ageOfIndependence
        # also updates guardian
        setAsIndependent!(person)
    end
    
    nothing
end

function ChangeEvents.process!(::ChangeDeath, ::DependenciesT, person)
    # dead persons are no longer dependents
    setAsIndependent!(person)

    # dead persons no longer have to be provided for
    setAsSelfproviding!(person)

    for p in person.providees
        p.provider = undefined(p.provider)
        # TODO update provision/work status
    end
    empty!(person.providees)
    
    nothing
end


function hasValidGuardian(person)
    for g in person.guardians
        if g.alive
            return true
        end
    end

    false
end


selectAssignGuardian(person) = person.alive && !canLiveAlone(person) && 
    !hasValidGuardian(person)


function assignGuardian!(person, time, model, pars)
    guard = findFamilyGuardian(person)
    if isUndefined(guard) 
        guard = findOtherGuardian(person, model.pop, pars)
    end

    # get rid of previous (possibly dead) guardians
    # this implies that relatives of a non-related former legal guardian
    # that are now excluded due to age won't get a chance again in the future
    empty!(person.guardians)

    if isUndefined(guard) 
        return false
    end

    # guard and partner become new guardians
    adopt!(guard, person)

    true
end
    
function findFamilyGuardian(person)
    potGuardians = Vector{Union{typeof(person), Nothing}}()

    pparents = parents(person)
    # these might be nonexistent or dead
    append!(potGuardians, pparents)

    # these can but don't have to be identical to the parents
    for g in person.guardians
        push!(potGuardians, g.partner)
    end

    # relatives of biological parents
    # any of these might already be guardians, but in that case they will be dead
    for p in pparents
        if isUndefined(p) 
            continue
        end
        append!(potGuardians, parents(p))
        append!(potGuardians, siblings(p))
    end
    
    # possible overlap with previous, but doesn't matter
    for g in person.guardians
        append!(potGuardians, parents(g))
        append!(potGuardians, siblings(g))
    end

    # potentially lots of redundancy, but just take the first 
    # candidate that works
    for g in potGuardians
        if isUndefined(g) || !g.alive || g.age < 18 
            continue
        end
        return g
    end

    return undefined(person)
end

function findOtherGuardian(person, people, pars)
    candidates = [ p for p in people if 
        isFemale(p) && canLiveAlone(p) && !isSingle(p) && 
            (p.status == WorkStatus.worker || p.partner.status == WorkStatus.worker) ]

    if length(candidates) > 0
        return rand(candidates)
    end

    return undefinedPerson
end


function adopt!(guard, person)
    movePeopleToHouse!([person], guard.pos)
    setAsGuardianDependent!(guard, person)
    if ! isSingle(guard)
        setAsGuardianDependent!(guard.partner, person)
    end
end

end
