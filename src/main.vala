//Test Functions
//Testing - Find last record id
void test_find_last_record_id(Database db){
    int id = db.find_last_record_id();

    stdout.printf("Last ID: %d\n",id);
}

//Print out whole file
void print_all(Database *db)
{
    stdout.printf("\n\033[32m---------ALL RECORDS----------\n");
    for(int i = 1; i <= db->last_record_id; i++)
    {
        stdout.printf("\t[%s]\n",db->read_record(i));
    }
    stdout.printf("------------------------------\033[0m\n");
}

//Main Function
int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file
    //get console input for now
    while(true){
        print_all(myDb);
        stdout.printf(" c - check line \n a - add record \n r - read record \n e - edit record \n q - exit\n d - delete record (testing)\n z - delete report (Testing)\n\n");
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

                break;
           case 'r':   //read record
                stdout.printf("Which record?\n");
                string which_rec = stdin.read_line();
                int id = which_rec[0].digit_value();
                stdout.printf("\033[33mRecord [%i]: [%s]\033[0m\n",id,myDb.read_record(id));
                break;
            case 'e': //edit record
                stdout.printf("Which record? (By ID)\n");
                string which_rec = stdin.read_line();
                int id = which_rec[0].digit_value();

                stdout.printf("New Item type: \n");
                string item_type = stdin.read_line();

                stdout.printf("New Quantity: \n");
                string quantity = stdin.read_line();

                stdout.printf("New Price: \n");
                string price = stdin.read_line();

                string rec = item_type+","+quantity+","+price+"\n";

                myDb.edit_record(id, ref rec);
                break;
            case 'd':   //delete record (testing)
                stdout.printf("Which record?\n");
                string which_rec = stdin.read_line();
                int id = which_rec[0].digit_value();
                stdout.printf("Deleting %i\n", id);
                myDb.delete_record(id);
                break;
            case 'q':   //exit
                return 0;
                break;
            case 'c':
                stdout.printf("Type in test record. \n");
                string which_line = stdin.read_line();
                int line_id = myDb.check_id_in_line(ref which_line);
                stdout.printf("Record [ %s ] has id %i \n",which_line,line_id);
                break;
            case 'z':  //delete report (testing) NOTE: No double-check for deletion yet
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
