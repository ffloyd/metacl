require 'metacl'

describe MetaCL::DSL do
  context "print_s" do
    let!(:dsl) {
      MetaCL::DSL.new :c do
        print_s 'Hello "world"!'
      end
    }

    it "should correct handle quotes and adds \\n" do
      expect(dsl.unwrapped_result).to eq('printf("Hello \"world\"!\n");')
    end
  end
end