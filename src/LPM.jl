module LPM

    include("./XAgents.jl")

    include("./lpm/demography/Create.jl") 
    include("./lpm/demography/Initialize.jl")  
    include("./lpm/demography/Simulate.jl")   

    include("./lpm/Parameters.jl")

end # LoneParentsModel
