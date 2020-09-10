public class Database : GLib.Object
{
    private File m_log_file;
    private FileIOStream m_log_file_ios;        //use this for seeking 
                                                //(m_log_file_ios.seek(pos, SeekType.SET)
    private DataOutputStream m_log_file_dos;    //use this for writing
                                                //m_log_file_dos.put_string(str);
    private DataInputStream m_log_file_dis;     //use this for reading
                                                //str = m_log_file_dis.read_line();


    public Database(){
        //load an initial hardcoded file here, will add checks and stuff later
        //for now we assume there's no existing file, if there is we delete and start from scratch
        stdout.printf("Loading log file...\n");
       m_log_file = File.new_for_path("../data/logs/testLog");
       if(m_log_file.query_exists())
       {
            m_log_file.delete();
       }
       m_log_file_ios = m_log_file.create_readwrite (FileCreateFlags.NONE);
       //creating the useful input and output streams
       m_log_file_dos = new DataOutputStream( m_log_file_ios.output_stream as FileOutputStream );
       m_log_file_dis = new DataInputStream( m_log_file_ios.input_stream as FileInputStream );
    
       
    }
    

    /* SPRINT 1 FUNCTIONALITY GOES HERE (i guess) */
    public void add_record(ref string rec_to_add)
    {
        //for testing purposes - adding a line to the file
        m_log_file_dos.put_string("1,yes,kefe,iufjeoifu,cnuoidwd\n");
        m_log_file_dos.put_string("2,seven,kefe,iufjeoifu,cnuoidwd\n");
        m_log_file_dos.put_string("3,hello,kefe,iufjeoifu,cnuoidwd\n");
        m_log_file_dos.put_string("4,testing,kefe,iufjeoifu,cnuoidwd\n");
        
        stdout.printf("Adding record!\n");
    }
    public void edit_record(int record_id,ref string new_record)
    {
        stdout.printf("Changing record!\n");
    }
    public void delete_record(int record_id) {
        var dis = new DataInputStream(m_log_file.read());
        FileOutputStream test = m_log_file.replace(null, false, FileCreateFlags.NONE);
        DataOutputStream dostest = new DataOutputStream(test);
        //int seek_pos = m_log_file_ios.seek(0, FileSeek.SET);
        //int c = seek_pos.getc();
        //print("First Char: %c\n", c);

        stdout.printf("Enter ID to delete: ");

        //basic Console input to select which ID to delete
        string id_select = stdin.read_line();
        if(id_select != null && id_select != ""){
            stdout.printf("ID Selected: %s\n", id_select);
        }
        
        string line;
        try {
            //checks to see if file has line or not. Uses while loop to print all iterations to the 
            while((line = dis.read_line(null))!=null){
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
}
