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
        m_log_file_dos.put_string("1, meme, kefe, eiufjeoifu, cnuoidwd\n");
        
        stdout.printf("Adding record!\n");
    }
    public void edit_record(int record_id,ref string new_record)
    {
        stdout.printf("Changing record!\n");
    }
    public void delete_record(int record_id) {
        var dis = new DataInputStream(m_log_file.read());

        string line;
        try {
            //checks to see if file has line or not. Note it only sees the first line, so not working properly
            if((line = dis.read_line(null))!=null){

                string[] vals = line.split(", ");
                
                foreach(unowned string str in vals){
                    //purely for testing purposes - Not working for final product
                    if(str != "1"){stdout.printf("'%s'\n", str);}
                    
                }

                stdout.printf ("%s\n", line);
    
            }
        } catch(Error e) {
            stderr.printf("%s\n", e.message);
        }
        
        stdout.printf("Deleted record!\n");
    }
}
