//Test Functions
//Testing - Find last record id
void test_find_last_record_id(Database db){
    int id = db.find_last_record_id();

    stdout.printf("Last ID: %d\n",id);
}



//Main Function
int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file

    test_find_last_record_id(myDb);
    
    //get console input for now
    stdout.printf("Item type: \n");
    string item_type = stdin.read_line();


    stdout.printf("Quantity: \n");
    string quantity = stdin.read_line();


    stdout.printf("Price: \n");
    string price = stdin.read_line();

    string rec = "2,"+item_type+","+quantity+","+price + "\n";
    
    myDb.add_record(ref rec);



    stdout.printf("Enter ID to Delete: ");
    string remove_db_entry = stdin.read_line();

    myDb.delete_record(remove_db_entry.get_char().digit_value());
    return 0;

}