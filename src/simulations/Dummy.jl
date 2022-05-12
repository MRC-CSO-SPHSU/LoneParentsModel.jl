"""
functions for a dummy simulation
"""

import SocialAgents: Town, House, Person
import SocialABMs: add_agent!

"Establish a dummy population"
function initDummyPopulation(houses::Array{House,1})
    
    population = SocialABM{Person}()

    for house in houses
        mother   = Person(house,rand(25:55))
        father   = Person(house,rand(30:55))
        son      = Person(house,rand(1:15))
        daughter = Person(house,rand(1:15))
        add_agent!(mother,population)
        add_agent!(father,population)
        add_agent!(son,population)
        add_agent!(daughter,population)
    end 

    population 
end 


function createDummyPopulation()
    # init Towns
    glasgow   = Town((10,10),"Glasgow") 
    edinbrugh = Town((11,12),"Edinbrugh")
    sterling  = Town((12,10),"Sterling") 
    aberdeen  = Town((20,12),"Aberdeen")
    towns = [aberdeen,edinbrugh,glasgow,sterling]

    # init Houses 
    numberOfHouses = 100 
    sizes = ["small","medium","big"]

    houses = House[] 
    for index in range(1,numberOfHouses)
        town = rand(towns)
        sz   = rand(sizes) 
        x,y  = rand(1:10),rand(1:10)
        push!(houses,House(town,(x,y),sz))
    end
    print("sample houses: \n ")
    print("============== \n ")
    @show houses[1:10]
   
    # init Population 
    population = initDummyPopulation(houses) 
    print("Sample population : \n")
    print("=================== \n ")
    @show population.agentsList[1:10]

    population
end 
