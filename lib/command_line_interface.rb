require 'csv'
require 'pp'
require 'date'
require 'readline'

require_relative '../lib/invoice.rb'

class CommandLineInterface

attr_reader :error_count

def initialize(file)
  row_count = 0
  invoice_numbers = []
  @error_count = 0
  @invoice_list = []
  CSV.foreach(file) do |record|
    row_count += 1
    invoice = Invoice.new(record)
    invoice.duplicated if invoice_numbers.include? invoice.invoice_number
    unless invoice.valid?
      @error_count += 1
      puts invoice.error_message(row_count)
    end
    invoice_numbers << invoice.invoice_number
    @invoice_list << invoice
  end
end

def invoice_amount(array_list = @invoice_list)
  array_list.map(&:invoice_amount).inject(:+)
end

def service_tax(array_list = @invoice_list)
  array_list.map(&:service_tax).inject(:+)
end

def education_cess(array_list = @invoice_list)
  array_list.map(&:education_cess).inject(:+)
end

def foreign_remittance_tax(array_list = @invoice_list)
  array_list.map(&:foreign_remittance_tax).inject(:+)
end

def wire_transfer_charges(array_list = @invoice_list)
  array_list.map(&:wire_transfer_charges).inject(:+)
end

def display_month_and_year(array_list = @invoice_list)
"#{array_list[0].date.month}-#{array_list[0].date.year}"
end

def total_details
  puts "Total  |  #{invoice_amount}  |  #{service_tax}  |  #{education_cess}  |  #{foreign_remittance_tax}  |  #{wire_transfer_charges}"
end

def aggregated_stats
  puts "Month   |   Total Invoice Amount   |  ST  |   EC   |  FRT  |  WTC"
  store = @invoice_list.group_by{ |object| "#{object.date.month} - #{object.date.year}" }
  store.each_value do |list|
    print [display_month_and_year(list),
    invoice_amount(list),
    service_tax(list),
    education_cess(list),
    foreign_remittance_tax(list),
    wire_transfer_charges(list)].join("   |   ")
    puts ""
  end
  total_details
end

def get_user_input
  puts "Please enter either of the following commands (mm-yyyy/ aggregated/ exit )"
  user_input = Readline.readline
  process_user_input(user_input)
end

def date_validator(user_input)
  return Date.strptime(user_input, "%m-%Y") 
  rescue ArgumentError 
  return false
end

def month_based_list(user_input)
  user_input = Date.strptime(user_input, "%m-%Y") 
  @invoice_list.find_all { |invoice| invoice.date.month == user_input.month && invoice.date.year == user_input.year }.group_by(&:client_number).each {|key,value|
      puts [key,
    invoice_amount(value),
    service_tax(value),
    education_cess(value),
    foreign_remittance_tax(value),
    wire_transfer_charges(value)].join("   |   ")
}
get_user_input
end

def process_user_input(user_input)
  if user_input.casecmp("AGGREGATED") == 0
    aggregated_stats
    get_user_input
  elsif user_input.casecmp("EXIT") == 0
    abort("Good Bye")
  elsif date_validator(user_input) 
    month_based_list(user_input)
  else
    get_user_input
  end
end

end