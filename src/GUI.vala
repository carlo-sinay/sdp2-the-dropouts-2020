using Gtk;

public void on_add_btn_click (Button source) {
    source.label = "Thank you!";
}

public void on_edit_btn_click (Button source) {
    source.label = "Thanks!";
}

int main (string[] args) {
    Gtk.init (ref args);

    try {
        // If the UI contains custom widgets, their types must've been instantiated once
        // Type type = typeof(Foo.BarEntry);
        // assert(type != 0);
        var builder = new Builder();
        builder.add_from_file("../glade/gui.glade");
        builder.connect_signals(null);
        var window = builder.get_object("window") as Window;
        window.show_all();
        Gtk.main();
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    }

    return 0;
}