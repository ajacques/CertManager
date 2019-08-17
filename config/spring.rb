Spring.after_fork do
  ENV['DEBUGGER_STORED_RUBYLIB']&.split(File::PATH_SEPARATOR)&.each do |path|
    next unless path =~ /ruby-debug-ide/

    load path + '/ruby-debug-ide/multiprocess/starter.rb'
  end
end
