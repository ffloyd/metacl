module MetaCL
  module Error
    class MetaCLError < StandardError; end

    {
        # matrices errors
        MatrixUnknownElementType: 'Cannot define matrix: unknown element type',
        MatrixInvalidSizeParams:  'Cannot define matrix: invalid size params',
        MatrixNameDuplication:    'Cannot define matrix: matrix with same name already exists',
        MatrixNotFound:           'Cannot find matrix with given name' # TODO: what name?
    }.each do |class_name, message|
      MetaCL::Error.const_set class_name, Class.new(MetaCLError)
      MetaCL::Error.const_get(class_name).const_set('MESSAGE', message)
      MetaCL::Error.const_get(class_name).class_eval <<CODE
        def message
          MESSAGE
        end
CODE
    end
  end
end