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
    private Gtk.TreeIter list_iter;
    private Database db;

    public AppGUI(ref Gtk.Builder bld)
    {
        db = new Database();

        message("RECORD 1: %s",db.read_record(1,1));
        stdout.write((uint8[])"TEST");

        test_label = bld.get_object("testLabel") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        test_entry = bld.get_object("qty_entry") as Gtk.Entry;
        item_list_chooser = bld.get_object("itemlistchooser") as Gtk.ComboBox;
        item_list_store = bld.get_object("itemliststore") as Gtk.ListStore;
        message("PHP-sREPs GUI\n");
        update_item_chooser();
        display_existing_records();
        message("Done.");
    }

    private void update_item_chooser()
    {
        message("Getting items from list...");
        for(int i = 0; i < db.get_list_length(); i++)
        {
            item_list_store.append(out list_iter);
            item_list_store.set(list_iter,0, db.get_item(i).getName() ,-1);
        }
    }

    //get back a formatted string from a price int
    private string format_price_string(int item_code, string qty)
    {
        //item price in dollars with 2 dp.
        float item_price_d = (float)db.get_item(item_code).getPrice() / 100 * int.parse(qty);
        string price_str = "$"+item_price_d.to_string();
//        price_str = db.get_item(item_code).getPrice().to_string();
        return price_str;
    }

    private void add_to_item_list(int which, int item_code, ref string qty){
        //which = 1 to add item in new transaction
        //which = 0 to add item to previous transaction
        if(which == 1){
            ls.append(out ti, null);
            ls.set(ti, 0,"Transaction",
                     -1);
        }
        ls.append(out ti2, ti);
        ls.set(ti2, 0,"69",
                    1, db.get_item(item_code).getName(),
                    2, qty,
                    3, format_price_string(item_code,qty),
                    -1);
    }

    //asks the database for existing records and puts them in the viewer
    private void display_existing_records()
    {
        message("Getting existing records...");
        int i = 1;
        int j = 1;
        for(; i <= db.last_transaction_id; i++)
        {
            message("getting record: %i, %i",i, j);
            string? first = db.read_record(i,j);
            message("got record: %s",first);
            string[] first_vals = first.split(",");
            //append new transaction
            //add_to_item_list(1,int.parse(first_vals[db.record_fields.ITEM_CODE]),ref first_vals[db.record_fields.QUANTITY]);
            add_to_item_list(1,int.parse(first_vals[2]),ref first_vals[3]);
            for(; j <= db.find_last_item_id(i); j++)
            {
                message("ADDING tr %i item %i\n",i,j);
                string other = db.read_record(i,j);
                //append items for transaction
                string[] other_vals = other.split(",");
                //add_to_item_list(0,int.parse(other_vals[db.record_fields.ITEM_CODE]),ref other_vals[db.record_fields.QUANTITY]);
                add_to_item_list(0,int.parse(other_vals[2]),ref other_vals[3]);

            }
            j = 1;
        }
    }



    [CCode (instance_pos = -1)]
    public void on_add_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = test_entry.get_text();
        add_to_item_list(0, item_id,ref qty);
        test_label.set_label("Added!");
    }

    [CCode (instance_pos = -1)]
    public void on_edit_btn_click (Gtk.Button source) {


        test_label.set_text("Editing");
    }

    [CCode (instance_pos = -1)]
    public void on_new_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = test_entry.get_text();
        add_to_item_list(1, item_id,ref qty);
        test_label.set_text("New transaction");
    }
    [CCode (instance_pos = -1)]
    public void on_tv_row_active(Gtk.TreeView source, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        test_label.set_label("ROW ACTIVE");
        message("row activated. ti: %i, ti2 %i",ti.stamp, ti2.stamp );
    }
 
}

int main (string[] args) {
    Gtk.init(ref args);
    try {
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