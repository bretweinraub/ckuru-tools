module CkuruTools
  # A typed Array guarantees that all elements of an array conform to a certain signature
  #
  # Instantion requires that the first argument be the type:
  #
  #  new = CkuruTools::TypedArray.new(AuraVisualize::SqlConstruct,
  #                                   AuraVisualize::SelectConstruct.new(:name => "1"),
  #                                   AuraVisualize::SelectConstruct.new(:name => "2"))
  class TypedArray < Array
    # required
    attr_accessor :required_type
    
    def validate
      self.each do |e|
        raise ArgumentError.new("all elements of this Array must be of type #{required_type}, not #{e.class}") unless e.is_a? required_type
      end
    end

    def <<(val)
      super
      validate
    end

    def push(val)
      super
      validate
    end

    def initialize(*args)
      args.reverse!
      @required_type = args.pop
      args.reverse!
      raise ArgumentError.new("argument must be a class not #{required_type.class}") unless required_type.is_a? Class
      @required_type = required_type
      super(args)
      validate
    end
  end
end
