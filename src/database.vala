public class Database : GLib.Object
{
    private FileStream m_log_file;
    
    public Database(){
        //load an initial hardcoded file here, will add checks and stuff later
        //for now we assume there's no existing file, if there is we delete and start from scratch
    stdout.printf("Loading log file...\n");
       //using gio's File to first check if ../data exists and then
       //../data/log and then finally if testLog exists
       //then when it does open it
       //if not
                //create the dirs that don't exist with GIO
                //create the log file with FileStream.open("<filepath>",O_RW);
       //assuming it exists for now and we're appending to it

     m_log_file = FileStream.open("../data/logs/testLog","a");
    }

    /* SPRINT 1 FUNCTIONALITY GOES HERE (i guess) */
    public void add_record(ref string rec_to_add)
    {
        //for testing purposes - adding a line to the file
        m_log_file.puts(rec_to_add);
        stdout.printf("Adding record!\n");
    }
    public void edit_record(int record_id,ref string new_record)
    {
        stdout.printf("Changing record!\n");
    }
    public void delete_record(int record_id) {
        string line;
        try {
            //checks to see if file has line or not. Note it only sees the first line, so not working properly
            if((line = m_log_file.read_line())!=null){

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
