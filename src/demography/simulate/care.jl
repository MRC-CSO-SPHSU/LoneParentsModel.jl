include("kinship.jl")


socialCareDemand(person, pars) = pars.careDemandInHours[careNeedLevel(person)+1]

numCareLevels(pars) = length(pars.careDemandInHours)


function childCareNeed(child, model, pars)
    ageC = age(child)

    childCare = 
        if ageC < 1
            pars.zeroYearCare
        elseif ageC < 13
            pars.childCareDemand
        else
            0
        end
    
    socCare = socialCareDemand(child, pars)
    
    childCare = max(0, childCare - socCare)
     
    schoolHours = 
        if ageC < 3
            0 
        elseif ageC <= 5
            pars.freeChildCareHoursPreSchool
        else
            pars.freeChildCareHoursSchool
        end
     
     childCare = max(0, childCare - schoolHours)
end
     
        
function householdChildCareNeed(house, model, pars)
    maxChildCare = 0
    for person in house.occupants
        if age(person) >= 13
            continue
        end
        care = childCareNeed(person, model, pars)
        maxChildCare = max(care, maxChildCare)
    end
    maxChildCare
end
 
 
function householdSocialCareNeed(house, model, pars)
    careNeed = 0
    for person in house.occupants
        careNeed += socialCareDemand(person, pars)
    end
    
    careNeed
end


function careSupply(person, pars)
    if careNeedLevel(person) > 0
        return 0
    end
    
    s = Int(status(person))
    
    pars.careSupplyByStatus[s+1]
end
    
function householdSocialCareSupply(house, model, pars)
    supply = 0
    for person in house.occupants
        supply += careSupply(person, pars)
    end
    
    supply
end


function calcHouseholdNetSupply!(house, model, pars)
    cn = householdChildCareNeed(house, model, pars)
    sn = householdSocialCareNeed(house, model, pars)
    s = householdSocialCareSupply(house, model, pars)
    
    s - cn - sn
    
    netCareSupply!(house, s)
end

"Find all households that have positive net care supply"
function supplyHouseholds(model)
    [house for house in model.houses if netCareSupply(house) > 0 ]
end


function buildSupplyDemandNetwork(model, pars)
    links = Link{eltype(model.houses)}[]
    suppliers = supplyHouseholds(model)
    
    for house in suppliers
        # we remove replicate links for now
        l = kinshipNetwork(house, model, pars, true) do h
            # only look at households that require care
            netCareSupply(h) < 0
            end
        append!(links, l)
    end
    
    links
end


function resolveCareSupply!(network, model, pars)
    while !isempty(network)
        l = rand(1:length(network))
        link = network[l]
        
        if netCareSupply(link.t1) <= pars.careQuantum ||
            netCareSupply(link.t2) >= 0
            remove_unsorted!(network, l)
            continue
        end
        
        addCareSupply!(link.t2, pars.careQuantum)
        removeCareSupply!(link.t1, pars.careQuantum)
        
        if netCareSupply(link.t1) <= pars.careQuantum ||
            netCareSupply(link.t2) >= 0
            remove_unsorted!(network, l)
        end
    end
end


function socialCare!(model, pars)
    for h in model.houses
        calcHouseholdNetSupply!(h, model, pars)
    end
    
    network = buildSupplyDemandNetwork(model, pars)
    resolveCareSupply!(network, model, pars)
end