public class Database : GLib.Object
{
   private FileStream m_log_file;
   private FileStream m_report;
   private string column_titles = "Item,Quantity,Price\n";
   private File m_dir_checker;
   private int m_log_file_tid_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line. */
   private int m_log_file_iid_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line. */
                                                   /* We can always get the absolute position using tell() */
   private int m_last_transaction_id;           /* Keep track of the last transaction ID added. Will only get incremented by add_record */
   private int m_last_item_id;                  /* Keep track of the last id (in the last trans) ID added. Will only get incremented by add_record */
   private int m_next_report_id;                /* keep track of current report to make */
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
    m_next_report_id = 1;
   }
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

       for(int i = 1; i <= m_last_transaction_id; i++)
       {
           expand_values_in_record(i,ref line_to_expand);
           stdout.printf("expanded line: %s\n",line_to_expand);
           m_report.puts(line_to_expand);
       }
       m_report.flush();
        return 0;
   }

   public int expand_values_in_record(int record_id, ref string? expanded)
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


    public void seek_to(int tr_id, int it_id)
    {
        //read line by line from beginning and check first 2 fields
        m_log_file.rewind();
        stdout.printf("[%i,%i]\t",tr_id,it_id); 
        if(tr_id == 1) return;      //start of file is ID 1
        m_log_file_tid_pos = 1;
        string? line = null, temp = null;
        string[2]? vals = {"",""};
        int t_id = 1, i_id = 1;
        char ch=0;
        while((temp = m_log_file.read_line ()) != null){
            line = temp;
            //read till we get null string (EOF)
            //line = temp;
            vals = line.split(",",2);
            t_id = int.parse(vals[0]);
            i_id = int.parse(vals[1]);
            if(t_id == tr_id && i_id == it_id){
                m_log_file_tid_pos = t_id;
                m_log_file_iid_pos = i_id;
                break;
            }
        }
        //we found the string, put cursor back a line
        while(ch != '\n'){
            m_log_file.seek(-2,FileSeek.CUR);
            ch = (char)m_log_file.getc();
        }
    }
    
    public void add_record(ref string rec_to_add)
    {
        //for testing purposes - adding a line to the file
        stdout.printf("writing %i bytes\n",rec_to_add.length);
        m_log_file.seek(0,FileSeek.END);
        m_last_transaction_id++;
        //m_log_file_tid_pos = m_last_transaction_id;
        string record = m_last_transaction_id.to_string() + "," + rec_to_add;
        m_log_file.puts(record);
        seek_to(m_last_transaction_id,1);
        stdout.printf("Adding record!\n");
        m_log_file.flush();
    }

    public string? read_record(int record_id, int item_id)
    {
        //return record at line
        seek_to(record_id,item_id);
        return m_log_file.read_line();
    }

    //changed to modify member variables directly as well as return them (for now)
    public int find_last_record_id()
    {
        string? ln_chkr = null;
        string? ln = null;
        string[2] fields = {"",""};
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

        fields = ln.split(",",2);
        id = int.parse(fields[0]);
        m_last_transaction_id = int.parse(fields[0]);
        m_last_item_id = int.parse(fields[1]);
        
        stdout.printf("Last record found: trans id: %i, item id: %i\n",m_last_transaction_id,m_last_item_id);
        //return the file indicator back where it was.
        //seek_to(m_log_file_tid_pos);
        return id;
    }

    public void edit_record(int record_id,ref string new_record)
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

    public void delete_record(int record_id) {

        //Declare remove record string to delete the old information in the record
        string remove_rec = record_id.to_string() + "," + "Deleted Record" + "\n";
        //if statement checks if its reached the last record or not
        if(record_id < m_last_transaction_id){
            //Seeks file pointer to after the target ID
            seek_to(record_id+1,1);
            //appends the records after the updated record info
            do{
                remove_rec += m_log_file.read_line()+"\n";
            } while(!m_log_file.eof());
        }
        //move the file pointer back to the desired target ID
        seek_to(record_id,1);
        //replaces the record with remove_rec, effectively deleting the record
        m_log_file.puts(remove_rec);
        stdout.printf("Deleted record!\n");
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

    /* getters and setters */
    public int last_record_id {
        get { return m_last_transaction_id; }
    }
}
