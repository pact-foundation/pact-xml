require 'pact/xml/differ'
require 'pact/support'

module Pact
  module XML
    describe Differ do
      describe ".call" do

        let(:expected) { StringWithMatchingRules.new(expected_xml_string, pact_specification_version, matching_rules) }
        let(:pact_specification_version) { Pact::SpecificationVersion.new("2") }
        let(:expected_xml_string) { "" }
        let(:matching_rules) do
          {

          }
        end
        let(:options) { { allow_unexpected_keys: allow_unexpected_keys } }
        let(:allow_unexpected_keys) { false }

        subject { Differ.call(expected, actual, options) }

        context "when allow_unexpected_keys is false" do
          let(:actual) { "" }

          it "returns the diff between two XML documents" do
            pending "to do"
            expect(subject).to_not be nil
          end
        end

        context "when allow_unexpected_keys is true" do

        end
      end
    end
  end
end
