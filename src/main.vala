int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file
    
    //get console input for now
    stdout.printf("Item type: \n");
    string item_type = stdin.read_line();


    stdout.printf("Quantity: \n");
    string quantity = stdin.read_line();


    stdout.printf("Price: \n");
    string price = stdin.read_line();
    
    string rec = ","+item_type+","+quantity+","+price + "\n";
    
    myDb.add_record(ref rec);

    return 0;

}