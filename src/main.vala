//Test Functions
//Testing - Find last record id
void test_find_last_record_id(ref Database db){
    int id = db.find_last_record_id();

    stdout.printf("Last ID: %d\n",id);
}

void test_edit_record(ref Database db, ref int index, ref string str){
    db.edit_record(ref index, ref str);
}



//Main Function
int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file

    test_find_last_record_id(ref myDb);

    int test_idx = 2;
    string test_str = "hello there";

    test_edit_record(ref myDb, ref test_idx, ref test_str);
    
    //  //get console input for now
    //  stdout.printf("Item type: \n");
    //  string item_type = stdin.read_line();


    //  stdout.printf("Quantity: \n");
    //  string quantity = stdin.read_line();


    //  stdout.printf("Price: \n");
    //  string price = stdin.read_line();

    //  string rec = "3,"+item_type+","+quantity+","+price + "\n";
    
    //  myDb.add_record(ref rec);

    return 0;

}