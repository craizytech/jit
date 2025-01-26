require "digest/sha1"

class Index
  # The Checksum class provides checksum verification and integrity checks
  # for a given file using the SHA-1 hashing algorithm. It ensures data consistency
  # by calculating and verifying checksums while reading and writing.
  class Checksum

    # Raised when the file reaches an unexpected end while reading.
    EndOfFile = Class.new(StandardError)

    # The fixed size of the SHA-1 checksum in bytes.
    CHECKSUM_SIZE = 20

    # Initializes a Checksum object.
    #
    # @param file [IO] The file object to be processed.
    def initialize(file)
      @file = file
      @digest = Digest::SHA1.new
    end

    # Reads a specified number of bytes from the file and updates the SHA-1 digest.
    #
    # @param size [Integer] The number of bytes to read.
    # @raise [EndOfFile] if the file does not contain the expected number of bytes.
    # @return [String] The data read from the file.
    def read(size)
      data = @file.read(size)

      unless data.bytesize == size
        raise EndOfFile, "Unexpected end-of-file while reading index"
      end

      @digest.update(data)
      data
    end

    # Verifies that the stored checksum in the file matches the computed checksum.
    #
    # @raise [Invalid] if the computed checksum does not match the stored checksum.
    def verify_checksum
      sum = @file.read(CHECKSUM_SIZE)

      unless sum == @digest.digest
        raise Invalid, "Checksum does not match value stored on disk"
      end
    end

    # Writes data to the file and updates the checksum.
    #
    # @param data [String] The data to be written.
    def write(data)
      @file.write(data)
      @digest.update(data)
    end

    # Writes the computed SHA-1 checksum to the file.
    def write_checksum
      @file.write(@digest.digest)
    end
  end
end
