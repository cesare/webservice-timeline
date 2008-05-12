module WebService #:nodoc:
  module TimeLine #:nodoc:
    module Version #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 2

      STRING = [MAJOR, MINOR, TINY].join('.')
      NAME   = [MAJOR, MINOR, TINY].join('_')

      class << self
        def to_version
          STRING
        end

        def to_name
          NAME
        end
      end
    end
  end
end
