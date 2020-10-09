//struct for items. All items will be in an array (of these structs) so
//their index will be their item ID
public struct item_t {
    string name;                //for listing in the report
    string description;         //for the GUI later
    int price;                  //in cents
}

const item_t item_list[2] = {
    {
        "Item1", "Item 1 description", 199
    },
    {
        "Item2", "Item 2 description", 299
    },
};