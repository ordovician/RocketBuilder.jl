#!/usr/local/bin/julia

# NOTE: This doesn't work. Window GUI components don't get shown
using RocketBuilder
using Gtk
using SQLite

db = opendb()
win = maketankeditor(db)

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
        DBInterface.close!(db)
    end
    @async Gtk.gtk_main()
    wait(c)
end
