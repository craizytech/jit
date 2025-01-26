# locks the file when a process is updating that file to prevent
# race conditions and file corruption

class Lockfile
  # custom error types
  MissingParent = Class.new(StandardError)
  NoPermission = Class.new(StandardError)
  StaleLock = Class.new(StandardError)
  LockDenied = Class.new(StandardError)

  # stores the desired pathname and calculates the path for the .lock file
  def initialize(path)
    @file_path = path

    # append '.lock' to the end of the path
    @lock_path = path.sub_ext(".lock")

    @lock = nil
  end

  # this method serves to let the caller attempt to acquire a lock
  # for writing to the file and to be told whether they were successful
  # or not
  def hold_for_update
    unless @lock
      flags = File::RDWR | File::CREAT | File::EXCL
      @lock = File.open(@lock_path, flags)
    end
  rescue Errno::EEXIST
    # an error will be raised if the file already exist
    # we return False meaning another process already has control over
    # the file
    raise LockDenied, "Unable to create '#{ @lock_path }': File exists."
  rescue Errno::ENOENT => error
    # if the dir containing the file doesn't exist  we catch the error
    # and use the error class we defined to address this
    raise MissingParent, error.message
  rescue Errno::EACCES => error
    # if we dont have the permission to create the file we raise an error
    # using the Error class that we had raised
    raise NoPermission, error.message
  end


  # Both write and commit methods should raise an error if they
  # are called when @lock does not exist, this means that @lock does not
  # exist or wasn't acquired

  def write(string)
    # builds up the data to be written to the original filename, by
    # storing it in the .lock file
    raise_on_stale_lock

    @lock.write(string)
  end

  def commit
    # commit sends all the accumulated data to the final destination
    # by closing the .lock file and renaming it to the original filename
    # then discard the @lock so that no more data can be written.
    raise_on_stale_lock

    @lock.close
    File.rename(@lock_path, @file_path)
    @lock = nil
  end

  def rollback
    raise_on_stale_lock

    @lock.close
    File.unlink(@lock_path)
    @lock = nil
  end

  private

  def raise_on_stale_lock
    unless @lock
      raise StaleLock, "Not holding lock on file: #{ @lock_path }"
    end
  end
  
end

# the change is now atomic since new data is written to a temporary file
# which is then renamed and two processes cannot change the file at the
# same time
