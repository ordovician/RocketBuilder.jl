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

function make_engine_editor(egndata::DataFrame)
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
    
    

    showall(w)
    return win    
end