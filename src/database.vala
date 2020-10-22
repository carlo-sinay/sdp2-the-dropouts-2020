public struct graph_info_t {
    int month;
    int item_code;
    int[] data;
}

public class Database : GLib.Object
{
    //Variables
    private FileStream m_log_file;
    private FileStream m_report;
    private string column_titles = "TransactionID,Item,Quantity,Price,Date\n";
    private File m_dir_checker;
    private int m_log_file_tid_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line. */
    private int m_log_file_iid_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line. */
                                                    /* We can always get the absolute position using tell() */
    private int m_last_transaction_id;           /* Keep track of the last transaction ID added. Will only get incremented by add_record */
    private int m_last_item_id;                  /* Keep track of the last id (in the last trans) ID added. Will only get incremented by add_record */
    private int m_next_report_id;                /* keep track of current report to make */

    private List<Item> items;

    //Public Variables for temporary access
    public int[] monthly_data = new int[12];
    public double[] trendline_data = new double[12];

    public enum record_fields {
        TRANSACTION_ID,             //field 0 - transaction ID
        ITEM_ID,                    //field 1 - item ID
        ITEM_CODE,                  //field 2 - item code
        QUANTITY,                   //field 3 - quantity
        PRICE,                      //field 4 - price (redundant but keep anyway)
        DATE                        //field 5 - date in ISO8601, hyphen separated
    }

    //Constructor
    public Database(){
         //load an initial hardcoded file here, will add checks and stuff later
         //for now we assume there's no existing file, if there is we delete and start from scratch
        stdout.printf("Checking if log file exists...\n");
        string filename1 = "../data/logs/"; 
        file_check(ref filename1, 1);                  //check if logs dir exists
        string filename2 = "../data/logs/testLog"; 
        file_check(ref filename2, 0);                  //create log file if not there
        m_log_file = FileStream.open(filename2,"r+");
        if(m_log_file == null) stdout.printf("File not opened properly\n");
        stdout.printf("Opening log file\n");
        int temp = find_last_record_id();       //changed this to directly modify m_* vars
        m_last_item_id = 0;
        if(m_last_transaction_id > 0)
        {
            seek_to(m_last_transaction_id,1);
            m_log_file_tid_pos = m_last_transaction_id;
        }
        string filename3 = "../data/export/";
        file_check(ref filename3,1);             //check if export dir exists if not create it
        //Prepare Item List
        items = new List<Item>();
        make_item_list();

        //Initialise public fields
        for (int i = 0; i < 12; i++){
            trendline_data[i] = 0;
            monthly_data[i] = 0;
        }
        
        m_next_report_id = 1;
    }


    //Functions
    private int file_check(ref string filename, int file_or_dir)
    {
            //checks if file (or directory exists) and then creates it if it doesn't (creates dir with parents if dir)
            //0 = file
            //1 = dir
            //return 0 on success
            //string path = filename;
            File temp = File.new_for_path(filename);

            if(temp.query_exists()) return 1;           //file already exists
            else
            {
                if(file_or_dir==1)
                {
                    //its a dir and it doesn't exist
                    temp.make_directory_with_parents();
                } else {
                    //its a file and it doesn't exist
                    temp.create(FileCreateFlags.NONE);
                }
            }
            return temp.query_exists() ? 0 : 1;
    }
    //Call to show Position of File Pointer in terminal
    private void debug_show_fp(){
        long fp = m_log_file.tell();
        stdout.printf("\n\033[31m FP: [%ld]\033[0m", fp);
    }

    private void debug_msg(){
        stdout.printf("\n\033[31m Error Point Reached \033[0m");
    }

    private void debug_msg_c(char c){
        stdout.printf("\n\033[31m Error => Got [%c] \033[0m",c);
    }
    private void debug_msg_i(int i){
        stdout.printf("\n\033[31m Error => Got [%i] \033[0m",i);
    }
    private void debug_msg_f(double f){
        stdout.printf("\n\033[31m Error => Got [%0.2f] \033[0m",f);
    }



