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
    stdout.printf("\n\033[32m---------ALL (%i) RECORDS----------\n",db->last_transaction_id);
    for(int i = 1; i <= db->last_transaction_id; i++)
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
                        d - delete Transaction or Item\n
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



                string rec = item_type+","+quantity+","+price ;

                myDb.add_transaction(ref rec);

                stdout.printf("Do you want to add another record?\n\n");
                string read = stdin.read_line();
                var i = 0;
                if(read == "yes")

                {
                  stdout.printf("Item type: \n");
                  string item_type2 = stdin.read_line();

                  stdout.printf("Quantity: \n");
                  string quantity2 = stdin.read_line();

                  stdout.printf("Price: \n");
                  string price2 = stdin.read_line();

                  string data = item_type2+","+quantity2+","+price2 ;

                  myDb.add_items(ref data);
                  i++;
                  while (i>0)
                  {
                    stdout.printf("Do you want to add another record?\n\n");
                    string read2 = stdin.read_line();
                    if(read2 == "yes")
                    {
                      stdout.printf("Item type: \n");
                      string item_type3 = stdin.read_line();

                      stdout.printf("Quantity: \n");
                      string quantity3 = stdin.read_line();

                      stdout.printf("Price: \n");
                      string price3 = stdin.read_line();

                      string data2 = item_type3+","+quantity3+","+price3 ;

                      myDb.add_items(ref data2);
                    }
                    else
                    {
                      i--;
                    }
                  }
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
                //Pick Transaction
                string which_transaction = stdin.read_line();;
                while (!myDb.check_id_input(ref which_transaction)) {
                    stdout.printf("Error! Invalid input");
                    which_transaction = stdin.read_line();
                }
                int tr_id = int.parse(which_transaction);
                //Pick Item ID in Transaction
                string which_itm_id = stdin.read_line();;
                while (!myDb.check_id_input(ref which_itm_id)) {
                    stdout.printf("Error! Invalid input");
                    which_itm_id = stdin.read_line();
                }
                int itm_id = int.parse(which_itm_id);

                //Populate Edit
                stdout.printf("New Item Code: \n");
                string item_code = stdin.read_line();
                //Check Item Code Validity
                while (!myDb.check_id_input(ref item_code)) {
                    stdout.printf("Error! Invalid input");
                    item_code = stdin.read_line();
                }
                int itm_code_int = int.parse(item_code);

                stdout.printf("New Quantity: \n");
                string quantity = stdin.read_line();
                //Check QTY Validity
                while (!myDb.check_qty_input(ref quantity)) {
                    stdout.printf("Error! Invalid input");
                    quantity = stdin.read_line();
                }
                int qty = int.parse(quantity);

                stdout.printf("New Price: \n");
                string price = stdin.read_line();
                while (!myDb.check_price_input(ref price)) {
                    stdout.printf("Error! Invalid input");
                    price = stdin.read_line();
                }
                int int_price = int.parse(price);

                //Populate Record to update
                string rec = myDb.zero_padding(itm_code_int,3)+",";
                rec += myDb.zero_padding(qty,2)+",";
                rec += myDb.zero_padding(int_price,4) + ",";
                rec += "2020-10-15\n"; //Dummy Date

                myDb.edit_item(tr_id,itm_id,ref rec);
                break;
            case 'd':   //delete Transaction/Item
                stdout.printf("Would you like to Delete Transaction (t) or Item (i)? ");
                string decision = stdin.read_line().down();
                if(decision == "t".down()){
                    stdout.printf("Enter transaction ID to delete: \n");
                    string tr_select = stdin.read_line();
                    int tr_id = int.parse(tr_select);
                    int item_id = tr_id;
                    stdout.printf("Deleted Transaction: %i\n", tr_id);
                    myDb.delete_transaction(tr_id);
                }
                else if(decision == "i".down()){
                    stdout.printf("Enter Transaction ID: \n");
                    string tr_select = stdin.read_line();
                    int tr_id = int.parse(tr_select);
                    stdout.printf("Enter Item ID: \n");
                    string item_select = stdin.read_line();
                    int item_id = int.parse(item_select);
                    myDb.delete_item(tr_id, item_id);
                }
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
