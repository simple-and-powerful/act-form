module FormModel
  class Utils
    class << self
      def merge(a_validators, b_validators)
        b_validators.each do |k, v|
          a_validators[k] ? (a_validators[k] += v) : (a_validators[k] = v)
        end
      end # merge
    end
  end
end
