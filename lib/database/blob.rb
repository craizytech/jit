# Handles individual files and their contents
class Database
  class Blob
    # Makes the oid instance attribute accessible outside the class
    attr_accessor :oid

    # Constructor: data represents the file's content
    def initialize(data)
      @data = data
    end

    # Returns the type of the object (in this case, "blob")
    def type
      "blob"
    end

    # Serializes the object into a string
    def to_s
      @data
    end
  end
end
