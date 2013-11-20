class MassObject
  def self.my_attr_accessible(*attributes)
    @attributes = attributes

    attributes.each do |attribute|
      new_attr_accessor attribute
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    params.each do |key, value|
      if self.class.attributes.include?(key.to_sym)
        attribute = key.to_s + "="
        self.send(attribute.to_sym, value)
      else
        raise "mass assignment to unregistered attribute #{key}"
      end
    end
  end
end

class Object
  def self.new_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}")
      end
      define_method("#{attribute}=") do |value|
        instance_variable_set("@#{attribute}", value)
      end
    end
  end
end