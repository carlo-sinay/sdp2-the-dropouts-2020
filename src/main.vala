
int main(string[] args) {
    stdout.printf("Main!\n");
    Database myDb = new Database();
    myDb.db();

    stdout.printf("Int is %i\n",myDb.getA());

    return 0;

}