    public int generate_report()
    {
        //generate pretty report with all records currently
        //when we add dates to records, we can allow caller to specify which
        //records to include in report (by ID)
        string? line_to_expand = null;
        string filename = "../data/export/export_" + m_next_report_id.to_string()+".csv";
        file_check(ref filename,0);          //check(create) for report file
        m_report = FileStream.open(filename,"r+");
        if(m_report == null) stdout.printf("report null\n");
        m_next_report_id++;
        stdout.printf("opened report file: %s\n",filename);

        //add column titles
        m_report.puts(column_titles);

        string item_name;
        string qty;
        string price;
        string transaction_id;
        string date;
        for(int i = 1; i <= m_last_transaction_id; i++)
        {
            for(int j = 1; j < find_last_item_id(i); j++){
                int item_code = int.parse(get_record_info(i,j,record_fields.ITEM_CODE));
                transaction_id = get_record_info(i,j,record_fields.TRANSACTION_ID);
                if(item_code != -1){
                item_name = get_item(item_code).getName();
                qty = get_record_info(i,j, record_fields.QUANTITY);
                price = get_record_info(i,j, record_fields.PRICE); 
                date = get_record_info(i,j, record_fields.DATE); 
                } else {
                    item_name = "---";
                    qty = "---";
                    price = "---";
                    date = "---";
                }
                line_to_expand = transaction_id + "," + item_name + "," + qty + "," + price + "," + date + "\n"; 
                m_report.puts(line_to_expand);
            }
        }
        m_report.flush();
            return 0;
    }

    private int expand_values_in_record(int record_id, ref string? expanded)
    {
        //expand record with human readable values
        //right now just makes it all uppercase, later we'll replace with
        //actual item name strings (when we also have item Codes)
        seek_to(record_id,1);
        string line = m_log_file.read_line();
        string[] vals = line.split(",");
        line = "";
        for(int i = 0; i < vals.length; i++)
        {
            if(i>0) vals[i] = vals[i].ascii_up(vals[i].length);
            if(i== vals.length-1) line+=vals[i];
            else line+=vals[i]+",";
        }
        expanded = line+"\n";
        return 0;
    }


    public int check_id_in_line(ref string line)
    {
        //check the ID at the start of the given string
        //has to be valid log record
        string[] fields = line.split(",");
        int id = int.parse(fields[0]);
        return id;
    }


   

    private string zero_padding(int i, int length)

    {
        string output = "000";

        //Check input validity
        if ((i > 9999)||(i<1)){
            return output; // 000 is an error code (for now)
        }

        //Padding
        switch (length){
            //Pad for QTY
            case 2:
                if ((i>9)&&(i<=99)){
                    output = i.to_string();
                }
                if ((i>0)&&(i<=9)){
                    output = "0" + i.to_string();
                }
                break;
            //Pad for IDs
            case 3:
                if ((i>99)&&(i <= 999)) {
                    output = i.to_string();
                }
                if ((i>9)&&(i<=99)){
                    output = "0" + i.to_string();
                }
                if ((i>0)&&(i<=9)){
                    output = "00" + i.to_string();
                }
                break;
            //Pad for Price
            case 4:
                if ((i>999)&&(i <= 9999)) {
                    output = i.to_string();
                }
                if ((i>99)&&(i<=999)){
                    output = "0" + i.to_string();
                }
                if ((i>9)&(i<=99)){
                    output = "00" + i.to_string();
                }
                if ((i>0)&(i<=9)){
                    output = "000" + i.to_string();
                }
                break;
            default:
                break;
        }
        return output;
    }

    public bool check_id_input(ref string line){
        //Ensures id doesn't exceed 999 or is null
        return (line.length > 3)||(line == "") ? false : true;
    }

    public bool check_qty_input(ref string line){
        //Ensures qty doesn't exceed 99
        return (line.length > 2||(line == "")) ? false : true;
    }

    public bool check_price_input (ref string line) {
        //Ensures price doesn't exceed 9999
        return (line.length > 4)||(line == "") ? false : true;
    }



    
    
    private void seek_to(int tr_id, int it_id)

