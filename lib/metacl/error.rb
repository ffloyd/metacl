module MetaCL
  module Error
    class MetaCLError < StandardError; end

    {
        # vars errors
        VarNameDuplication:       'Cannot define variable: variable with same name already exists',
        VarUnknownType:           'Cannot define variable: unknown element type',
        VarNotFound:              'Cannot find matrix with given name',

        # matrices errors
        MatrixUnknownElementType: 'Cannot define matrix: unknown element type',
        MatrixInvalidSizeParams:  'Cannot define matrix: invalid size params',
        MatrixNameDuplication:    'Cannot define matrix: matrix with same name already exists',
        MatrixNotFound:           'Cannot find matrix with given name', # TODO: what name?
        MatrixMismatchSizes:      'Mismatch sizes of matrices',
        MatrixMismatchTypes:      'Mismatch types of matrices',
        UnknownOperator:          'Unknown operator',

        InvalidBorders:           'Borders are out of matrix size',

        # partials errors
        PartialNameDuplication:   'Cannot define partial: partial with same name already exists',
        PartialNotFound:          'Cannot find partial with given name'
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