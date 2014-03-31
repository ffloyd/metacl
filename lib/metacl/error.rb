module MetaCL
  module Error
    class MetaCLError < StandardError; end

    {
        # matrices errors
        MatrixUnknownElementType: 'Cannot define matrix: unknown element type',
        MatrixInvalidSizeParams:  'Cannot define matrix: invalid size params',
        MatrixNameDuplication:    'Cannot define matrix: matrix with same name already exists',
        MatrixNotFound:           'Cannot find matrix with given name'
    }.each do |class_name, message|
      Object.const_set(class_name, Class.new(MetaCLError) do
        def message
          MESSAGE
        end
      end).const_set('MESSAGE', message)
    end
  end
end