# database class is responsible for managing the files 
# in .git/objects

require "digest/sha1"
require "zlib"

require_relative "./database/blob"
require_relative "./database/blob"
require_relative "./database/tree"
require_relative "./database/commit"
require_relative "./database/author"

class Database
  # b4 copying the contents of the compression ouput to the file
  # we copy this into a temporary file this is to prevent another 
  # process from accessing the file b4 all the output is written to file
  # TEMP_CHARS helps us generate random file names
  TEMP_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

  # constructor function takes in the path of the database
  def initialize(pathname)
    @pathname = pathname
  end

  # store the object in the database
  def store(object)
    # convert the blob to the string ouput and force it to be encoded as ascii
    # this is ruby's way of saying string represents arbitrary binary data rather
    # than text per se
    string = object.to_s.force_encoding(Encoding::ASCII_8BIT)

    # get the blob content ready for compression like how git does it;
    # and type of object+space+string_bytesize+nullbyte+string 
    content = "#{ object.type } #{ string.bytesize}\0#{ string }"

    # hash content using using SHA-1 to compute its Object ID
    # set the object ID to the attr accessor in respective classes
    object.oid = Digest::SHA1.hexdigest(content)
    
    # write the content to file using write_object method
    write_object(object.oid, content)
  end

  # private - all the methods defined after this are private to the class
  private

  # method compresses and writes the content of the blob to the database
  def write_object(oid, content)
    # Builds object path the final destination path that the blob will
    # be written to by combining the path to the .git/objects fir, the
    # first two chars of the object ID, and the remaining characters

    object_path = @pathname.join(oid[0..1], oid[2..-1])

    # check if object exists before proceeding, if it does return there
    # is no need to write if the file already exists
    return if File.exists?(object_path)


    # .dirname() returns all but the last component of the path
    dirname = object_path.dirname

    # using the dirname create a temporary file to store the compressed
    # contents temporarily
    temp_path = dirname.join(generate_temp_name)

    # create the temp file to store the content with the r,w,e flags
    begin
      flags = File::RDWR | File::CREAT | File::EXCL
      file = File.open(temp_path, flags)
    rescue Errno::ENOENT
      # incase an error is raised because the dir does not exist
      # create the directory and attempt to open again
      Dir.mkdir(dirname)
      file = File.open(temp_path, flags)
    end

    # compress the contents of the blob using the Zlib module
    compressed = Zlib::Deflate.deflate(content, Zlib::BEST_SPEED)

    # write the file to the temp_file_location fully first & close the file
    file.write(compressed)
    file.close

    # rename the temporary file to the correct file name of the object
    File.rename(temp_path, object_path)
  end

  # used to generate the temporary file names
  def generate_temp_name
    "tmp_obj_#{ (1..6).map { TEMP_CHARS.sample }.join("") }"
  end


end
