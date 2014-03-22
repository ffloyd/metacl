require 'metacl'

describe MetaCL::DSL::Main do
  context "print_s" do
    let!(:code) do
      MetaCL::Program.create do
        configure do
          lang :c
        end

        print_s 'Hello "world"!'
      end
    end

    it "should correct handle quotes and adds \\n" do
      expect(code).to include 'printf("Hello \"world\"!\n");'
    end
  end
end