require_relative 'lib/command_line_interface.rb'

if( !(file = ARGV.first).empty? && File.exist?(file))

list = CommandLineInterface.new(file)
  unless list.error_count > 0
    list.aggregated_stats
    list.get_user_input
  end
else
  puts "Oh noes, the file #{file} is either empty or it does not exist "
end
