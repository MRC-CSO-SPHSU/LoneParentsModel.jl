"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia Main.jl

from REPL execute it using 
> include("Main.jl")
"""

using CSV
using Tables

include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end


using LPM.ParamTypes
using LPM.ParamTypes.Loaders

using XAgents

using LPM.Demography.Create
using LPM.Demography.Initialize
using LPM.Demography.Simulate

using Utilities

mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}

    fertility :: Matrix{Float64}
    death_female :: Matrix{Float64}
    death_male :: Matrix{Float64}
end


function createUKDemography!(pars)
    ukTowns = createUKTowns(pars.mappars)

    ukHouses = Vector{PersonHouse}()

    ukPopulation = createUKPopulation(pars.poppars)

    fert = CSV.File("data/babyrate.txt.csv",header=0) |> Tables.matrix
    death_female = CSV.File("data/deathrate.fem.csv",header=0) |> Tables.matrix
    death_male = CSV.File("data/deathrate.male.csv",header=0) |> Tables.matrix

    Model(ukTowns, ukHouses, ukPopulation, fert, death_female, death_male)
end


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemography!(towns, houses, pop, pars)
    initialConnectH!(houses, towns, pars)
    initialConnectP!(pop, houses, pars)
end


function run!(model, simPars, pars)
    time = Rational(simPars.startTime)

    simPars.verbose = false

    while time < simPars.finishTime
        
        # TODO remove dead people?
        doDeaths!(people = Iterators.filter(a->alive(a), model.pop),
                  parameters = pars.poppars, data = model, currstep = time, 
                  verbose = simPars.verbose, 
                  checkassumption = simPars.checkassumption)

        babies = doBirths!(people = Iterators.filter(a->alive(a), model.pop), 
                  parameters = pars.birthpars, data = model, currstep = time, 
                 verbose = simPars.verbose, checkassumption = simPars.checkassumption)

        selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
        applyTransition!(selected, ageTransition!, time, model, pars.workpars, 
                         "age", simPars.verbose)

        selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
        applyTransition!(selected, workTransition!, time, model, pars.workpars, 
                         "work", simPars.verbose)

        selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
        applyTransition!(selected, socialTransition!, time, model, pars.workpars, 
                         "social", simPars.verbose)

        append!(model.pop, babies)

        time += simPars.dt
    end
end

const simPars = SimulationPars(false)

const pars = loadUKDemographyPars() 

const model = createUKDemography!(pars)

initializeDemography!(model.towns, model.houses, model.pop, pars.mappars)

@show "Town Samples: \n"     
@show model.towns[1:10]
println(); println(); 
                        
@show "Houses samples: \n"      
@show model.houses[1:10]
println(); println(); 
                        
@show "population samples : \n" 
@show model.pop[1:10]
println(); println(); 

# Execution 

@time run!(model, simPars, pars)
