public class Database : GLib.Object
{
    private FileStream m_log_file;
    private File m_dir_checker;
    private int m_log_file_id_pos;              /* Keep track of what record ID the file pointer is at. It will be at the beginning of that line.
                                                    We can always get the absolute position using tell() */
    private int m_last_record_id;               /* Keep track of the last record ID added. Will only get incremented by add_record */
    public Database(){
            //load an initial hardcoded file here, will add checks and stuff later
            //for now we assume there's no existing file, if there is we delete and start from scratch
        stdout.printf("Loading log file...\n");
        m_dir_checker = File.new_for_path("../data/logs/");
        if(!m_dir_checker.query_exists())
        {
            //"../data/logs" dir doesn't exist so create it with its parents
            stdout.printf("[../data/logs] doesn't exist. Creating now!\n");
            m_dir_checker.make_directory_with_parents();
            //also create the first log file since it won't be there
            //being lazy here cause I don't wanna use the gio File stuff
            m_log_file = FileStream.open("../data/logs/testLog","w+");
            //since file was newly created, init everything
            m_log_file_id_pos = 0; /* only an empty file will cause this to be 0 */
            m_last_record_id = 0;
        }
        else{
            //dir exists so now we check if the file is there
            m_log_file = FileStream.open("../data/logs/testLog","r+");
            if (m_log_file == null){
                //file not present, create it in the lazy way and cary on
                m_log_file = FileStream.open("../data/logs/testLog","w+");
                m_log_file_id_pos = 0;
                m_last_record_id = 0;
            }
            else {
                /* file and dirs exist. get latest record ID and seek to it so
                we're ready for adding records.
                That'll most likely be the first action after launching the program */
                m_last_record_id = find_last_record_id();
                stdout.printf("Opened latest log file!\n");
                m_log_file_id_pos = m_last_record_id;
                seek_to(m_log_file_id_pos);
            }
        }
        m_dir_checker = File.new_for_path("../data/export/");
        if(!m_dir_checker.query_exists())
        {
            //"../data/logs" dir doesn't exist so create it with its parents
            stdout.printf("[../data/export] doesn't exist. Creating now!\n");
            m_dir_checker.make_directory_with_parents();
        }
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

        
        //this leaves the cursor at the beggining of the next line after record_id
    }

    public void delete_record(int record_id) {

        stdout.printf("Enter ID to delete: ");
        
        string line;
        try {
            //checks to see if file has line or not. Uses while loop to print all iterations to the 
            while((line = m_log_file.read_line())!=null){
                string[] vals = line.split(",");
                string id = vals[0];
                foreach(unowned string db_content in vals){
                    stdout.printf("%s\n", db_content);
                }
                foreach(unowned string str in vals){
                    //purely for testing purposes - Not working for final product
                    if(str != id){ 
                        //dostest.put_string("null"); 
                    }
                }
            }
        } catch(Error e) {
            stderr.printf("%s\n", e.message);
        }

        stdout.printf("Deleted record!\n");
    }


    /* getters and setters */
    public int last_record_id {
        get { return m_last_record_id; }
    }
}
