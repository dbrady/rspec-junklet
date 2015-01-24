class Line < String
  def initialize(line="")
    super
  end
  
  def indent
    ' ' * (size - lstrip.size)
  end
  
  def let?
    match(/^\s*let\s*\(/) && !junklet?
  end
  
  def junklet?
     already_junklet? || secure_random?
  end

  def already_junklet?
    match(/^\s*junklet\b/)
  end
  
  def secure_random?
    match(/^\s*(let)\s*\(?([^)]*)\)\s*{\s*SecureRandom.uuid\s*}?/)
  end
  
  def code?
    empty? || (!let? && !junklet?)
  end

  def names
    return nil unless let? || junklet?
    match(/^\s*(let|junklet)\s*\(?([^)]*)\)?/) \
      .captures[1..-1] \
      .join('') \
      .split(/,/) \
      .map(&:strip)
  end

  def convert
    return nil unless junklet?
    return self if already_junklet?
    Line.new("#{indent}junklet #{names.first}")
  end
end