    {
        //read line by line from beginning and check first 2 fields
        m_log_file.rewind();
        m_log_file_tid_pos = 1;
        string? line = null, temp = null;
        string[3]? vals = {"","",""};
        int t_id = 1, i_id = 1;
        char ch=0;
        while((temp = m_log_file.read_line()) != null){
            line = temp;
            //read till we get null string (EOF)
            vals = line.split(",",3);
            t_id = int.parse(vals[0]);
            i_id = int.parse(vals[1]);

            if((t_id == tr_id) && (i_id == it_id)){
                m_log_file_tid_pos = t_id;
                m_log_file_iid_pos = i_id;
                //stdout.printf("t_id: [%d] | i_id: [%d]",t_id,i_id);
                //Move File Pointer Back to start of line
                m_log_file.seek(-31,FileSeek.CUR);
                break;
            }
        }
    }


    public void add_transaction(ref string rec_to_add)
    {

        //obtaining date from local machine
        var now = new DateTime.now_local ();
        var date_year = now.get_year().to_string ();
        var date_month = now.get_month();
        var date_day = now.get_day_of_month();
        var fdate_day = "";
        var fdate_month = "";

        //adding prefix zero to the date of the month if required
        fdate_day = zero_padding(date_day,2);
        fdate_day = now.get_day_of_month().to_string();

        //adding prefix zero to the month of the year if required
        fdate_month = zero_padding(date_month,2);
        fdate_month = now.get_month().to_string();

        //variable date stores current date in formate yyyy-mm-dd
        string date = date_year + "-" + fdate_month + "-" + fdate_day;

        stdout.printf("writing %i bytes\n",rec_to_add.length);
        m_log_file.seek(0,FileSeek.END);
        m_last_transaction_id++;
        m_last_item_id = 1;
        var final_m_last_transaction_id = "";
        var final_m_last_item_id = "";

        // adding prefix zeros to transaction_id and item_id
        final_m_last_transaction_id = zero_padding(m_last_transaction_id,3);
        final_m_last_item_id = zero_padding(m_last_item_id,3);

        /* spliting the values entered by the user in terminal and adding prefix
        zeros to store data in intended format.*/
        string [] padding = rec_to_add.split (",");
        var quantity = zero_padding(int.parse(padding[1]),2);
        var price = zero_padding(int.parse(padding[2]),4);
        var type = zero_padding(int.parse(padding[0]),3);



        //m_log_file_tid_pos = m_last_transaction_id;

        //variable record stores all the information in the form of string to be saved in the log file

        string record = final_m_last_transaction_id + "," + final_m_last_item_id + "," + type.to_string() + "," + quantity.to_string() + "," + price.to_string() + "," + date +  "\n";
        m_log_file.puts(record);
        seek_to(m_last_transaction_id,1);
        seek_to(m_last_item_id,1);
        stdout.printf("Adding record!\n");
        m_log_file.flush();
    }

    /* add_items function is called only after at least one record added to a transaction_id
       and the user tends to add more items to the same transaction id. Basically To add a
       record within a transaction.
    */
    public void add_items(ref string data_add )
    {
      //obtaining date from local machine
      var now = new DateTime.now_local ();
      var date_year = now.get_year().to_string ();
      var date_month = now.get_month();
      var date_day = now.get_day_of_month();
      string fdate_day = "";
      string fdate_month = "";

      //adding prefix zero to the date of the month if required
      //can be replaced with zero_padding(date_day,2)
      if (now.get_day_of_month() < 10)
      {



        fdate_day = zero_padding(date_day,2);

      }
      else
      {
        fdate_day = now.get_day_of_month().to_string();

      }

      //adding prefix zero to the month of the year if required
      //can be replaced with zero_padding(date_month,2)
      if (now.get_month() < 10)
      {



        fdate_month = zero_padding(date_month,2);

      }
      else
      {
        fdate_month = now.get_month().to_string();

      }

      //variable date stores current date in formate yyyy-mm-dd
      string date = date_year + "-" + fdate_month + "-" + fdate_day;

      //BUG fix: didn't check the last item of the last transaction before incrementing
      //resulted in adding 100,001 after 100,003 for example.
      m_last_item_id = find_last_item_id(m_last_transaction_id) + 1;
      //m_last_item_id++;

      var final_m_last_transaction_id = "";
      var final_m_last_item_id = "";

      // adding prefix zeros to transaction_id and item_id
        //BUG fix: zero_padding was being used incorrectly, calling it with length 2 when transaction
        //ID is 100+ resulting in it returning "000". Replaced with a call in the final data string
      /* spliting the values entered by the user in terminal and adding prefix
      zeros to store data in intended format.*/

      string [] padding = data_add.split (",");
      var quantity = zero_padding(int.parse(padding[1]),2);
      var price = zero_padding(int.parse(padding[2]),4);
      var type = zero_padding(int.parse(padding[0]),3);


      m_log_file.seek(0,FileSeek.END);

      //variable data stores all the information in the form of string to be saved in the log file
      string data = zero_padding(m_last_transaction_id,3) + "," + zero_padding(m_last_item_id,3) + "," + type.to_string() + "," + quantity.to_string() + "," + price.to_string() + "," + date + "\n";
      //string data = final_m_last_transaction_id + "," + final_m_last_item_id + "," + type.to_string() + "," + quantity.to_string() + "," + price.to_string() + "," + date + "\n";
      m_log_file.puts(data);
      seek_to(m_last_transaction_id,1);
      seek_to(m_last_item_id,1);
      stdout.printf("Adding another item to the same transaction item id!\n");
      m_log_file.flush();

    }



