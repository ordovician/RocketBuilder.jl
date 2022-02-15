export make_engine_editor, show_engine_editor

using SQLite
using DataFrames
using Gtk
using Rockets

function show_engine_editor()
    enginesdata = load_engines()
    win = make_engine_editor(enginesdata)
    showall(win)
    return win, db
end

function make_engine_editor(enginesdata::DataFrame)
    path = "data/engineui.glade"
    builder = GtkBuilder(filename=path); 
    w = builder["enginewin"]; 

    enginelistview = builder["enginelist"];
    enginestore = builder["enginestore"];
    
    enginename_entry = builder["engine_name"];
    mass_entry = builder["mass"];
    thrust_sl_entry = builder["thrust_sl"];
    thrust_vac_entry = builder["thrust_vac"];
    isp_sl_entry = builder["isp_sl"];
    isp_vac_entry = builder["isp_vac"];
    
    addbtn = builder["add"];
    removebtn = builder["remove"];
    reloadbtn = builder["reload"];
    
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
    
    # Adding row
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
    
    # Reloading
    reloadid = signal_connect(reloadbtn, "clicked") do widget
        Gtk.@sigatom begin
            empty!(enginestore)
            for name in enginesdata.Engine
               push!(enginestore, (name,)) 
            end        
        end
    end

    showall(w)
    return win    
end