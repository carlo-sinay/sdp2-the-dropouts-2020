using Gtk;

public class TreeViewSample : Window {

    public TreeViewSample () {
        this.title = "TreeView Sample";
        set_default_size (250, 100);
        var view = new TreeView ();
        setup_treeview (view);
        add (view);
        this.destroy.connect (Gtk.main_quit);
    }

    private void setup_treeview (TreeView view) {

        /*
         * Use ListStore to hold accountname, accounttype, balance and
         * color attribute. For more info on how TreeView works take a
         * look at the GTK+ API.
         */

        var listmodel = new Gtk.ListStore (4, typeof (string), typeof (string),
                                          typeof (string), typeof (string));
        view.set_model (listmodel);

        view.insert_column_with_attributes (-1, "Item", new CellRendererText (), "text", 0);
        view.insert_column_with_attributes (-1, "Qty", new CellRendererText (), "text", 1);

        var cell = new CellRendererText ();
        cell.set ("foreground_set", true);
        view.insert_column_with_attributes (-1, "Cost", cell, "text", 2, "foreground", 3);

        TreeIter iter;
        listmodel.append (out iter);
        listmodel.set (iter, 0, "aspirin", 1, "2", 2, "2,10", 3, "red");

        listmodel.append (out iter);
        listmodel.set (iter, 0, "telfast", 1, "1", 2, "8", 3, "red");
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var sample = new TreeViewSample ();
        sample.show_all ();
        Gtk.main ();

        return 0;
    }
}