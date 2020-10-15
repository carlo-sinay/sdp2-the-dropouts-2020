//public class holding references to all data needed for the callbacks

public class AppGUI{
    private int edit_rec_tr_id;
    private int edit_rec_item_id;
    public Gtk.Label test_label;
    private Gtk.Entry test_entry;
    private Gtk.ListStore item_list_store;
    private Gtk.TreeStore ls;
    private Gtk.TreeIter ti;
    private Gtk.TreeIter ti2;
    private Gtk.TreeIter list_iter;
    private Gtk.TextView debug_text_view;
    private Gtk.TextBuffer debug_text_buf;
    private Gtk.TextIter debug_text_iter;
    private Gtk.ComboBox item_list_chooser;
    private Gtk.Dialog edit_record_dialog;
    private Database db;
    
    enum tree_store_fields{
        TRANSACTION_ID,
        ITEM_NAME,
        QUANTITY,
        PRICE,
        DB_TRANSACTION_ID,
        DB_ITEM_ID
    }

    public AppGUI(ref Gtk.Builder bld)
    {
        db = new Database();


        edit_rec_item_id = -1;
        edit_rec_tr_id = -1;
        test_label = bld.get_object("testLabel") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        test_entry = bld.get_object("qty_entry") as Gtk.Entry;
        item_list_chooser = bld.get_object("itemlistchooser") as Gtk.ComboBox;
        item_list_store = bld.get_object("itemliststore") as Gtk.ListStore;
        debug_text_view = bld.get_object("debug_text_view") as Gtk.TextView;
        edit_record_dialog = bld.get_object("edit_dialog") as Gtk.Dialog;
        debug_text_buf = debug_text_view.get_buffer();
        debug_text_buf.get_start_iter(out debug_text_iter);
        if(debug_text_buf == null) message("TEXT BUFFER NULL");
        message("PHP-sREPs GUI\n");
        update_item_chooser();
        display_existing_records();
        message("Done.");
    }

    private void log(string msg)
    {
        //puts a line of text in textbuffer
        debug_text_buf.insert(ref debug_text_iter, msg, msg.length);
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

    private void add_to_item_list(int which, int item_code, ref string qty, ref string db_tr_id, ref string db_it_id){
        //which = 1 to add item in new transaction
        //which = 0 to add item to previous transaction
        if(which == 1){
            ls.append(out ti, null);
            ls.set(ti, tree_store_fields.TRANSACTION_ID,"Transaction",
                     -1);
            return;
        }
        ls.append(out ti2, ti);
        ls.set(ti2, tree_store_fields.TRANSACTION_ID,"69",
                    tree_store_fields.ITEM_NAME, db.get_item(item_code).getName(),
                    tree_store_fields.QUANTITY, qty,
                    tree_store_fields.PRICE, format_price_string(item_code,qty),
                    tree_store_fields.DB_TRANSACTION_ID, db_tr_id,
                    tree_store_fields.DB_ITEM_ID, db_it_id,
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
            string first_item_code = db.get_record_info(i,j,db.record_fields.ITEM_CODE);
            string first_qty = db.get_record_info(i,j,db.record_fields.QUANTITY);
            string db_tr_id = db.get_record_info(i,j,db.record_fields.TRANSACTION_ID);
            string db_it_id = db.get_record_info(i,j,db.record_fields.ITEM_ID);
            message("got record: %s",db.read_record(i,j));
            //append new transaction
            add_to_item_list(1,int.parse(first_item_code),ref first_qty,ref db_tr_id, ref db_it_id);
            
            for(; j <= db.find_last_item_id(i); j++)
            {
                message("ADDING tr %i item %i\n",i,j);
                string rec_item_code = db.get_record_info(i,j,db.record_fields.ITEM_CODE);
                string rec_qty = db.get_record_info(i,j,db.record_fields.QUANTITY);
                string rec_db_tr_id = db.get_record_info(i,j,db.record_fields.TRANSACTION_ID);
                string rec_db_it_id = db.get_record_info(i,j,db.record_fields.ITEM_ID);
                //append items for transaction
                add_to_item_list(0,int.parse(rec_item_code),ref rec_qty, ref rec_db_tr_id, ref rec_db_it_id);

            }
            j = 1;
        }
    }


    [CCode (instance_pos = -1)]
    public void on_add_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = test_entry.get_text();
        //TODO: add item to actual database and get its transaction and item IDs
        string temp = "";
        add_to_item_list(0, item_id,ref qty,ref temp,ref temp);
        log("Adding " + qty + " of " + db.get_item(item_id).getName() + "\n");
    }

    [CCode (instance_pos = -1)]
    public void on_edit_btn_click (Gtk.Button source) {

        string str = "Editing tr: " + edit_rec_tr_id.to_string() + ", item: " + edit_rec_item_id.to_string();
        log(str+"\n");
        log("Running dialog \n");
        int res = edit_record_dialog.run();
        log("response id: " + res.to_string() + "\n");
        //edit_record_dialog.destroy();
    }
    [CCode (instance_pos = -1)]
    public void on_diag_done_click (Gtk.Button source) {
       log("Diag done!\n");
    }
 
    public void on_diag_cancel_click (Gtk.Button source) {
        //edit_record_dialog.destroy();
    }

    [CCode (instance_pos = -1)]
    public void on_new_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = test_entry.get_text();
        //TODO: add item to actual database and get its transaction and item IDs
        string temp = "";
        add_to_item_list(1, item_id,ref qty,ref temp,ref temp);
        add_to_item_list(0, item_id,ref qty,ref temp,ref temp);
        log("New transaction\n");
    }
    [CCode (instance_pos = -1)]
    public void on_tv_row_active(Gtk.TreeView source, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        string? item_name = null;
        string? db_tr_id = null;
        string? db_item_id = null;

        Gtk.TreeIter temp_iter;
        ls.get_iter(out temp_iter, path);
        ls.get(temp_iter,tree_store_fields.ITEM_NAME,&item_name,-1);
        ls.get(temp_iter,tree_store_fields.DB_TRANSACTION_ID,&db_tr_id,-1);
        ls.get(temp_iter,tree_store_fields.DB_ITEM_ID,&db_item_id,-1);
        if(db_tr_id != null) edit_rec_tr_id = int.parse(db_tr_id);
        else edit_rec_tr_id = -1;
        if(db_item_id != null) edit_rec_item_id = int.parse(db_item_id);
        else edit_rec_item_id = -1;
        message("parsing id strings\n");
        string str = "Row: " + path.to_string() + ". Item: " + item_name + ". tr_id: " + edit_rec_tr_id.to_string() + ", it_id: " + edit_rec_item_id.to_string();
        log(str + "\n");
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