#!/usr/local/bin/julia

# NOTE: This doesn't work. Window GUI components don't get shown
using RocketBuilder
using Gtk
using SQLite

db = opendb()

tanklist = GtkListStore(String)

for name in tanknames(db)
   push!(tanklist, (name,)) 
end

win = maketankeditor(tanklist, db)

if !isinteractive()
    cond = Condition()
    signal_connect(win, :destroy) do widget
        notify(cond)
        DBInterface.close!(db)
    end
    @async Gtk.gtk_main()
    showall(win)
    wait(cond)
end
