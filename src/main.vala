//Test Functions
//Testing - Find last record id
void test_find_last_record_id(Database *db){
    int id = db->find_last_record_id();

    stdout.printf("Last ID: %d\n",id);
}

void test_find_last_item_id(Database *db, int i){
    int id = db->find_last_item_id(i);

    stdout.printf("Last itm ID: %d\n",id);
}

void test_stringbuilder(){
    string? test = "001";
    var builder = new StringBuilder();

    int i = 0;
    while (i < test.char_count()){
        builder.append_c(test[i]);
        i++;
    }

    stdout.printf("builder: [%s]",builder.str);
    stdout.printf("\n To Int: [%d]",builder.str.to_int());
}

void test_padding(){
    stdout.printf("\n\n\n");
}

void test_lists(Database *db){
    Item itm = db->get_item(2);

    stdout.printf("name: [%s]",itm.getName());
}

//Print out whole file
void print_all(Database *db)
{
    stdout.printf("\n\033[32m---------ALL (%i) RECORDS----------\n",db->last_record_id);
    for(int i = 1; i <= db->last_record_id; i++)
    {
        for (int j = 1; j <= db->find_last_item_id(i); j++){
            stdout.printf("\t[%s]\n",db->read_record(i,j));
        }
    }
    stdout.printf("------------------------------\033[0m\n");
}

void list_all_items(Database* db)
{
    stdout.printf("\n\033[32m---------ITEMS----------\n");
    for(int i = 0; i < db->get_list_length(); i++)
    {
        stdout.printf("Item no. [%d]: NAME: %s DESCRIPTION: %s COST: %d\n",
        db->get_item(i).getCode(),
        db->get_item(i).getName(),
        db->get_item(i).getDesc(),
        db->get_item(i).getPrice());
    }
    stdout.printf("------------------------\033[0m\n");
}

//Main Function
int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file
    //get console input for now
    while(true){
        print_all(myDb);
        stdout.printf("
                        c - check line\n
                        a - add record\n
                        r - read record\n
                        e - edit record\n
                        g - generate report\n
                        i - list items\n
                        d - delete record\n
                        z - delete report\n
                        q - exit\n
                      ");
        stdout.printf("Option: ");
        string input = stdin.read_line();
        switch(input[0]){
            case 'a':   //add record
                stdout.printf("Item type: \n");
                string item_type = stdin.read_line();

                stdout.printf("Quantity: \n");
                string quantity = stdin.read_line();

                stdout.printf("Price: \n");
                string price = stdin.read_line();



                string rec = item_type+","+quantity+","+price + "\n";

                myDb.add_record(ref rec);

                stdout.printf("Do you want to add another record?\n\n");
                string read = stdin.read_line();
                if(read == "yes")
                {
                  stdout.printf("Item type: \n");
                  string item_type2 = stdin.read_line();

                  stdout.printf("Quantity: \n");
                  string quantity2 = stdin.read_line();

                  stdout.printf("Price: \n");
                  string price2 = stdin.read_line();

                  string data = item_type2+","+quantity2+","+price2 + "\n";

                  myDb.add_items(ref data);
                }




                break;
            case 'r':   //read record
                stdout.printf("Which transaction?\n");
                string which_rec = stdin.read_line();
                int id = int.parse(which_rec);
                stdout.printf("Which item?\n");
                string which_it = stdin.read_line();
                int item_id = int.parse(which_it);
                stdout.printf("\033[33mRecord [%i]: [%s]\033[0m\n",id,myDb.read_record(id,item_id));
                break;
            case 'e': //edit record
                stdout.printf("Which record? (By ID)\n");
                string which_rec = stdin.read_line();
                int id = int.parse(which_rec);

                stdout.printf("New Item type: \n");
                string item_type = stdin.read_line();

                stdout.printf("New Quantity: \n");
                string quantity = stdin.read_line();

                stdout.printf("New Price: \n");
                string price = stdin.read_line();

                string rec = item_type+","+quantity+","+price;

                myDb.edit_record(id, ref rec);
                break;
            case 'd':   //delete record
                stdout.printf("Which record?\n");
                string which_rec = stdin.read_line();
                int id = int.parse(which_rec);
                stdout.printf("Deleting %i\n", id);
                myDb.delete_record(id);
                break;
            case 'q':   //exit
                return 0;
                break;
            case 'i':   //exit
                list_all_items(myDb);
                break;
            case 'g':   //generate report
                stdout.printf("generating report\n");
                myDb.generate_report();
                break;
            case 'c':
                stdout.printf("Type in test record. \n");
                string which_line = stdin.read_line();
                int line_id = myDb.check_id_in_line(ref which_line);
                stdout.printf("Record [ %s ] has id %i \n",which_line,line_id);
                break;
            case 'z':  //delete report
                stdout.printf("Enter name of report: \n");
                string record_name = stdin.read_line();
                myDb.delete_report(record_name);
                stdout.printf("Report [ %s ] was deleted \n", record_name);
                break;
            default:
                stdout.printf("Not a valid input\n");
                break;
        }
    }
    return 0;
}
