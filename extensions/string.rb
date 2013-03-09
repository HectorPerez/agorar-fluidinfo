class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end

  def to_o
    Opinator.new(dup)
  end

  def to_st
    Statement.new(dup)
  end
end
