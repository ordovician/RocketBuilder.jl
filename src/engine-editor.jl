export make_engine_editor, show_engine_editor

using SQLite
using DataFrames
using Gtk
using Rockets

function show_engine_editor()
    db = opendb()
    win = make_engine_editor(list, db)
    showall(win)
    return win, db
end

function make_engine_editor(db::DBInterface.Connection)
    path = "data/engineui.glade"
    builder = GtkBuilder(filename=path); 
    w = builder["enginewin"]; 
    showall(w)
        
    return win    
end