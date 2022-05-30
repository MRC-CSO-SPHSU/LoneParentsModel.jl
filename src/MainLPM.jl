"""
Main simulation of the lone parent model 

under construction 
"""

import SocialSimulations: SocialSimulation

import SocialSimulations.LoneParentsModel: createPopulation, loadData!, setSimulationParameters

import SocialSimulations.LoneParentsModel: loadUKMapParameters, loadUKPopulationParameters

import SocialAgents: Town
import SocialABMs: MultiABM, SocialABM
import SocialABMs.LoneParentsModel: createUKDemography


ukmapParameters = loadUKMapParameters()
ukpopParameters = loadUKPopulationParameters() 
ukDemographyParameters = merge(ukmapParameters,ukpopParameters)

# simProperties = setSimulationParameters()

# (uktowns,ukhouses,ukpopulation) = createUKDemography(ukDemographyParameters) # = SocialABM{Town}(createUKDemography,ukmapProperties)

ukDemography = MultiABM(ukDemographyParameters,
                         declare=createUKDemography)


# lpmSimulation = SocialSimulation(createPopulation,simProperties)

# loadData!(lpmSimulation)

# lpmSimulation
