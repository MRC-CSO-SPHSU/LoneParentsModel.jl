using Memoization

export adjacent8Towns, findHousesInTown, emptyHouses, emptyHousesInTown

# memoization not really necessary for low number of towns, but why not
#"Find all towns adjacent to `town` (von Neumann neighbourhood). Memoized for efficiency - empty cache when topology changes."
@memoize adjacent8Towns(town, towns) = [ t for t in towns if isAdjacent8(town, t) ] 


"Find all houses belonging to a specific town."
findHousesInTown(t) = t.houses

emptyHouses(allHouses)  = [ house for house in allHouses if isEmpty(house) ]

emptyHousesInTown(town) = 
    [ house for house in findHousesInTown(town) if isEmpty(house) ]
