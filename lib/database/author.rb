# Defines the Author structure within the Database namespace.
# The Author object represents the metadata for commit authors and committers,
# including their name, email, and timestamp.

class Database
  Author = Struct.new(:name, :email, :time) do
    # Converts the Author object into a formatted string representation
    # that follows Git's author and committer header format.
    #
    # Format:
    #   "Name <email> timestamp timezone_offset"
    #
    # - "%s" extracts the UNIX timestamp (seconds since epoch)
    # - "%z" provides the timezone offset from UTC (e.g., +0300)
    def to_s
      timestamp = time.strftime("%s %z")
      "#{name} <#{email}> #{timestamp}"
    end
  end
end