    public string read_record(int record_id, int item_id)

    {
        //return record at line
        seek_to(record_id,item_id);
        return m_log_file.read_line();

    }


    public string get_record_info(int tr_id, int item_id, record_fields which)
    {
        string info = read_record(tr_id,item_id);
        string[] info_vals = info.split(",");
        //always return the IDs, unless record is valid in which case return relevant data
        if(which <= record_fields.ITEM_ID || info_vals.length > 3)
        {
            return info_vals[which];
        } else {                        //asking for anything other than IDs in deleted record, return -1
            return "-1";
            
        }
    }


    public int find_last_item_id(int tr_id)
    {
        int itm_id = 1;
        int t_id = tr_id;
        //Store String and Split fields
        string? line = null;
        string[3] fields = {"","",""};
        //Seek To Target Transaction
        seek_to(t_id,itm_id);
        //Break Points Inserted (Optimise later)
        do{
            //Clear Fields
            fields = {"","",""};
            line = m_log_file.read_line();
            //EOF Check
            if (line == null) {break;}
            fields = line.split(",",3);
            t_id = int.parse(fields[0]);
            //Check we're still in the same transaction
            if (t_id != tr_id){break;}
            //If we are, assign itm_id
            itm_id = int.parse(fields[1]);
        }while(!m_log_file.eof());
        //m_log_file.rewind();
        return itm_id;
    }

    //changed to modify member variables directly as well as return them (for now)
    private int find_last_record_id()
    {
        string? ln_chkr = null;
        string? ln = null;
        string[3] fields = {"","",""};
        int id = 0;

        //small check here to return 0 if file is empty. -andrej
        if(m_log_file.getc() == -1){
            m_log_file.seek(-1,FileSeek.CUR);
            return 0;
        }
        //If not empty
        m_log_file.rewind();

        while ((ln_chkr = m_log_file.read_line())!= null) {
            ln = ln_chkr;
            continue;
        }

        fields = ln.split(",",3);
        id = int.parse(fields[0]);
        m_last_transaction_id = int.parse(fields[0]);
        m_last_item_id = int.parse(fields[1]);

        stdout.printf("Last record found: trans id: %i, item id: %i\n",m_last_transaction_id,m_last_item_id);
        //return the file indicator back where it was.
        //seek_to(m_log_file_tid_pos);
        return id;
    }

