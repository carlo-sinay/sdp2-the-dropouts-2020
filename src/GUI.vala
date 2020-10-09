//public class holding references to all data needed for the callbacks

public class AppGUI{
    private int myInt = 3;
    public Gtk.Label test_label;
    private Gtk.Entry test_entry;
    private Gtk.TreeStore ls;
    private Gtk.TreeIter ti;
    private Gtk.TreeIter ti2;

    public AppGUI(ref Gtk.Builder bld)
    {
        test_label = bld.get_object("testLabel") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        test_entry = bld.get_object("qty_entry") as Gtk.Entry;
    }

    [CCode (instance_pos = -1)]
    public void on_add_btn_click (Gtk.Button source) {
    ls.append(out ti,null);
    ls.set(ti,0,"trannies",-1);
    ls.append(out ti2,ti);
    ls.set(ti2,   0,"69",
                  1,test_entry.get_text(),
                  2, 5,
                  //3, 6.9,
                  -1);

    test_label.set_label("Added!");
    }

    [CCode (instance_pos = -1)]
    public void on_edit_btn_click (Gtk.Button source) {
        source.label = "PRESSED";
        test_label.set_text("Boo");
    }
}

int main (string[] args) {
    Gtk.init(ref args);
    /*
    Gtk.Builder builder;
    Gtk.Window window;
    */
    try {
        stdout.printf("Got here");
        var builder = new Gtk.Builder ();
        builder.add_from_file ("../glade/gui.glade");
        //AppGUI myApp = new AppGUI();
        AppGUI myApp = new AppGUI(ref builder);
        var window = builder.get_object ("window") as Gtk.Window;
        
        builder.connect_signals(myApp);
        window.show_all ();
        Gtk.main ();
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    }

    return 0;
}