
int main(string[] args) {
    stdout.printf("Welcome to PHP-SrePS!\n");
    Database myDb = new Database();         //opened file
    string str = "blah";
    myDb.add_record(ref str);
    myDb.edit_record(0,ref str);
    myDb.delete_record(0);



    return 0;

}