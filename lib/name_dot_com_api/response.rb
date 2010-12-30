require 'json'

module NameDotComApi
  class Response < Hash

    def initialize(json)
      self.update JSON.parse(json)
    end

    module EigenMethodDefiner # :nodoc:
      def method_missing(name, *args, &block)
        if key?(name.to_s)
          define_eigen_method(name.to_s)
          value = self[name.to_s]
          value.extend(EigenMethodDefiner) if value.is_a?(Hash)
          value
        else
          super
        end
      end

    private

      def define_eigen_method(name)
        eigen_class = class << self; self; end
        eigen_class.send(:define_method, name){ self[name] }
      end

    end

    include EigenMethodDefiner

  end
end