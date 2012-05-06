require 'date'

class Invoice

  attr_reader :invoice_number, :date, :invoice_amount, :client_number

  def initialize(data = [])
    @errors = []

    if data.empty?
      @errors << 'Empty data'
    else
      process(data)
    end
  end

  def process(invoice_detail)
    @invoice_number, @client_number, @date, @invoice_amount = invoice_detail.map( &:strip )
    validate_date
    validate_invoice_number
    validate_client_number
    validate_invoice_amount
  end

  def valid?
    @errors.empty?
  end

  def duplicated
    @errors << 'Duplicate invoice number'
  end

  def error_message(row_count = nil)
    row_count.nil? ? @errors.join(', ') : "Line #{row_count} - #{@errors.join(', ')}"
  end

  def foreign_remittance_tax
    return  !is_domestic? ? (0.05 * @invoice_amount).to_i : 0
  end

  def service_tax
    return  is_domestic? ? (0.1 * @invoice_amount).to_i : 0
  end

  def education_cess
    return  is_domestic? ? (0.03 * service_tax).round : 0
  end

  def wire_transfer_charges
    return  !is_domestic? ? 100 : 0
  end

  def is_domestic?
    @client_number[0] == "D"
  end

  private

  def validate_date
    @date = Date.strptime(@date,"%d-%m-%Y")
    rescue ArgumentError
      @errors << 'Invalid date'
  end

  def validate_client_number
     unless @client_number =~ /^(D|I)[0-9]{3}$/
       @errors << 'Client number is invalid'
     end
  end

  def validate_invoice_number
    unless @invoice_number =~ /^[0]*[1-9][0-9]*$/
     @errors << 'Invoice number invalid'
    end
  end

  def validate_invoice_amount
    unless @invoice_amount =~ /^[0]*[1-9][0-9]*$/
      @errors << 'Invoice amount is invalid'
    else
      @invoice_amount = @invoice_amount.to_i
    end
  end

end