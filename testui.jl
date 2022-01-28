#!/usr/local/bin/julia

using Gtk

win = GtkWindow("Main", 100,50)
button = GtkButton("Exit")
push!(win,button)

signal_connect(button, :clicked) do widget
    Gtk.destroy(win)
    println("Exit")
end


if !isinteractive()
    cond = Condition()
    signal_connect(win, :destroy) do widget
        notify(cond)
        DBInterface.close!(db)
    end
    showall(win)
    @async Gtk.gtk_main()
    wait(cond)
end




