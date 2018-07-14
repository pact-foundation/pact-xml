require 'pact/matchers'
require 'rexml/document'

include REXML
include Pact::Matchers

module Pact
  module XML

    class Differ

      DEFAULT_OPTIONS = {allow_unexpected_keys: true, type: false}.freeze

      def self.valid_xml expected, actual, doc, type
        doc.root.nil? ? [Difference.new(expected, actual, "#{type} is not a valid XML")] : []
      end

      def self.valid_xmls expected, actual, expected_doc, actual_doc
        []
          .concat ( valid_xml expected, actual, expected_doc, 'Expected' )
          .concat ( valid_xml expected, actual, actual_doc, 'Actual' )
      end

      def self.call expected, actual, options = {}
        expected_doc = (Document.new expected)
        actual_doc = (Document.new actual)

        diff = valid_xmls expected, actual, expected_doc, actual_doc
        return diff if diff.any?

        node_diff expected_doc, actual_doc, DEFAULT_OPTIONS.merge(options)
      end

      def self.get_attr_by_name n, e
        e.attributes.get_attribute(n)&.value
      end

      def self.attr_diff expected, actual, options
        diff = []
        expected.attributes.each_attribute { |a|
          diff.concat (
            difference get_attr_by_name(a.name, expected), get_attr_by_name(a.name, actual), 'Attribute'
          )
        }
        diff.concat ( extra_attrs expected, actual ) unless options[:allow_unexpected_keys]
        diff
      end

      def self.extra_attrs expected, actual
        diff = []
        actual.attributes.each_attribute { |a|
          diff.push a.name if (get_attr_by_name a.name, expected).nil?
        }

        diff.map { |x| Difference.new(nil, x, "Did not expect Attribute #{x} to exist") }
      end

      def self.elem_diff expected, actual, options
        diff = []
        expected.each_index { |i|
          diff.concat (
            node_diff expected.elements[i+1], actual.elements[i+1], options
          )
        }
        diff.concat ( extra_elems expected, actual ) unless options[:allow_unexpected_keys]
        diff
      end

      def self.extra_elems expected, actual
        actual.elements.drop(expected.elements.size).map { |x|
          Difference.new(nil, x.name,  "Did not expect Element #{x} to exist")
        }
      end

      def self.difference expected, actual, type
        expected == actual ? [] : [Difference.new(expected, actual, "Expected #{type} #{expected} but got #{actual}")]
      end

      def self.node_diff expected, actual, options
        if expected.nil?
          return []
        end

        diff = difference expected.name, actual.name, 'Element'
        return diff if diff.any?

        diff.concat ( attr_diff expected, actual, options)
        diff.concat ( elem_diff expected, actual, options)
        diff.concat ( difference expected.text, actual.text, 'Text' )
      end

    end

  end
end
