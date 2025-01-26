# Handles the Commit object operations within the Database namespace

class Database
  class Commit
    # Makes the oid instance attribute accessible outside the class
    attr_accessor :oid

    # Constructor
    # - parent: The parent commit (if any, for tracking commit history)
    # - tree: The root tree object representing the snapshot of the project
    # - author: The author information (name, email, timestamp)
    # - message: The commit message describing the changes
    def initialize(parent, tree, author, message)
      @parent = parent
      @tree = tree
      @author = author
      @message = message
    end

    # Returns the type of the object (in this case, "commit")
    def type
      "commit"
    end

    # Serializes the commit object into a string format
    # This format follows a simple Git-like structure
    def to_s
      lines = []

      # The commit points to a tree (root directory snapshot)
      lines.push("tree #{@tree}")

      # If there is a parent commit, store its reference
      lines.push("parent #{@parent}") if @parent

      # Author information
      lines.push("author #{@author}")
      lines.push("committer #{@author}") # In Git, author and committer can be different

      # Add an empty line before the commit message
      lines.push("")
      lines.push(@message)

      # Join all lines into a single formatted string
      lines.join("\n")
    end
  end
end
