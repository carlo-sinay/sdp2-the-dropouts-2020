//Class for items. All items will be in an List (of this Class) so
//their index will be their item ID

<<<<<<< HEAD
const item_t item_list[2] = {
    {
        "Item1", "Item 1 description", 199
    },
    {
        "Item2", "Item 2 description", 299
    },
};
=======
public class Item : GLib.Object{
    private int code;
    private string name;
    private string description;
    private int price;

    public Item(int c, string n, string d, int p){
        this.code = c;
        this.name = n;
        this.description = d;
        this.price = p;
    }

    //getters
    public int getCode(){
        return this.code;
    }
    
    public string getName(){
        return this.name;
    }

    public string getDesc(){
        return this.description;
    }
    public int getPrice(){
        return this.price;
    }
}
>>>>>>> master
