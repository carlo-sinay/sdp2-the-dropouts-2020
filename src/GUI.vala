//public class holding references to all data needed for the callbacks

public class AppGUI{
    private int myInt = 5;
    public Gtk.Label test_label;
    private Gtk.Entry test_entry;
    private Gtk.TreeStore ls;
    private Gtk.TreeIter ti;
    private Gtk.TreeIter ti2;
    private Gtk.ComboBox item_list_chooser;
    private Gtk.ListStore item_list_store;
    private Gtk.CellRenderer qty_renderer;
    private Database db;

    public AppGUI(ref Gtk.Builder bld, int sz)
    {
        db = new Database();

        test_label = bld.get_object("testLabel") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        test_entry = bld.get_object("qty_entry") as Gtk.Entry;
        item_list_chooser = bld.get_object("itemlistchooser") as Gtk.ComboBox;
        item_list_store = bld.get_object("itemliststore") as Gtk.ListStore;
        qty_renderer = bld.get_object("renderer6") as Gtk.CellRenderer;
        //qty_renderer.set_visible(false);
    }

    [CCode (instance_pos = -1)]
    public void on_add_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        int qty = int.parse(test_entry.get_text());
        //item price in dollars with 2 dp.
        float item_price_d = (float)item_list[item_id].price / 100 * qty;
        string price_str = "$"+item_price_d.to_string();
        ls.append(out ti,null);
        ls.set(ti,  0,"Transaction",
                    -1);
        ls.append(out ti2,ti);
        ls.set(ti2, 0,"69",
                    1,item_list[item_list_chooser.get_active()].name,
                    2, test_entry.get_text(),
                    3, price_str,
                    -1);
        test_label.set_label("Added!");
    }

    [CCode (instance_pos = -1)]
    public void on_edit_btn_click (Gtk.Button source) {
        //source.label = "PRESSED";
        string str = "chosen item: " + item_list_chooser.get_active().to_string();
        test_label.set_text(str);
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
        AppGUI myApp = new AppGUI(ref builder, 10);
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