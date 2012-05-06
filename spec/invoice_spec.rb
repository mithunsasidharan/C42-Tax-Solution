require './lib/invoice.rb'

describe Invoice, "#error_message" do
  before(:each) do
    @invoice = ['1', 'D111', '10-10-2010', '1000']
  end

  describe 'valid' do
    it 'should be valid' do
      invoice = Invoice.new @invoice
      invoice.should be_valid
    end
  end

  describe 'invalid' do
    it 'should be invalid' do
      invoice = Invoice.new @invoice.map! { 'invalid' }
      invoice.should_not be_valid
    end

    it "should show all validation errors" do
      invoice = Invoice.new @invoice.map! { 'invalid' }
      invoice.error_message.split(',').length.should == 4
    end

    describe 'invoice number' do
      it "should show invoice number error" do
        @invoice[0] = 'invalid'
        invoice = Invoice.new @invoice
        invoice.error_message.should == 'Invoice number invalid'
      end

      it 'should not be valid if is not a natural number' do
        @invoice[0] = '1.1'
        invoice = Invoice.new @invoice
        invoice.should_not be_valid

        @invoice[0] = '0'
        invoice = Invoice.new @invoice
        invoice.should_not be_valid
      end
    end

    it "should show client number error" do
      @invoice[1] = 'invalid'
      invoice = Invoice.new @invoice
      invoice.error_message.should == 'Client number is invalid'
    end

    it "should show date error" do
      @invoice[2] = 'invalid'
      invoice = Invoice.new @invoice
      invoice.error_message.should == 'Invalid date'
    end

    it "should show date error" do
      @invoice[3] = 'invalid'
      invoice = Invoice.new @invoice
      invoice.error_message.should == 'Invoice amount is invalid'
    end
  end
end
