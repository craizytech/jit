# Handles the Tree object operations within the Database namespace

require_relative "../entry"

class Database
  class Tree
    # Defines the binary format for encoding tree entries:
    # - "Z*" : Null-padded string for "#{MODE} #{entry.name}"
    # - "H40": 40-character hexadecimal object ID (OID), packed as raw bytes
    ENTRY_FORMAT = "Z*H40"
    TREE_MODE = 040000

    # Makes the oid instance attribute accessible outside the class
    attr_accessor :oid

    # Constructor: Initializes an empty hash to store tree entries
    def initialize
      @entries = {}
    end

    # Returns the type of the object (in this case, "tree")
    def type
      "tree"
    end

    # Serializes the tree object into a binary format for storage
    # Each entry is formatted as "#{MODE} #{name}" + packed OID
    def to_s
      entries = @entries.map do |name, entry|
        mode = entry.mode.to_s(8)
        ["#{ mode } #{ name }", entry.oid].pack(ENTRY_FORMAT)
      end

      # Return the concatenated binary representation of all entries
      entries.join("")
    end

    # Class method to build a Tree object from a list of entries
    def self.build(entries)
      # Sort entries by name for consistent ordering
      entries.sort_by { |entry| entry.path.to_s }

      # Create the root Tree object
      root = Tree.new

      # Add each entry to the appropriate position in the tree
      entries.each do |entry|
        root.add_entry(entry.parent_directories, entry)
      end

      root
    end

    # Adds an entry to the tree, handling nested directories
    # - `parents`: List of parent directories (empty for files in root)
    # - `entry`: The entry (file or directory) to be added
    def add_entry(parents, entry)
      if parents.empty?
        # Directly store the entry if there are no parent directories
        @entries[entry.basename] = entry
      else
        # Retrieve or create a subtree for the first parent directory
        tree = @entries[parents.first.basename] ||= Tree.new

        # Recursively add the entry to the correct subtree
        tree.add_entry(parents.drop(1), entry)
      end
    end

    # Recursively traverses the tree and applies a given block to each node
    def traverse(&block)
      @entries.each do |name, entry|
        entry.traverse(&block) if entry.is_a?(Tree)
      end
      block.call(self)
    end

    # Returns the mode used for directories in Git trees
    def mode
      TREE_MODE
    end
  end
end
