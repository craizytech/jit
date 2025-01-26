# the job of index is to manage the list of cache entries stored
# in the file .git/index  

require "digest/sha1"
require "sorted_set"
require_relative "./lockfile"
require_relative "./index/entry"
require_relative "./index/checksum"

class Index

  # pack in a 4byte string followed by 32-bit big-endian numbers
  HEADER_FORMAT = "a4N2"
  HEADER_SIZE = 12
  SIGNATURE = "DIRC"
  VERSION = 2
  ENTRY_FORMAT = "N10H40nZ*"
  ENTRY_BLOCK = 8
  ENTRY_MIN_SIZE = 64

  def initialize(pathname)
    @pathname = pathname
    @keys = SortedSet.new
    @lockfile = Lockfile.new(pathname)
    clear
  end

  # create a cache entry
  def add(pathname, oid, stat)
    entry = Entry.create(pathname, oid, stat)
    discard_conflicts(entry)
    store_entry(entry)
    @changed = true
  end

  # reads the index, handles rebuilding data before the index was last written
  def load_for_update
    @lockfile.hold_for_update
    load
  end

  def write_updates
    return @lockfile.rollback unless @changed

    writer = Checksum.new(@lockfile)

    header = [SIGNATURE, VERSION, @entries.size].pack(HEADER_FORMAT)
    writer.write(header)

    each_entry { |entry| writer.write(entry.to_s) }
    
    writer.write_checksum

    @lockfile.commit

    @changed = false
  end

  def begin_write
    @digest = Digest::SHA1.new
  end

  def write(data)
    @lockfile.write(data)
    @digest.update(data)
  end

  def finish_write
    @lockfile.write(@digest.digest)
    @lockfile.commit
  end

  def each_entry
    if block_given?
    @keys.each { |key| yield @entries[key] }
    else
      enum_for(:each_entry)
    end
  end

  def load
    clear
    file = open_index_file

    if file
      reader = Checksum.new(file)
      count = read_header(reader)
      read_entries(reader, count)
      reader.verify_checksum
    end
  ensure
    file&.close
  end

  # resets the in-memory state of the index
  def clear
    @entries = {}
    @keys = SortedSet.new
    @parents = Hash.new { |hash, key| hash[key] = Set.new}
    @changed = false
  end

  # open a file handle for the locked file so we can read from it
  def open_index_file
    File.open(@pathname, File::RDONLY)
  rescue Errno::ENOENT
    nil
  end

  def read_header(reader)
    data = reader.read(HEADER_SIZE)
    signature, version, count = data.unpack(HEADER_FORMAT)

    unless signature == SIGNATURE
      raise Invalid, "Signature: expected '#{ SIGNATURE }' but found '#{ signature }'"
    end

    unless version == VERSION
      raise Invalid, "Version: expected '#{ VERSION }' but found '#{ version }'"
    end

    count
  end

  def read_entries(reader, count)
    count.times do
      entry = reader.read(ENTRY_MIN_SIZE)

      until entry.byteslice(-1) == "\0"
        entry.concat(reader.read(ENTRY_BLOCK))
      end

      store_entry(Entry.parse(entry))
    end
  end

  def store_entry(entry)
    @keys.add(entry.key)
    @entries[entry.key] = entry

    entry.parent_directories.each do |dirname|
      @parents[dirname.to_s].add(entry.path)
    end
  end

  def discard_conflicts(entry)
    entry.parent_directories.each { |parent| remove_entry(parent)}
    remove_children(entry.path)
  end

  def remove_children(path)
    return unless @parents.has_key?(path)

    children = @parents[path].clone
    children.each { |child| remove_entry(child) }
  end

  def remove_entry(pathname)
    entry = @entries[pathname.to_s]
    return unless entry

    @keys.delete(entry.key)
    @entries.delete(entry.key)

    entry.parent_directories.each do |dirname|
      dir = dirname.to_s
      @parents[dir].delete(entry.path)
      @parents.delete(dir) if @parents[dir].empty?
    end
  end

  def release_lock
    @lockfile.rollback
  end
end

