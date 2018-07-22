# frozen_string_literal: true

require 'pact/xml/errors'
require 'pact/matchers'
require 'rexml/document'

module Pact
  module XML
    # Diffs two XML strings
    class Differ
      include REXML
      include Pact::Matchers

      DEFAULT_OPTIONS = { allow_unexpected_keys: true, type: false }.freeze

      def self.validate_xml(doc, type)
        raise InvalidXmlError, "#{type} is not a valid XML" if doc.root.nil?
      end

      def self.validate_xmls(expected_doc, actual_doc)
        validate_xml expected_doc, 'Expected'
        validate_xml actual_doc, 'Actual'
      end

      def self.parse(xml, type)
        Document.new(xml, ignore_whitespace_nodes: :all)
      rescue REXML::ParseException
        raise InvalidXmlError, "#{type} is not a valid XML"
      end

      def self.call(expected, actual, options = {})
        return [] if expected.to_s.empty?

        expected_doc = parse expected, 'Expected'
        actual_doc = parse actual, 'Actual'

        validate_xmls expected_doc, actual_doc

        node_diff(
          expected_doc,
          actual_doc,
          ['$'],
          DEFAULT_OPTIONS.merge(options)
        )
      end

      def self.path_to_s(path)
        path.join '.'
      end

      def self.get_attr_by_name(name, element)
        element.attributes.get_attribute(name)&.value
      end

      def self.attr_diff(expected, actual, path, options)
        diff = []
        expected.attributes.each_attribute do |a|
          diff.concat(
            difference(
              get_attr_by_name(a.name, expected),
              get_attr_by_name(a.name, actual),
              'attribute',
              path,
              ".@#{a.name}"
            )
          )
        end
        unless options[:allow_unexpected_keys]
          diff.concat(
            extra_attrs(expected, actual, path)
          )
        end
        diff
      end

      def self.extra_attrs(expected, actual, path)
        diff = []
        actual.attributes.each_attribute do |a|
          diff.push a.name if (get_attr_by_name a.name, expected).nil?
        end

        diff.map do |x|
          Difference.new(
            nil,
            x,
            "Did not expect attribute #{x} to exist at #{path_to_s path}"
          )
        end
      end

      def self.elem_diff(expected, actual, path, options)
        diff = []
        expected.each_index do |i|
          i_next = i + 1
          expected_next = expected.elements[i_next]
          actual_next = actual.elements[i_next]
          diff.concat(
            node_diff(
              expected_next,
              actual_next,
              [*path, expected_next&.name],
              options
            )
          )
        end
        unless options[:allow_unexpected_keys]
          diff.concat(
            extra_elems(expected, actual, path)
          )
        end
        diff
      end

      def self.extra_elems(expected, actual, path)
        actual.elements.drop(expected.elements.size).map do |x|
          Difference.new(
            nil,
            x.name,
            "Did not expect element #{x.name} to exist at #{path_to_s path}"
          )
        end
      end

      def self.nil_if_nil(obj)
        obj.nil? ? 'nil' : obj
      end

      def self.difference(expected, actual, type, path, suffix)
        return [] if expected == actual
        [Difference.new(
          expected,
          actual,
          "Expected #{type} #{nil_if_nil expected} " \
          "but got #{nil_if_nil actual} " \
          "at #{path_to_s path}#{suffix}"
        )]
      end

      def self.node_diff(expected, actual, path, options)
        return [] if expected.nil?

        diff = difference expected.name, actual.name, 'element', path, ''
        return diff if diff.any?

        diff.concat(
          attr_diff(expected, actual, path, options)
        )
        diff.concat(
          elem_diff(expected, actual, path, options)
        )
        diff.concat(
          difference(expected.text, actual.text, 'text', path, '.#text')
        )
      end
    end
  end
end
