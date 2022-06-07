"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/LoneParentsModels.jl/src")
julia> include("RunTests.jl")
"""

using Test

using SocialAgents: Person, House, Town

using SocialAgents: verify, isFemale, isMale
using SocialAgents: setFather!, setParent!
using SocialAgents: getHomeTown, getHomeTownName, getHouseLocation 

using Spaces: HouseLocation

using Utilities: readArrayFromCSVFile, createTimeStampedFolder

using Global: Gender, male, female 

@testset "Lone Parent Model Components Testing" begin 

    # List of towns 
    glasgow   = Town((10,10),name="Glasgow") 
    edinbrugh = Town((11,12),name="Edinbrugh")
    sterling  = Town((12,10),name="Sterling") 
    aberdeen  = Town((20,12),name="Aberdeen")

    # List of houses 
    house1 = House(edinbrugh,(1,2)::HouseLocation) 
    house2 = House(aberdeen,(5,10)::HouseLocation) 
    house3 = House(glasgow,(2,3)::HouseLocation) 

    # List of persons 
    person1 = Person(house1,55,gender=male) 
    person2 = person1               
    person3 = Person(house2,25,gender=female) 
    person4 = Person(house1,50,gender=female) 

    @testset verbose=true "Basic declaration" begin
        @test_throws MethodError person4 = Person(1,house1,22)         # Default constructor is disallowed
        
        @test verify(glasgow) 
        @test verify(house1)
        @test verify(person1)

        # Testing that every agent should have a unique ID 
        @test person1.id > 0                        
        @test house1.id != person1.id       
        @test person3.id != person1.id                  # A new person is another person   

        # every agent should be assigned with a location        
        @test person1.pos == house1        

        @test person1 === person2 
    end 

    @testset verbose=true "Type Person" begin
        @test getHomeTown(person1) != nothing             
        @test getHomeTownName(person1) == "Edinbrugh"    
        
        @test !isinteger(person1.age) skip = false 
        
        @test isMale(person1)
        @test !isFemale(person1)
        
        setFather!(person3,person1) 
        @test person3 in person1.childern
        @test person3.father === person1 

        setParent!(person3,person4) 
        @test person3.mother === person4
        @test person3 in person4.childern 

        person1.pos = house2       
        @test getHomeTown(person1) == aberdeen       
    end 

    @testset verbose=true "Type House" begin

        @test house1.id > 0                    
        @test house1.pos != nothing         
        @test getHomeTown(house1) === edinbrugh 
        @test getHouseLocation(house1) == (1,2)

    end # House functionalities 

    # detect_ambiguities(AgentTypes)

    #=
        testing SocialABMs TODO 

        @test (pop = Population()) != nothing                           # Population means something 
        @test household = Household() != nothing                        # a household instance is something 

        @test_throws UndefVarError town = Town()                        # Town class is not yet implemented 
        @test town = Town()                          skip=true  
    =# 

    # TODO testing SocialABMs once designed

    # TODO testing stepping functions once design is fixed 

    @testset verbose=true "Utilities" begin
        simfolder = createTimeStampedFolder()
        @test !isempty(simfolder)                                       skip=false 
        @test isdir(simfolder)                                          skip=false 
        @test readArrayFromCSVFile("filename-todo.csv") != nothing      skip=false 
    end

    @testset verbose=true "Lone Parent Model Simulation" begin

        import  SocialSimulations: SocialSimulation
        import  SocialSimulations.LoneParentsModel as SimLPM  

        simProperties = SimLPM.setSimulationParameters()
        lpmSimulation = SocialSimulation(SimLPM.createPopulation,simProperties)

        @test SimLPM.loadMetaParameters!(lpmSimulation) != nothing  skip=true
        @test SimLPM.loadModelParameters!(lpmSimulation) != nothing skip=false
        @test SimLPM.createShifts!(lpmSimulation) != nothing        skip=false 

    end 

end  # Lone Parent Model main components 