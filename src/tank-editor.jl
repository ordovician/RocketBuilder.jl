export maketankeditor, showtankeditor, liststore, treeview

using SQLite
using DataFrames
using Gtk
using Rockets

function showtankeditor()
    db = opendb()
    win = maketankeditor(db)
    showall(win)
    return win, db
end

function maketankeditor(db::DBInterface.Connection)
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
    
    list = liststore(db::DBInterface.Connection)
    model = GtkTreeModel(list)
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
    
    push!(toplayout, detail_layout)
    
    
    # Deal with selection and model update
    selection = GAccessor.selection(tree)
    chid = signal_connect(selection, "changed") do widget
       current = selected(selection)
       tankname = list[current, 1]
       tank = findfirsttank(db, tankname)
       if !isnothing(tank)
            set_gtk_property!(nameentry, :text, tankname)
            set_gtk_property!(totalentry, :text, tank.total_mass)
            set_gtk_property!(dryentry, :text, tank.dry_mass)  
       end
    end

    # To disconnect this signal handler later
    # signal_handler_disconnect(selection, chid)
    
    # Adding row
    addid = signal_connect(addbtn, "clicked") do widget
        name = get_gtk_property(nameentry, :text, String)
        
        # Cannot get text as numbers. Need to make that conversion ourselves
        drytxt = get_gtk_property(dryentry, :text, String)
        totaltxt = get_gtk_property(totalnetry, :text, String)
        
        dry = parse(Float64, drytxt)
        total = parse(Float64, totaltxt)
        
        add_tank!(db, name, Tank(dry, total))
        push!(list, (name,))
    end
    
    # Remove row
    rmid = signal_connect(removebtn, "clicked") do widget
        current = selected(selection)
        tankname = list[current, 1]
        tank = findfirsttank(db, tankname)
        
        if !isnothing(tank)
            deleteat!(list, current)
            
            set_gtk_property!(nameentry, :text, "")
            set_gtk_property!(totalentry, :text, "")
            set_gtk_property!(dryentry, :text, "")  
        end
    end
    
    
    # Reloading
    reloadid = signal_connect(reloadbtn, "clicked") do widget
        empty!(list)
        for name in tanknames(db)
           push!(list, (name,)) 
        end        
    end
        
    return win    
end

function liststore(db::DBInterface.Connection)
    list = GtkListStore(String)
    
    for name in tanknames(db)
       push!(list, (name,)) 
    end
    
    list
end

function treeview(model::GtkTreeModel)
    tree = GtkTreeView(model)

    txtcell = GtkCellRendererText()

    # Render first column as text
    col1 = GtkTreeViewColumn("Tank", txtcell, Dict([("text",0)]))

    push!(tree, col1)

    return tree 
end

"Just meant for experimenting with list view"
function liststore_window_test()
    ls = GtkListStore(String, Int, Bool)
    push!(ls,("Peter",20,false))
    push!(ls,("Paul",30,false))
    push!(ls,("Mary",25,true))
    
    m  = GtkTreeModel(ls)
    tv = GtkTreeView(m)
    
    rTxt = GtkCellRendererText()
    rTog = GtkCellRendererToggle()
    
    c1 = GtkTreeViewColumn("Name", rTxt, Dict([("text",0)]))
    c2 = GtkTreeViewColumn("Age", rTxt, Dict([("text",1)]))
    c3 = GtkTreeViewColumn("Female", rTog, Dict([("active",2)]))
    
    push!(tv, c1, c2, c3)
    
    # Get selection
    selection = GAccessor.selection(tv)
    
    win = GtkWindow(tv, "List View")
    showall(win)
end