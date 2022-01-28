#!/usr/local/bin/julia

using RocketBuilder
using DataFrames
using Gtk

db = opendb()

tanklist = GtkListStore(String)

for name in tanknames(db)
   push!(tanklist, (name,)) 
end

win = GtkWindow("Tank Editor", 500, 250)

toplayout = GtkBox(:h)  # :h makes a horizontal layout, :v a vertical layout
set_gtk_property!(toplayout, :margin_left, 10)
set_gtk_property!(toplayout, :margin_top, 10)
set_gtk_property!(toplayout,:spacing,10)
push!(win, toplayout)


# Master View Containing list of tanks
master_layout = GtkBox(:v)
set_gtk_property!(master_layout,:spacing,10)
push!(toplayout, master_layout)

model = GtkTreeModel(tanklist)
tree = treeview(model)
    
push!(master_layout, tree)

actions_layout = GtkBox(:h)
set_gtk_property!(actions_layout,:spacing,10)
push!(master_layout, actions_layout)

addbtn = GtkButton("Add")
removebtn = GtkButton("Remove")
reloadbtn = GtkButton("Reload")

push!(actions_layout, addbtn)
push!(actions_layout, removebtn)
push!(actions_layout, reloadbtn)

# Detail View with info about each selected tank
detail_layout = GtkGrid()

namelabel = GtkLabel("Name:")
totallabel = GtkLabel("Total mass:")
drylabel = GtkLabel("Dry mass:")

nameentry = GtkEntry()
totalentry = GtkEntry()
dryentry = GtkEntry()

detail_layout[1, 1] = namelabel
detail_layout[2, 1] = nameentry
detail_layout[1, 2] = drylabel 
detail_layout[2, 2] = dryentry
detail_layout[1, 3] = totallabel
detail_layout[2, 3] = totalentry
    
set_gtk_property!(detail_layout, :column_spacing, 10)
set_gtk_property!(detail_layout, :row_spacing, 10)

# Test exiting
exit_btn = GtkButton("Exit")
detail_layout[2, 4] = exit_btn
signal_connect(exit_btn, :clicked) do widget
    Gtk.destroy(win)
    println("Exit")
end

push!(toplayout, detail_layout)

# Deal with selection and model update
selection = GAccessor.selection(tree)
chid = signal_connect(selection, "changed") do widget
   selection = GAccessor.selection(tree)
   if hasselection(selection)
       current = selected(selection)
       tankname = tanklist[current, 1]
       tank = findfirsttank(db, tankname)
       if !isnothing(tank)
            set_gtk_property!(nameentry, :text, tankname)
            set_gtk_property!(totalentry, :text, tank.total_mass)
            set_gtk_property!(dryentry, :text, tank.dry_mass)  
       end    
   end
end

# To disconnect this signal handler later
# signal_handler_disconnect(selection, chid)

# Adding row
addid = signal_connect(addbtn, "clicked") do widget
    name = get_gtk_property(nameentry, :text, String)

    # Cannot get text as numbers. Need to make that conversion ourselves
    drytxt = get_gtk_property(dryentry, :text, String)
    totaltxt = get_gtk_property(totalentry, :text, String)

    dry = parse(Float64, drytxt)
    total = parse(Float64, totaltxt)

    Gtk.@sigatom begin
        add_tank!(db, name, Tank(dry, total))
        push!(tanklist, (name,))
    end
end

# Remove row
rmid = signal_connect(removebtn, "clicked") do widget
    selection = GAccessor.selection(tree)
    current = selected(selection)
    tankname = tanklist[current, 1]
    tank = findfirsttank(db, tankname)

    if !isnothing(tank)
        Gtk.@sigatom begin
            deleteat!(tanklist, current)

            set_gtk_property!(nameentry, :text, "")
            set_gtk_property!(totalentry, :text, "")
            set_gtk_property!(dryentry, :text, "")
        end
    end
end


# Reloading
reloadid = signal_connect(reloadbtn, "clicked") do widget
    Gtk.@sigatom begin
        empty!(tanklist)
        for name in tanknames(db)
           push!(tanklist, (name,)) 
        end
    end
end

# Close window
# Gtk.destroy(win)

if !isinteractive()
    cond = Condition()
    signal_connect(win, :destroy) do widget
        notify(cond)
        DBInterface.close!(db)
    end
    showall(win)
    @async Gtk.gtk_main()
    wait(cond)
else
    showall(win)
end




