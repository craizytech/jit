# implementing the parent chain
# ref helps us update the .git/HEAD file

require_relative "../lib/lockfile.rb"


class Refs

  # custom errors
  LockDenied = Class.new(StandardError)

  def initialize(pathname)
    @pathname = pathname
  end

  # update the value stored at head with the latest commit
  def update_head(oid)
    lockfile = Lockfile.new(head_path)

    lockfile.hold_for_update
    lockfile.write(oid)
    lockfile.write("\n")
    lockfile.commit
  end

  # reading the value stored at head, if head actually exists
  def read_head
    if File.exists?(head_path)
      File.read(head_path).strip
    end
  end

  private

  def head_path
    @pathname.join("HEAD")
  end
end
