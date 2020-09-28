public class Database : GLib.Object
{
   private FileStream m_log_file;
   private FileStream m_report;
   private string column_titles = "Item,Quantity,Price\n";
   private File m_dir_checker;
   private int m_log_file_id_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line.
                                                   We can always get the absolute position using tell() */
   private int m_last_record_id;               /* Keep track of the last record ID added. Will only get incremented by add_record */
   private int m_next_report_id;               /* keep track of current report to make */
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
    m_last_record_id = find_last_record_id();
    stdout.printf("FAIL?\n");
    if(m_last_record_id > 0)
    {
        seek_to(m_last_record_id);
        m_log_file_id_pos = m_last_record_id;
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

       for(int i = 1; i <= m_last_record_id; i++)
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
       seek_to(record_id);
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


    public void seek_to(int record_id)
    {
        m_log_file.rewind();
        long fp = 0;
        long len = 0;
                
        int ch = m_log_file.getc();
        //Variable Size Container for ID
        var builder = new StringBuilder();
        builder.append_c((char)ch);
        //Set first ID
        int id = builder.str.to_int();
        
        m_log_file.rewind();

        if (ch != (FileStream.EOF&0xFF)){
            //Checks for sought ID
            while (id != record_id) {
                //Ignores clearing StringBuilder for first ID
                if (record_id != 1) {
                    len = builder.str.len();
                    builder.erase(0,len);
                }
                //Checks for New Line ('\n')
                while (ch != 0x0a) {
                    ch = m_log_file.getc();
                }
                //Checks for first comma (',') in current line
                while (ch != 0x2c) {
                    ch = m_log_file.getc();
                    builder.append_c((char)ch);            
                }
                len = builder.str.len();
                id = builder.str.to_int();
            }
            //Move File Pointer back by length of ID
            m_log_file.seek((-1)*len,FileSeek.CUR);
            m_log_file_id_pos = id;
            
            //DEBUG: Check File Pointer Position and curent ch as a HEX value
            //fp = m_log_file.tell();
            //stdout.printf("\033[31m FP: %ld | ch: 0x%02hhX\033[0m",fp,(char)ch);
        }
        stdout.printf("[%i]\t",m_log_file_id_pos); 
    }
    
    public void add_record(ref string rec_to_add)
    {
        //for testing purposes - adding a line to the file
        stdout.printf("writing %i bytes\n",rec_to_add.length);
        m_log_file.seek(0,FileSeek.END);
        m_last_record_id++;
        //m_log_file_id_pos = m_last_record_id;
        string record = m_last_record_id.to_string() + "," + rec_to_add;
        m_log_file.puts(record);
        seek_to(m_last_record_id);
        stdout.printf("Adding record!\n");
        m_log_file.flush();
    }

    public string? read_record(int record_id)
    {
        //return record at line
        seek_to(record_id);
        return m_log_file.read_line();
    }

    //For Add Record - prepend id to string
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
        while ((ln_chkr = m_log_file.read_line())!= null) {
            ln = ln_chkr;
            continue;
        }

        fields = ln.split(",",2);
        id = int.parse(fields[0]);
        
        stdout.printf("Last ID found: %i\n",id);
        //return the file indicator back where it was.
        //seek_to(m_log_file_id_pos);
        return id;
        
    }

    public void edit_record(int record_id,ref string new_record)
    {
        //go to specified line
        seek_to(record_id);

        string? line = m_log_file.read_line();
        long line_len = line.len();
        long rec_len = new_record.len();

        if (rec_len <= line_len){
            m_log_file.seek((-1)*line_len-1,FileSeek.CUR);
            string updated_rec = record_id.to_string() + "," + new_record;
            m_log_file.puts(updated_rec);
            stdout.printf("Record Updated!\n");
        }
        else {
            //cannot update a string with extra characters than the original
            stdout.printf("Error: String length overload. Update failed.");
        }

        //TO DO 1: Add method(s) to copy remainder of log after target record
        //TO DO 2: Add cleanup method to remove excess characters
    }

    public void delete_record(int record_id) {
        Database db = new Database();
        stdout.printf("%i\n", record_id);
        string line = null;
        m_log_file = FileStream.open("../data/logs/testLog","r+");

        try {
            //checks to see if file has line or not. Uses while loop to print all iterations to the console
            
            while((line = m_log_file.read_line())!=null){
                
                string[] vals = line.split(",");
                int id = check_id_in_line(ref line);
                foreach(unowned string db_content in vals){
                    if( id == record_id ){
                        //seek_to(record_id);
                        //read_record(record_id);
                        //stdout.printf("%s\n", db_content);
                        string replace_content = db_content.replace(db_content, "null"); //Not Working Yet
                        m_log_file.puts(replace_content);
                        
                    }
                    
                }
                
            }
        } catch(Error e) {
            stderr.printf("%s\n", e.message);
        }

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
        get { return m_last_record_id; }
    }
}
