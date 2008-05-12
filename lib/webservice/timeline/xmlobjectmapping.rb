require 'date'
require 'rexml/document'

module WebService #:nodoc:
module TimeLine #:nodoc:

module XmlObjectMapping #:nodoc:
  def XmlObjectMapping.included(base)
    base.extend ClassMethods
  end

  module ClassMethods #:nodoc:
    def attr_mapping(name, args = {})
      unless args[:private]
        attr_accessor name
      end

      mapping = {
        :name => name,
        :type => args[:type] || :string,
        :array => args[:array] || false,
        :subnode => args[:subnode],
      }
      path = args[:path] || name.to_s

      @attributes ||= {}
      @attributes[path] = mapping
    end

    def attr_array(name, args = {})
      attr_mapping(name, args.merge(:array => true))
    end
  end

  class Base #:nodoc:
    include XmlObjectMapping

    def self.unmarshal(xml)
      self.new.__send__ :populate, xml
    end


    private

    def populate(xml)
      attributes = collect_mappings(self.class)

      xml.elements.each do |node|
        name = node.name
        mapping = attributes[name]
        next unless mapping
        array = mapping[:array]

        value = array ? get_attribute_array(node, mapping) : get_attribute_value(node, mapping)
        instance_variable_set("@#{mapping[:name]}", value)
      end

      post_population
      self
    end

    def collect_mappings(clazz)
      if clazz == Base
        {}
      else
        base_mappings = collect_mappings(clazz.superclass)
        self_mappings = clazz.class_eval { @attributes } || {}
        base_mappings.merge(self_mappings)
      end
    end

    def post_population
    end

    def get_attribute_array(node, mapping)
      list = []
      m = mapping.dup
      subnode = m.delete :subnode
      node.elements.each(subnode) do |e|
        list << get_attribute_value(e, m)
      end
      list
    end

    def get_attribute_value(node, mapping)
      type = mapping[:type]
      str = node.text
      case type
      when :string
        str
      when :integer
        str.to_i
      when :date
        Date.parse(str)
      when :datetime
        DateTime.parse(str)
      else
        subnode = mapping[:subnode]
        if subnode
          nodes = node.get_elements(subnode)
          nodes.empty? ? nil : type.unmarshal(nodes[0])
        else
          type.unmarshal(node)
        end
      end
    end

  end
end

end
end