    public void edit_item(int tr_id, int itm_id, ref string edit, record_fields which)
    {
        //Prepare updated item
        string update= zero_padding(tr_id,3) + "," + zero_padding(itm_id,3) + ",";
        //Inject Item Code to updated String
        if (which == ITEM_CODE){
            update += zero_padding(int.parse(edit),3) + ",";
            update += get_record_info(tr_id, itm_id, QUANTITY) + ",";
            update += get_record_info(tr_id, itm_id, PRICE) + ",";
            update += get_record_info(tr_id, itm_id, DATE);
        }
        //Inject Quantity to updated String
        if (which == QUANTITY){
            update += get_record_info(tr_id, itm_id, ITEM_CODE) + ",";
            update += zero_padding(int.parse(edit),2) + ",";
            update += get_record_info(tr_id, itm_id, PRICE) + ",";
            update += get_record_info(tr_id, itm_id, DATE);
        }
        //Inject Price to updated String
        if (which == PRICE){
            update += get_record_info(tr_id, itm_id, ITEM_CODE) + ",";
            update += get_record_info(tr_id, itm_id, QUANTITY) + ",";
            update += zero_padding(int.parse(edit),4) + ",";
            update += get_record_info(tr_id, itm_id, DATE);
        }
        //Inject Date to updated String
        if (which == DATE){
            update += get_record_info(tr_id, itm_id, ITEM_CODE) + ",";
            update += get_record_info(tr_id, itm_id, QUANTITY) + ",";
            update += get_record_info(tr_id, itm_id, PRICE) + ",";
            update += edit;
        }
        update += "\n";
        seek_to(tr_id,itm_id);
        //Update item
        m_log_file.puts(update);
        stdout.printf("Transaction Item Updated!\n");
    }


    //TO DO: Needs to return transaction target
    public void edit_transaction(int record_id,ref string new_record)
    {
        //Prepare updated record
        string updated_rec = record_id.to_string() + "," + new_record + "\n";
        //Move FP to records after target_record
        seek_to(record_id+1,1);
        //Append records after updated record information
        do {
            updated_rec += m_log_file.read_line()+"\n";
        } while (!m_log_file.eof());
        //Move FP back to desired insertion point (start of target record)
        seek_to(record_id,1);
        //Update Record
        m_log_file.puts(updated_rec);
        stdout.printf("Record Updated!\n");

        //TO DO: Add cleanup method to remove excess characters
        //       Important for editing the last records of the file only
    }


    public void delete_transaction(int t_id) {

        seek_to(t_id,1);
        string line = m_log_file.read_line();
        int max_items = 1;

        string[] id_vals = line.split(",");

        while((line = m_log_file.read_line()) != null){
            id_vals = line.split(",");
            int new_tr = int.parse(id_vals[0]);
            int new_item = int.parse(id_vals[1]);
            //check for the next transaction
            stdout.printf("max items : %i\n", max_items);
            if(t_id != new_tr){ break; }
            max_items = new_item;
        }
        for(int i=0; i < max_items; i++){
            delete_item(t_id,i+1);
        }
    }

    //deletes an item within a transaction
    public void delete_item(int t_id, int i_id){

        seek_to(t_id,1);
        string zeros = "0000000000000000000000";
        //gets ID's from the read line
        string tr_id = get_record_info(t_id,i_id,TRANSACTION_ID);
        string it_id = get_record_info(t_id,i_id,ITEM_ID);

        //declare delete line string to replace old info in the transaction
        string del_line = tr_id + "," + it_id + "," + zeros.to_string() + "\n";

        if(t_id < m_last_transaction_id){
            if(i_id == m_last_item_id){
                seek_to(t_id+1,1);
                do{
                    del_line += m_log_file.read_line()+"\n";
                }while(!m_log_file.eof());
            }
        }
        //move to desired item within the tranasction
        seek_to(t_id, i_id);
        //deletes item in transaction
        m_log_file.puts(del_line);
        stdout.printf("Deleting Item %i in Transaction %i\n", i_id, t_id);

    }

    //deletes the .csv report in the data/export directory.
    /*User specifies which report is to be deleted in console (currently testing)
    then it passes into File.new_for_path which just points to the directory and delete it*/
    public void delete_report(string report_name){
        //Goes to file path of the report to delete. Takes input from user
        File file = File.new_for_path("../data/export/"+report_name+".csv");
        try{
            //deletes the file
            file.delete();
        } catch(Error err){
            stdout.printf("Error: %s\n", err.message);
        }
    }

