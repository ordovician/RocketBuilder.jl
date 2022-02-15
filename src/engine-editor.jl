export make_engine_editor, show_engine_editor

using SQLite
using DataFrames
using Gtk
using Rockets

"""
    show_engine_editor

Show GTK window with engine data by loading database in `data/rockets.db`.
"""
function show_engine_editor()
    enginesdata = load_engines()
    win = make_engine_editor(enginesdata)
    showall(win)
    return win, db
end

"""
    make_engine_editor(enginesdata::DataFrame)

Show GTK window with engine data stored in `enginesdata`.
"""
function make_engine_editor(enginesdata::DataFrame)
    path = "data/engineui.glade"
    builder = GtkBuilder(filename=path); 
    w = builder["enginewin"]; 

    enginelistview = builder["enginelist"];
    
    # Will get some dummy data, we will immediately replace
    enginestore = builder["enginestore"];
    updatestore!(enginestore, enginesdata)
    
    enginename_entry = builder["engine_name"];
    mass_entry = builder["mass"];
    thrust_sl_entry = builder["thrust_sl"];
    thrust_vac_entry = builder["thrust_vac"];
    isp_sl_entry = builder["isp_sl"];
    isp_vac_entry = builder["isp_vac"];
    
    addbtn = builder["add"];
    removebtn = builder["remove"];
    reloadbtn = builder["reload"];
    savebtn = builder["save"];
    
    # Deal with selection and model update
    selection = GAccessor.selection(enginelistview)
    chid = signal_connect(selection, "changed") do widget
        # selection = GAccessor.selection(enginelistview)
        if hasselection(selection)
            current = selected(selection)
            enginename = enginestore[current, 1]

            i = findfirst(==(enginename), enginesdata.Engine)

            if !isnothing(i)         
                set_gtk_property!(enginename_entry, :text, enginesdata.Engine[i])
                set_gtk_property!(mass_entry, :text, enginesdata.Mass[i])
                set_gtk_property!(thrust_sl_entry, :text, enginesdata.ThrustSL[i])
                set_gtk_property!(thrust_vac_entry, :text, enginesdata.ThrustVac[i])
                set_gtk_property!(isp_sl_entry, :text, enginesdata.IspSL[i])
                set_gtk_property!(isp_vac_entry, :text, enginesdata.IspVac[i])
            end
        end
    end
    
    # Adding row. Note we keep ID (addid) in case we copy paste this into REPL
    # Allows you to disconnect: signal_handler_disconnect(addbtn, addid)
    addid = signal_connect(addbtn, "clicked") do widget
        name = get_gtk_property(enginename_entry, :text, String)

        # Cannot get text as numbers. Need to make that conversion ourselves
        enginename = get_gtk_property(enginename_entry, :text, String)
        masstxt = get_gtk_property(mass_entry, :text, String)
        thrust_sltxt = get_gtk_property(thrust_sl_entry, :text, String)
        thrust_vactxt = get_gtk_property(thrust_vac_entry, :text, String)
        isp_sltxt = get_gtk_property(isp_sl_entry, :text, String)
        isp_vactxt = get_gtk_property(isp_vac_entry, :text, String)
        
        mass = parse(Float64, masstxt)
        thrust_sl = parse(Float64, thrust_sltxt)
        thrust_vac = parse(Float64, thrust_vactxt)
        isp_sl = parse(Float64, isp_sltxt)
        isp_vac = parse(Float64, isp_vactxt)
 
        push!(enginesdata, (
            Engine = enginename,
            Mass = mass,
            ThrustSL = thrust_sl,
            ThrustVac = thrust_vac,
            IspSL = isp_sl,
            IspVac = isp_vac
        ))
        
        push!(enginestore, (name,))
    end
    
    rmid = signal_connect(removebtn, "clicked") do widget
        if hasselection(selection)
            current = selected(selection)
            enginename = enginestore[current, 1]

            i = findfirst(==(enginename), enginesdata.Engine)

            if !isnothing(i)
                # Remove from DataFrame
                deleteat!(enginesdata, i)
                                     
                # Put on this on main GUI task. I think.
                # GUI stuff cannot be run on other tasks 
                Gtk.@sigatom begin
                    deleteat!(enginestore, current)

                    set_gtk_property!(enginename_entry, :text, "")
                    set_gtk_property!(mass_entry, :text, "")
                    set_gtk_property!(thrust_sl_entry, :text, "")
                    set_gtk_property!(thrust_vac_entry, :text, "")
                    set_gtk_property!(isp_sl_entry, :text, "")
                    set_gtk_property!(isp_vac_entry, :text, "")
                    
                    display(enginesdata)
                end
            end
        end
    end
    
    # Reloading
    reloadid = signal_connect(reloadbtn, "clicked") do widget
        Gtk.@sigatom begin
            updatestore!(enginestore, enginesdata)      
        end
    end
    
    saveid = signal_connect(savebtn, "clicked") do widget
        # This is just to demonstrate different ways of working
        # It is not ideal to  delete a whole table and then add all the data
        path = joinpath(datadir, "rockets.db")
        db = SQLite.DB(path)   
        
        # Remove table Engines. Don't throw exception if the table
        # is not there (ifexists=true).
        stmt = SQLite.drop!(db, "Engines", ifexists = true)                

        # Create Engines table from scratch by loading data
        # from DataFrame
        SQLite.load!(enginesdata, db, "Engines")
        
        DBInterface.close!(db)
    end

    showall(w)
    return w    
end

"Put engine names in `enginesdata` into  `enginestore` used by tree view"
function updatestore!(enginestore::GtkListStore, enginesdata::DataFrame)
    empty!(enginestore)
    for name in enginesdata.Engine
       push!(enginestore, (name,)) 
    end  
end