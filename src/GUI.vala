//public class holding references to all data needed for the callbacks

public class AppGUI{
    private int edit_rec_tr_id;
    private int edit_rec_item_id;
    public Gtk.Label test_label;
    private Gtk.Entry qty_entry;
    private Gtk.Entry dlg_qty_entry;
    private Gtk.Builder m_bldr;
    private Gtk.ListStore item_list_store;
    private Gtk.TreeStore ls;
    private Gtk.TreeIter ti;
    private Gtk.TreeIter ti2;
    private Gtk.TreeIter list_iter;
    private Gtk.TextView debug_text_view;
    private Gtk.TextBuffer debug_text_buf;
    private Gtk.TextIter debug_text_iter;
    private Gtk.ComboBox item_list_chooser;
    private Gtk.ComboBox dlg_item_list_chooser;
    private Gtk.Dialog edit_record_dialog;
    private Gtk.TreePath selected_row_path;         //we keep track of IDs to edit, this is so we can write it back to the gui treestore
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
        m_bldr = bld;


        edit_rec_item_id = -1;
        edit_rec_tr_id = -1;
        test_label = bld.get_object("testLabel") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        qty_entry = bld.get_object("qty_entry") as Gtk.Entry;
        dlg_qty_entry = bld.get_object("dlg_qty_entry") as Gtk.Entry;
        item_list_chooser = bld.get_object("itemlistchooser") as Gtk.ComboBox;
        dlg_item_list_chooser = bld.get_object("dlg_itemlistchooser") as Gtk.ComboBox;
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
        if(edit_record_dialog == null)  message("DIALOG NULL");
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

    //fetches the right info for the given row (record) and updates the tree view
    private void update_tree_store_row(Gtk.TreePath path_to_change){
        Gtk.TreeIter temp;
        //get tran id and item id for that row
        string? db_tr_id = null;
        string? db_item_id = null;
 
        ls.get_iter(out temp, path_to_change);
        ls.get(temp,tree_store_fields.DB_TRANSACTION_ID,&db_tr_id,-1);
        ls.get(temp,tree_store_fields.DB_ITEM_ID,&db_item_id,-1);

        //get the item code
        string db_item_code = db.get_record_info(int.parse(db_tr_id),int.parse(db_item_id),db.record_fields.ITEM_CODE);
        string qty = db.get_record_info(int.parse(db_tr_id),int.parse(db_item_id),db.record_fields.QUANTITY);

        ls.set(temp, tree_store_fields.TRANSACTION_ID,"",
                    tree_store_fields.ITEM_NAME, db.get_item(int.parse(db_item_code)).getName(),
                    tree_store_fields.QUANTITY, qty,
                    tree_store_fields.PRICE, format_price_string(int.parse(db_item_code),qty),
                    -1);
        message("Changed tr %i item %i",edit_rec_tr_id, edit_rec_item_id);
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
        ls.set(ti2, tree_store_fields.TRANSACTION_ID,"",
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
        string qty = qty_entry.get_text();
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
        edit_record_dialog.hide();
    }
    [CCode (instance_pos = -1)]
    public void dlg_done_click (Gtk.Button source) {
        //edit_rec_tr_id/edit_rec_item_id should be set to the last clicked on item
        //get qty from entry
        string? new_qty = null;
        new_qty = dlg_qty_entry.get_text();
        //get item from dropdown
        int new_item_code_num = -1;
        new_item_code_num = dlg_item_list_chooser.get_active();
        message("Editing tr %i item %i with new code %i and qty %s",edit_rec_tr_id, edit_rec_item_id, new_item_code_num, new_qty);
        //call db.edit_item with the right stuff
        if (new_qty != null)
        {
            db.edit_item(edit_rec_tr_id,edit_rec_item_id,ref new_qty,db.record_fields.QUANTITY);
            update_tree_store_row(selected_row_path);
        }
        if(new_item_code_num != -1)
        {
            string new_item_code = new_item_code_num.to_string();
            db.edit_item(edit_rec_tr_id,edit_rec_item_id,ref new_item_code,db.record_fields.ITEM_CODE);
            update_tree_store_row(selected_row_path);
        }
        //update the treestore from the db.

        message("Dialog done!");
        edit_record_dialog.hide();
    }
 
    public void dlg_cancel_click (Gtk.Button source) {
        message("Dialog cancel!");
        edit_record_dialog.hide();
    }

        
    /*
    [CCode (instance_pos = -1)]
    public void diag_resp(Gtk.Dialog source)
    {
        message("Dialog response handler!");
    }
    */
    [CCode (instance_pos = -1)]
    public void on_new_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = qty_entry.get_text();
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
        selected_row_path = path;
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