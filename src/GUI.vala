//public class holding references to all data needed for the callbacks

public class AppGUI{
    private int edit_rec_tr_id;
    private int edit_rec_item_id;
    public Gtk.Label test_label;
    private Gtk.Label delete_record_dlg_label;
    private Gtk.Label generate_report_dlg_label;
    private Gtk.Entry qty_entry;
    private Gtk.Entry dlg_qty_entry;
    private Gtk.Entry graph_dlg_data_range;
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
    private Gtk.ComboBox graph_dlg_item_chooser;
    private Gtk.Dialog edit_record_dialog;
    private Gtk.Dialog change_graph_item_dlg;
    private Gtk.Dialog delete_record_dlg;
    private Gtk.Dialog generated_report_dlg;
    private Gtk.TreePath selected_row_path;         //we keep track of IDs to edit, this is so we can write it back to the gui treestore
    private Gtk.Window graph_win;
    private Gtk.Grid graph_grid;
    private Gtk.Paned graph_pane;
    private Database db;
    private Caroline graph;
    private Caroline graph_trend;
    private double[] x_axis = new double[12];

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
        delete_record_dlg_label = bld.get_object("delete_record_dlg_label") as Gtk.Label;
        generate_report_dlg_label = bld.get_object("generate_report_dlg_label") as Gtk.Label;
        ls = bld.get_object("mytreestore") as Gtk.TreeStore;
        qty_entry = bld.get_object("qty_entry") as Gtk.Entry;
        dlg_qty_entry = bld.get_object("dlg_qty_entry") as Gtk.Entry;
        graph_dlg_data_range = bld.get_object("graph_dlg_data_range") as Gtk.Entry;
        item_list_chooser = bld.get_object("itemlistchooser") as Gtk.ComboBox;
        dlg_item_list_chooser = bld.get_object("dlg_itemlistchooser") as Gtk.ComboBox;
        graph_dlg_item_chooser = bld.get_object("graph_dlg_item_chooser") as Gtk.ComboBox;
        item_list_store = bld.get_object("itemliststore") as Gtk.ListStore;
        debug_text_view = bld.get_object("debug_text_view") as Gtk.TextView;
        edit_record_dialog = bld.get_object("edit_dialog") as Gtk.Dialog;
        delete_record_dlg = bld.get_object("delete_record_dlg") as Gtk.Dialog;
        change_graph_item_dlg = bld.get_object("change_graph_item_dlg") as Gtk.Dialog;
        generated_report_dlg = bld.get_object("generated_report_dlg") as Gtk.Dialog;
        graph_win = bld.get_object("graph_win") as Gtk.Window;
        graph_grid = bld.get_object("graph_grid") as Gtk.Grid;
        graph_pane = bld.get_object("graph_pane") as Gtk.Paned;
        debug_text_buf = debug_text_view.get_buffer();
        debug_text_buf.get_start_iter(out debug_text_iter);
        message("PHP-sREPs GUI\n");
        update_item_chooser();
        display_existing_records();
        message("Done.");
        if(edit_record_dialog == null)  message("DIALOG NULL");
        if(change_graph_item_dlg == null)  message("GRAPH ITEM DIALOG NULL");
        if(graph_win == null) message("Graph window null");
        if(graph_grid == null) message("Graph grid null");

        //init x axis data for graph

        for (int i = 1; i <= x_axis.length; ++i)
            x_axis[i-1] = i;
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
        message("Path is %s\n",path_to_change.to_string());
        Gtk.TreeIter temp;
        //get tran id and item id for that row
        string? db_tr_id = null;
        int db_tr_id_num = -1;
        string? db_item_id = null;
        int db_item_id_num = -1;
 
        if(ls.get_iter(out temp, path_to_change) == false) message("INVALID ITER\n");
        ls.get(temp,tree_store_fields.DB_TRANSACTION_ID,&db_tr_id,-1);
        ls.get(temp,tree_store_fields.DB_ITEM_ID,&db_item_id,-1);
        message("Values are %s and %s\n",db_tr_id, db_item_id);
        message("HERE\n");
        if(db_tr_id != null) db_tr_id_num = int.parse(db_tr_id);
        else db_tr_id_num = -1;
        if(db_item_id != null) db_item_id_num = int.parse(db_item_id);
        else db_item_id_num = -1;
        //check if we're changing the transaction heading
        message("Changing tr %i item %i", db_tr_id_num, db_item_id_num);
        if(db_tr_id_num > 0 && db_item_id_num < 0)
        {
            //if so then add the deleted transaction heading and return
            message("Transaction heading\n");
            ls.set(temp, tree_store_fields.TRANSACTION_ID,"---DELETED TRANSACTION---",
                    -1);
        return;
        }

