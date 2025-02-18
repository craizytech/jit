# Entry is a simple structure that exists to package up the info
# that a tree needs to know about its contents: the filename, and the
# Object ID

class Entry
  attr_reader :name, :oid

  REGULAR_MODE = "100644"
  EXECUTABLE_MODE = "100755"
  DIRECTORY_MODE = "40000"

  def initialize(name, oid, stat)
    @name = name
    @oid = oid
    @stat = stat
  end

  def mode
    @stat.executable? ? EXECUTABLE_MODE : REGULAR_MODE
  end

  def parent_directories
    # returns all the parent directories of the entry's name in desc order
    @name.descend.to_a[0..-2]
  end

  def basename
    @name.basename
  end

end