    private void make_item_list(){
        string filename = "../data/itemList";
        file_check(ref filename, 0);
        FileStream file = FileStream.open(filename,"r");
        if(file == null) stdout.printf("File not opened properly\n");

        string? line = null, temp = null;
        string[4] fields;

        while ((line = file.read_line())!=null){
            temp = line;
            fields = line.split(",",4);
            Item itm = new Item(int.parse(fields[0]), fields[1],fields[2],int.parse(fields[3]));

            items.append(itm);
        }
    }

    /*
    * Generates QTY of a given item and month
    * Saves to public array for temporary access
    */
    public int generate_monthly_data(int month, int item_code){
        int tot_qty = 0;
        string to_read = "";
        //Seek to the start of the file
        m_log_file.rewind();

        //Reset monthly Data
        monthly_data[month-1] = 0;

        //Check entire database
        while((to_read = m_log_file.read_line()) != null){
            string[] line_info = to_read.split(",");
            string[] date_info = line_info[5].split("-");
            //Check Month
            if (int.parse(date_info[1]) == month){
                //Check Code
                if (int.parse(line_info[2]) == item_code){
                    tot_qty += int.parse(line_info[3]);
                }
            }
        }

        //Update Monthly Data
        //Save to public array
        monthly_data[month-1] = tot_qty;

        //Return value
        return tot_qty;
    }

    /*
    * Generates QTY of given month
    * Saves to public array for temporary access
    */
    public int generate_monthly_data_all(int month){
        int tot_qty = 0;
        string to_read = "";
        //Seek to the start of the file
        m_log_file.rewind();

        //Reset monthly Data
        monthly_data[month-1] = 0;

        //Check entire database
        while((to_read = m_log_file.read_line()) != null){
            string[] line_info = to_read.split(",");
            string[] date_info = line_info[5].split("-");
            //Check Month
            if (int.parse(date_info[1]) == month){
                tot_qty += int.parse(line_info[3]);
            }
        }

        //Update Monthly Data
        //Save to public array
        monthly_data[month-1] = tot_qty;

        //Return value
        return tot_qty;
    }

    /*
    * Generates QTY of a given item for a year (12 months)
    * Saves to public array for temporary access
    */
    public void generate_yearly_data(int item_code){
        for (int i = 0; i < monthly_data.length; i++){
            generate_monthly_data(i+1,item_code);
        }
    }

    /*
    * Generates QTY of all items for a year (12 months)
    * Saves to public array for temporary access
    */
    public void generate_yearly_data_all(){
        for (int i = 0; i < monthly_data.length; i++){
            generate_monthly_data_all(i+1);
        }
    }
    
    /*
    * Calculates a trendline equation and plots points into a
    * temporary array trendline_points[] for temporary access
    *
    * Formula => y = mx + c
    * > m = sum(x_i - x_avg) * sum (y_i - y_avg) / (sum(x_i-x_avg))^2
    * > c = y_avg - m*x_avg
    */
    public void set_trendline(int start_month, int end_month){
        double x_avg = 0;
        double y_avg = 0; 
        double trend_sum_n = 0;
        double trend_sum_d = 0;
        //get data from monthly_data[]
        for (int i = start_month; i <= end_month; i++){
            //Loop for Averages
            x_avg += (double)(i - start_month + 1);
            y_avg += (double)monthly_data[i-1];
        }
        double n = end_month - start_month + 1;
        x_avg = (double)(x_avg / n);
        y_avg = (double)(y_avg / n);

        for (int i = start_month; i <= end_month; i++){
            //Loop for Summations
            trend_sum_n += ((double)(i - start_month + 1) - x_avg)*((double)monthly_data[i-1] - y_avg);
            trend_sum_d += ((double)(i - start_month + 1) - x_avg)*((double)(i - start_month + 1) - x_avg);
        }
        //Get the gradient
        double m = trend_sum_n / trend_sum_d;
        //Get y-intercept
        double c = (double)(y_avg/(m*x_avg));

        //Populate array for trendline
        for (int i = 0; i < trendline_data.length; i++){
            trendline_data[i] = ((m*(i+1)) + c )* -1;
        }
    }

    public Item get_item(int index){
        return items.nth_data(index);
    }

    public int get_list_length(){
        return (int)items.length();
    }

    /* getters and setters */
    public int last_transaction_id {
        get { return m_last_transaction_id; }
    }
}
