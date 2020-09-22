public class Database : GLib.Object
{
    private FileStream m_log_file;
    private File m_logs_dir_checker;
    private File m_export_dir_checker;
    public Database(){
        //load an initial hardcoded file here, will add checks and stuff later
        //for now we assume there's no existing file, if there is we delete and start from scratch
    stdout.printf("Loading log file...\n");
    m_logs_dir_checker = File.new_for_path("../data/logs/");
    m_export_dir_checker = File.new_for_path("../data/export/");
    if(!m_logs_dir_checker.query_exists())
    {
        //"../data/logs" dir doesn't exist so create it with its parents
        stdout.printf("[../data/logs] doesn't exist. Creating now!\n");
        m_logs_dir_checker.make_directory_with_parents();
    }
    if(!m_export_dir_checker.query_exists())
    {
        //"../data/logs" dir doesn't exist so create it with its parents
        stdout.printf("[../data/export] doesn't exist. Creating now!\n");
        m_export_dir_checker.make_directory_with_parents();
    }
    //here we're pretty sure the dirs exist
    stdout.printf("All directories are present. Opening latest log file!\n");
    m_log_file = FileStream.open("../data/logs/testLog","a+");

       //using gio's File to first check if ../data exists and then
       //../data/log and then finally open it with open(,"a") which will create it if it doesn't exist, otherwise append
       //then when it does open it
       //if not
                //create the dirs that don't exist with GIO
                //create the log file with FileStream.open("<filepath>",O_RW);
       //assuming it exists for now and we're appending to it

     //check the ID of the last transaction and update internal id
    }

    /* SPRINT 1 FUNCTIONALITY GOES HERE (i guess) */
    public void add_record(ref string rec_to_add)
    {
        //for testing purposes - adding a line to the file
        m_log_file.puts(rec_to_add);
        stdout.printf("Adding record!\n");
    }

    //For Add Record - prepend id to string
    public int find_last_record_id()
    {
        string? line = null;
        int id = 0;

        while ((line = m_log_file.read_line())!= null) {
            id = line.get_char().digit_value();
        }

        return id;
        
    }

    public void edit_record(ref int record_id,ref string new_record)
    {
        int id = 0;
        string? line = null;


        while (id != record_id){
            line = null; 
            line = m_log_file.read_line();          
            id++;
        }

        //test output of current line
        stdout.printf(line);

        stdout.printf("\nChanging record!\n");
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
}
