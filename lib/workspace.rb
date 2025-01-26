# workspace class is responsible for the files in the working tree
# all the files you can edit directly, rather than those stored in git

class Workspace

  # custom errors
  MissingFile = Class.new(StandardError)
  NoPermission = Class.new(StandardError)

  # list the things we'll need to ignore when listing files
  IGNORE = [".", "..", ".git"]

  # This is the constructor object
  def initialize(pathname)
    @pathname = pathname
  end

  # list all files in the current working space
  def list_files(path = @pathname)
    relative = path.relative_path_from(@pathname)

    if File.directory?(path)
      filenames = Dir.entries(path) - IGNORE
      filenames.flat_map { |name| list_files(path.join(name)) }
    elsif File.exists?(path)
      [relative]
    else
      raise MissingFile, "pathspec '#{ relative }' did not match any files"
    end
  end

  # Read the content of the file at path
  def read_file(path)
    File.read(@pathname.join(path))
  rescue Errno::EACCES
    raise NoPermission, "open('#{ path }'): Permission denied"
  end

  # get the file stat of a file
  def stat_file(path)
    File.stat(@pathname.join(path))
  rescue Errno::EACCES
    raise NoPermission, "stat('#{ path }'): Permission denied"
  end

end



  