        //get the item code
        string db_item_code = db.get_record_info(int.parse(db_tr_id),int.parse(db_item_id),db.record_fields.ITEM_CODE);
        string qty = db.get_record_info(int.parse(db_tr_id),int.parse(db_item_id),db.record_fields.QUANTITY);

        if(db_item_code == "-1")
        {
            //deleted item
        ls.set(temp, tree_store_fields.TRANSACTION_ID,"---",
                    tree_store_fields.ITEM_NAME, "---",
                    tree_store_fields.QUANTITY, "---",
                    tree_store_fields.PRICE, "---",
                    -1);
 
        } else {
        ls.set(temp, tree_store_fields.TRANSACTION_ID,"",
                    tree_store_fields.ITEM_NAME, db.get_item(int.parse(db_item_code)).getName(),
                    tree_store_fields.QUANTITY, qty,
                    tree_store_fields.PRICE, format_price_string(int.parse(db_item_code),qty),
                    -1);
        message("Changed tr %i item %i",edit_rec_tr_id, edit_rec_item_id);
        }
    }

    private void add_to_item_list(int which, int item_code, ref string? qty, ref string db_tr_id, ref string db_it_id){
        //which = 1 to add item in new transaction (add empty "heading")
        //which = 0 to add item to previous transaction
        //which = 11 to add deleted item in new transaction (add "deleted heading")
        //which = 10 to add deleted item to previous transaction
        if(which == 1){
           ls.append(out ti, null);
           ls.set(ti, tree_store_fields.TRANSACTION_ID,"Transaction",
                      tree_store_fields.DB_TRANSACTION_ID, db_tr_id,
                     -1);
            return;
        } else if (which == 11) {
            ls.append(out ti, null);
            ls.set(ti, tree_store_fields.TRANSACTION_ID,"--DELETED TRANSACTION--",
                      tree_store_fields.DB_TRANSACTION_ID, db_tr_id,
                     -1);
        return;
        }
        //add item, could be deleted, must show it as such
        ls.append(out ti2, ti);
        if(which == 10)
        {
        ls.set(ti2, tree_store_fields.TRANSACTION_ID,"---",
                    tree_store_fields.ITEM_NAME, "---",
                    tree_store_fields.QUANTITY, "---",
                    tree_store_fields.PRICE, "---",
                    tree_store_fields.DB_TRANSACTION_ID, db_tr_id,
                    tree_store_fields.DB_ITEM_ID, db_it_id,
                    -1);
 
        } else {
        ls.set(ti2, tree_store_fields.TRANSACTION_ID,"",
                    tree_store_fields.ITEM_NAME, db.get_item(item_code).getName(),
                    tree_store_fields.QUANTITY, qty,
                    tree_store_fields.PRICE, format_price_string(item_code,qty),
                    tree_store_fields.DB_TRANSACTION_ID, db_tr_id,
                    tree_store_fields.DB_ITEM_ID, db_it_id,
                    -1);
        }
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
            string db_tr_id = db.get_record_info(i,j,db.record_fields.TRANSACTION_ID);
            string db_it_id = db.get_record_info(i,j,db.record_fields.ITEM_ID);
            string first_item_code = db.get_record_info(i,j,db.record_fields.ITEM_CODE);
            if(first_item_code != "-1"){
                string first_qty = db.get_record_info(i,j,db.record_fields.QUANTITY);
                add_to_item_list(1,int.parse(first_item_code),ref first_qty,ref db_tr_id, ref db_it_id);
            } else {
                //deleted record
                string first_qty = "";
                add_to_item_list(11,int.parse(first_item_code),ref first_qty,ref db_tr_id, ref db_it_id);
            }
            message("got record: %s",db.read_record(i,j));
            //append new transaction
            
            for(; j <= db.find_last_item_id(i); j++)
            {
                message("ADDING tr %i item %i\n",i,j);
                string rec_db_tr_id = db.get_record_info(i,j,db.record_fields.TRANSACTION_ID);
                string rec_db_it_id = db.get_record_info(i,j,db.record_fields.ITEM_ID);
                string rec_item_code = db.get_record_info(i,j,db.record_fields.ITEM_CODE);
                if(rec_item_code != "-1"){
                    //legit record
                    string rec_qty = db.get_record_info(i,j,db.record_fields.QUANTITY);
                    add_to_item_list(0,int.parse(rec_item_code),ref rec_qty, ref rec_db_tr_id, ref rec_db_it_id);
                } else {
                    //deleted record
                    string rec_qty = "";
                    add_to_item_list(10,int.parse(rec_item_code),ref rec_qty, ref rec_db_tr_id, ref rec_db_it_id);
                }
            }
            j = 1;
        }
    }
    [CCode (instance_pos = -1)]
    public void on_graph_item_done_click(Gtk.Button source) {
    }

    [CCode (instance_pos = -1)]
    public void on_graph_item_back_click(Gtk.Button source) {
        change_graph_item_dlg.hide();
    }

    [CCode (instance_pos = -1)]
    public void on_graph_export_click (Gtk.Button source) {
        int res = change_graph_item_dlg.run();
        log("active item: " + graph_dlg_item_chooser.get_active().to_string() + "\n");
        graph.destroy(); 
        graph_trend.destroy(); 
        db.generate_yearly_data(graph_dlg_item_chooser.get_active());
        db.set_trendline(1,12);
        double[] new_y = new double[12];
        double[] new_y_trend = new double[12];


        for (int i = 0; i < new_y.length; ++i){
            new_y[i] = db.monthly_data[i];
            new_y_trend[i] = db.trendline_data[i];

        }
        graph_trend = new Caroline(
        x_axis, //dataX
        new_y_trend, //dataY
        "line", //chart type
        true, //yes or no for generateColors function (needed in the case of the pie chart),
        true // yes or no for scatter plot labels
        );
 

        //Simply set Caroline to a variable
        graph = new Caroline(
        x_axis, //dataX
        new_y, //dataY
        "bar", //chart type
        true, //yes or no for generateColors function (needed in the case of the pie chart),
        true // yes or no for scatter plot labels
        );
        graph.spreadY = 12;
        graph_trend.spreadY = 12;

        int sp = 0;
        for(int yl = 0; yl < 13; yl++)
        {
            graph.labelYList.add(sp.to_string());
            graph_trend.labelYList.add(sp.to_string());
            sp += 50;
        }


        graph_grid.attach(graph, 0, 0, 1, 1);
        graph_grid.attach(graph_trend, 0, 0, 1, 1);
        graph_win.show_all();
        message("Exporting data");
        change_graph_item_dlg.hide();

    }

    [CCode (instance_pos = -1)]
    public void on_graph_close_click (Gtk.Button source) {
        graph.destroy();
        graph_win.hide();
    }
    [CCode (instance_pos = -1)]
    public void on_graph_btn_click (Gtk.Button source) {
        log("GRAPH\n");
        message("GRAPH\n");
        if(graph_trend != null) graph_trend.destroy();
        if(graph != null) graph.destroy();
        db.generate_yearly_data(2);
        db.set_trendline(1,10);
        double[] new_y = new double[12];
        double[] new_y_trend = new double[12];

        message("GRAPH2\n");

        for (int i = 0; i < new_y.length; ++i){
            new_y[i] = db.monthly_data[i];
            new_y_trend[i] = db.trendline_data[i];

        }
        graph_trend = new Caroline(
        x_axis, //dataX
        new_y_trend, //dataY
        "line", //chart type
        true, //yes or no for generateColors function (needed in the case of the pie chart),
        true // yes or no for scatter plot labels
        );
 

        //Simply set Caroline to a variable
        graph = new Caroline(
        x_axis, //dataX
        new_y, //dataY
        "bar", //chart type
        true, //yes or no for generateColors function (needed in the case of the pie chart),
        true // yes or no for scatter plot labels
        );
        graph.spreadY = 12;
        graph_trend.spreadY = 12;

        int sp = 0;
        for(int yl = 0; yl < 15; yl++)
        {
            graph.labelYList.add(sp.to_string());
            graph_trend.labelYList.add(sp.to_string());
            sp += 50;
        }


        graph_grid.attach(graph, 0, 0, 1, 1);
        graph_grid.attach(graph_trend, 0, 0, 1, 1);
 
 
        graph_win.show_all();

    }

    [CCode (instance_pos = -1)]
    public void on_add_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = qty_entry.get_text();
        if(int.parse(qty) > 0){
        int price = int.parse(qty) * db.get_item(item_id).getPrice();
        //TODO: add item to actual database and get its transaction and item IDs
        string temp = "";
        string rec = item_id.to_string() + "," + qty + "," + price.to_string();
        db.add_items(ref rec);
        string new_db_tr_id = db.last_transaction_id.to_string();
        string new_db_it_id = db.find_last_item_id(int.parse(new_db_tr_id)).to_string();
        //add_to_item_list(0, item_id,ref qty,ref temp,ref temp);
        add_to_item_list(0, item_id,ref qty,ref new_db_tr_id,ref new_db_it_id);
        log("Adding " + qty + " of " + db.get_item(item_id).getName() + "\n");
        }
    }

    [CCode (instance_pos = -1)]
    public void generate_report_dlg_ok_click(Gtk.Button source) {
        generated_report_dlg.hide();        
    }

    [CCode (instance_pos = -1)]
    public void on_generate_report_click(Gtk.Button source) {
        db.generate_report();
        generate_report_dlg_label.set_text("Report generated. Check your export folder.");
        generated_report_dlg.run();

    }
    [CCode (instance_pos = -1)]
    public void on_new_btn_click (Gtk.Button source) {
        int item_id = item_list_chooser.get_active();
        string qty = qty_entry.get_text();
        if(int.parse(qty) > 0){
        int price = int.parse(qty) * db.get_item(item_id).getPrice();
        //TODO: add item to actual database and get its transaction and item IDs
        string temp = "-1";
        string rec = item_id.to_string() + "," + qty + "," + price.to_string();
        db.add_transaction(ref rec);
        string new_db_tr_id = db.last_transaction_id.to_string();
        string new_db_it_id = db.find_last_item_id(int.parse(new_db_tr_id)).to_string();
        add_to_item_list(1, item_id,ref qty,ref new_db_tr_id,ref temp);
        add_to_item_list(0, item_id,ref qty,ref new_db_tr_id,ref new_db_it_id);
        log("New transaction\n");
        }
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
    public void on_delete_btn_click (Gtk.Button source) {
        bool is_item = false;       //are we deleting item or transaction?
        if(edit_rec_item_id > 0 && edit_rec_tr_id > 0){
            //we're trying to delete one item
            is_item = true;
            message("Deleting item %i in transaction %i\n",edit_rec_item_id, edit_rec_tr_id);
            delete_record_dlg_label.set_text("Are you sure you want to delete item " + edit_rec_item_id.to_string() + " in transaction " + edit_rec_tr_id.to_string() + "?");
        }
        else if( edit_rec_tr_id > 0 && edit_rec_item_id == -1)
        {
            //we're tring to delete a whole transaction
            is_item = false;
            message("Deleting transaction %i\n",edit_rec_tr_id);
            delete_record_dlg_label.set_text("Are you sure you want to delete transaction " + edit_rec_tr_id.to_string() + "?");
        }
        int res = delete_record_dlg.run();
        log("response id: " + res.to_string() + "\n");
        edit_record_dialog.hide();
        if(res > 0)
        {
            if(is_item == true)
            {
                db.delete_item(edit_rec_tr_id,edit_rec_item_id);
                update_tree_store_row(selected_row_path);
            } else {
                //deleting whole transaction
                db.delete_transaction(edit_rec_tr_id);
                update_tree_store_row(selected_row_path);
                selected_row_path.down();
                for(int i = 0; i < db.find_last_item_id(edit_rec_tr_id); i++)
                {
                    edit_rec_item_id = i+1;
                    update_tree_store_row(selected_row_path);
                    selected_row_path.next();
                }
            }
            message("Deleted!\n");
        } else {

            message("Not deleted!\n");
        }
    }

    [CCode (instance_pos = -1)]
    public void delete_record_dlg_no_click (Gtk.Button source) {
        message("Not deleting\n");
        delete_record_dlg.hide();
    }

    [CCode (instance_pos = -1)]
    public void delete_record_dlg_yes_click (Gtk.Button source) {
        message("Deleting\n");
        delete_record_dlg.hide();
    
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
        //edit_record_dialog.hide();
    }
 
    public void dlg_cancel_click (Gtk.Button source) {
        message("Dialog cancel!");
        //edit_record_dialog.hide();
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