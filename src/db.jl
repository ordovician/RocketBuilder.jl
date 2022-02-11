export opendb
export load_tanks, add_tank!, findalltanks, findfirsttank, tanknames
export load_engines

using SQLite
using DataFrames
using Rockets

"""
    opendb() -> SQLite.DB
Open SQLite database. Make sure you close it with `DBInterface.close!(db)`
"""
function opendb()
    path = joinpath(datadir, "rockets.db")
    return SQLite.DB(path)    
end

# path = joinpath(datadir, "rockets.db")
# db = SQLite.DB(path)
# DataFrame(DBInterface.execute(db, "SELECT * FROM Tanks"))


"""
    load_tanks() -> DataFrame
Load tank data as a data frame from data/rockets.db SQLite database
"""
function load_engines()
    path = joinpath(datadir, "rockets.db")
    db = SQLite.DB(path)
    
    query = DBInterface.prepare(db, "SELECT * FROM Engines")
    df = DBInterface.execute(query) |> DataFrame
    
    DBInterface.close!(db)  # close database for further interaction
    return df
end


"""
    load_tanks() -> DataFrame
Load tank data as a data frame from data/rockets.db SQLite database
"""
function load_tanks()
    path = joinpath(datadir, "rockets.db")
    db = SQLite.DB(path)
    
    query = DBInterface.prepare(db, "SELECT * FROM Tanks")
    df = DBInterface.execute(query) |> DataFrame
    
    DBInterface.close!(db)  # close database for further interaction
    return df
end

"""
    add_tank(db::Connection, name, tank::Tank)
Adds a tank with given `name` to the `db` database.
"""
function add_tank!(db::DBInterface.Connection, name::AbstractString, tank::Tank)
    query = DBInterface.prepare(db, "INSERT INTO Tanks VALUES(?, ?, ?)")
    DBInterface.execute(query, [name, tank.total_mass, tank.dry_mass])
end

"Find all tanks with given tank name. Should only be one"
function findalltanks(db::DBInterface.Connection, tankname::AbstractString)
    query  = DBInterface.prepare(db, "SELECT * FROM Tanks WHERE Tank LIKE ?")
    result = DBInterface.execute(query, [tankname])
    rows   = Tables.rows(result)        # Get row iterator
    tanks  = map(rows) do row           # Iterate over each row in table
        Tank(row.DryMass, row.TotalMass)
    end
    
    tanks
end

"""
    findfirsttank(db, name)
Finds first tank with `name`. If no such tank is found return `nothing`
"""
function findfirsttank(db::DBInterface.Connection, tankname::AbstractString)
    tanks = findalltanks(db, tankname)
    if isempty(tanks)
        nothing
    else
        tanks[1]
    end
end

function tanknames(db::DBInterface.Connection)
    result = DBInterface.execute(db, "SELECT Tank FROM Tanks")
    rows   = Tables.rows(result)        # Get row iterator
    map(rows) do row
        row.Tank
    end
end