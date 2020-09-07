public class Database : GLib.Object
{
    public Database(){
        a = 5;
    }
    private int a;
    public void db()
    {
        stdout.printf("Database!\n");
    }
    public int getA()
    {
        return a;
    }
}
