module Loris
  private
    def self.accessor(name, value = nil)
      module_eval "@@#{name} = #{value.inspect};
        def self.#{name}; @@#{name}; end;
        def self.#{name}=(value); @@#{name} = value; end;"
    end
end
