require 'rexml/document'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

module TestHelper
  def parse_xml(filename)
    xml_source = load_xml(filename)
    REXML::Document.new(xml_source)
  end

  def load_xml(filename)
    IO.read(File.join(File.dirname(__FILE__), filename))
  end
end
