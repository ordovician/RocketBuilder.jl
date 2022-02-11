# Rocket Builder

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

A package for educational use. It is mainly for creating a Gtk3 GUI for manipulating objects created in the Rockets package.

## GTK Resources
While developing a GTK application, these are useful resources

- [Widget](https://docs.gtk.org/gtk3/visual_index.html) - Visual overview over GTK3 widgets.
- [GtkBuilder](https://docs.gtk.org/gtk3/class.Builder.html) - Used to load `.glade` UI design files.

## Data
Under the `data` directory we have `rockets.sql` which contains SQL statements needed to create the `rockets.db` SQLite3 database.


## Source Code
The `rocketbuilder.jl` file is meant as a way of easily launching the application. It needs some more work to function properly.

Under the `src` directory you find these files of significance:

- `db.jl` - Code interfacing with SQLite3 database found in `data/rockets.db`
- `tank-editor.jl` - Shows a GUI for adding and removing data for propellant tanks to the database.

## Usable Observations From Development

Not all SQL statements support placeholdres such as `?`. For instance this is possible:

    query = DBInterface.prepare(db, "INSERT INTO Tanks VALUES(?, ?, ?)")
    DBInterface.execute(query, [name, tank.total_mass, tank.dry_mass])
    
However using a placeholder for the `SELECT` statement doesn't seem to work.

When working with Gtk3 keep in mind that you are working with a C library with a minimal wrapper. For instance there has been no attempt to wrap the setting of all properties with a Julia function. Gtk objects are GObjects which have properties which can be looked up and set at runtime. In julia we do it like this:

    set_gtk_property!(win, :title, "New title")
    
This applies to windows, buttons, layout or pretty much anything. You can get a property like this:

    get_gtk_property(win, :title, String)
    
Notice how you got to write that you want a `String` back. Don't get clever about this. It is not smart enough to convert a string to a number. So when getting the content of a textfield you need to convert to a number explicitly.

    drytxt = get_gtk_property(dryentry, :text, String)
    totaltxt = get_gtk_property(totalnetry, :text, String)
    
    dry = parse(Float64, drytxt)
    total = parse(Float64, totaltxt
        
Remember when done with the database to close it:

    db = opendb()
    
    # Do a bunch of stuff
    
    DBInterface.close!(db)
        
## Tree View

One of the more complex controls in Gtk is the tree view so lets have some remarks on how to use it.

    model = GtkTreeModel(list)
    tree = GtkTreeView(model)
    
You got different ways of rendering a cell in the tree view. You need
one of these if you are showing text.

    txtcell = GtkCellRendererText()

The tree view can have multiple columns. Here we are defining only a single column with the header `Tank`. The list store provided to the model can have many columns. `Dict([("text", 0)])` says we are using a `txtcell` renderer for the value in the first column in the list store.

    col1 = GtkTreeViewColumn("Tank", txtcell, Dict([("text",0)]))
    push!(tree, col1)
    
