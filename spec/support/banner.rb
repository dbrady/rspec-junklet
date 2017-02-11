def banner(*objects, &_block)
  puts '-' * 80
  if !objects.empty?
    objects.each do |object|
      puts object
    end
  end
  yield if block_given?
  puts '-' * 80
end
