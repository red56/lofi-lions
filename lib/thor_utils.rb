module ThorUtils
  protected
  def io_from_filename(filename, &io_block)
    if filename == "-"
      if io_block
        io_block.call($stdin)
      else
        return $stdin
      end
    else
      if io_block
        open(filename, "rb", &io_block)
      else
        return open(filename, "rb")
      end
    end
  end

  def self.exit_on_failure?
    true
  end

end