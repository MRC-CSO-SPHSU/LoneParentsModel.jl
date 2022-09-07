""" 
Main components of LoneParentsModel simulation based on MultiAgents.jl package 
""" 
module MALPM

    include("./malpm/demography/Population.jl") 

    include("./MAXAgents.jl")

    include("./lpm/demography/Create.jl") 
    include("./lpm/demography/Initialize.jl")  
    include("./lpm/demography/Simulate.jl")   

end # MALPM
