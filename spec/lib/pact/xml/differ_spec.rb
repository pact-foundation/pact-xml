require 'pact/xml/differ'
require 'pact/xml/errors'
require 'pact/support'

include Pact::Matchers

# TODO: add rules support

module Pact
  module XML
    describe Differ do
      describe ".call" do

        let(:expected) { StringWithMatchingRules.new(
          expected_xml_string,
          pact_specification_version,
          matching_rules
        ) }
        let(:expected_xml_string) { "<xml/>" }
        let(:actual) { "<xml/>" }
        let(:pact_specification_version) { Pact::SpecificationVersion.new("3") }
        let(:matching_rules) { nil }
        let(:options) { { allow_unexpected_keys: allow_unexpected_keys } }
        let(:allow_unexpected_keys) { false }

        subject { Differ.call(expected, actual, options) }

        context "when actual is not a valid XML" do
          let(:actual) { "Actual not a XML" }

          it "throws error" do
            expect { subject }.to raise_error InvalidXmlError
            expect { subject }.to raise_error "Actual is not a valid XML"
          end
        end

        context "when expected is not a valid XML" do
          let(:expected) { "Expected not a XML" }

          it "throws error" do
            expect { subject }.to raise_error InvalidXmlError
            expect { subject }.to raise_error "Expected is not a valid XML"
          end
        end

        context "when actual is broken XML" do
          let(:actual) { "<xml" }

          it "throws error" do
            expect { subject }.to raise_error InvalidXmlError
            expect { subject }.to raise_error "Actual is not a valid XML"
          end
        end

        context "when expected is broken XML" do
          let(:expected) { "<xml" }

          it "throws error" do
            expect { subject }.to raise_error InvalidXmlError
            expect { subject }.to raise_error "Expected is not a valid XML"
          end
        end

        context "when expected is missing" do
          let(:expected) { nil }

          it { expect(subject).to be_empty }
        end

        context "when expected is empty" do
          let(:expected) { "" }

          context "when actual is empty" do
            let(:actual) { "" }

            it { expect(subject).to be_empty }
          end
          context "when actual is anything" do
            let(:actual) { "<xml/>" }

            it { expect(subject).to be_empty }
          end
        end

        context "when allow_unexpected_keys is false" do

          context "simple xml" do

            let(:expected_xml_string) { %(<tag attr="attr_val">text</tag>) }

            context "when text does not match" do
              let(:actual) { expected.gsub "text", "x"}
              it "returns diff" do
                expect(subject).to eq([Difference.new("text", "x")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected text text but got x at $.tag.#text")
              end
            end

            context "when tag does not match" do
              let(:actual) { expected.gsub "tag", "x" }
              it "returns diff" do
                expect(subject).to eq([Difference.new("tag", "x")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected element tag but got x at $.tag")
              end
            end

            context "when extra tag" do
              let(:actual) { %(<tag attr="attr_val"><another_tag/>text</tag>) }
              it "returns diff" do
                expect(subject).to eq([Difference.new(nil, "another_tag")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Did not expect element another_tag to exist at $.tag")
              end
            end

            context "when attribute value does not match" do
              let(:actual) { expected.gsub "attr_val", "x"}
              it "returns diff" do
                expect(subject).to eq([Difference.new("attr_val", "x")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected attribute attr_val but got x at $.tag.@attr")
              end
            end

            context "when missing attribute" do
              let(:actual) { %(<tag>text</tag>)  }
              it "returns diff" do
                expect(subject).to eq([Difference.new("attr_val", nil)])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected attribute attr_val but got nil at $.tag.@attr")
              end
            end

            context "when extra attribute" do
              let(:actual) { %(<tag attr="attr_val" another_attr="x">text</tag>)  }
              it "returns diff" do
                expect(subject).to eq([Difference.new(nil, "another_attr")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Did not expect attribute another_attr to exist at $.tag")
              end
            end

            context "when attribute and text mismatch" do
              let(:actual) { (expected.gsub "attr_val", "x").gsub "text", "y" }
              it "returns diff" do
                expect(subject).to eq([
                  Difference.new("attr_val", "x"),
                  Difference.new("text", "y")
                ])
              end
            end


            context "when a string match" do
              let(:actual) { expected_xml_string }

              it { expect(subject).to be_empty }
            end
          end

          context "prolog" do
            let(:expected_xml_string) { %(<?xml version="1.0" encoding="UTF-8"?><tag attr="attr_val">text</tag>) }

            context "when a string match" do
              let(:actual) { expected }

              it { expect(subject).to be_empty }
            end

            context "when missing" do
              let(:actual) { %(<tag attr="attr_val">text</tag>) }

              it { expect(subject).to be_empty }
            end

            context "when different" do
              let(:actual) { %(<?xml?><tag attr="attr_val">text</tag>) }

              it { expect(subject).to be_empty }
            end

          end

          context "nested xml" do

            let(:expected_xml_string) { %(<tag attr="attr_val"><c_tag>text</c_tag></tag>) }

            context "when text does not match" do
              let(:actual) { expected.gsub "text", "x"}
              it "returns diff" do
                expect(subject).to eq([Difference.new("text", "x")])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected text text but got x at $.tag.c_tag.#text")
              end
            end

            context "when a string match" do
              let(:actual) { expected_xml_string }

              it { expect(subject).to be_empty }
            end

            context "when extra whitespaces" do
              let(:actual) { %(<tag attr="attr_val"> <c_tag>text</c_tag> </tag>) }
              it { expect(subject).to be_empty }
            end

            context "when extra newlines" do
              let(:actual) { %(
              <tag attr="attr_val">
               <c_tag>text</c_tag>
               </tag>) }

              it { expect(subject).to be_empty }
            end

          end

          context "complex xml" do

            let(:expected_xml_string) { %(
            <root r_a="r_a_val" xmlns:x="http://www.example.com/x">
              <x:c1_t c_a="c_a_val">text_c1_1</x:c1_t>
              <c1_t>text_c1_2</c1_t>
              <c1_t>text_c1_3</c1_t>
              <c2_t>
                <c3_t>text_c3_1</c3_t>
                <c3_t>text_c3_2</c3_t>
                  <c4_t>text_c4_1</c4_t>
              </c2_t>
            </root>) }

            context "when tag does not match" do
              let(:actual) { expected.gsub "c3_t", "x" }
              it "returns diff" do
                expect(subject).to eq([
                  Difference.new("c3_t", "x"),
                  Difference.new("c3_t", "x")
                ])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected element c3_t but got x at $.root.c2_t.c3_t")
              end
            end

            context "when text does not match" do
              let(:actual) { expected.gsub "text_c3_1", "x" }
              it "returns diff" do
                expect(subject).to eq([
                  Difference.new("text_c3_1", "x")
                ])
              end
              it "returns message with path" do
                expect(subject.first.message).to eq("Expected text text_c3_1 but got x at $.root.c2_t.c3_t.#text")
              end
            end


            context "when a string match" do
              let(:actual) { expected_xml_string }

              it { expect(subject).to be_empty }
            end

          end

          context "elements" do
            let(:expected_xml_string) { %(
            <root>
              <first/>
              <second/>
              <third/>
            </root>) }

            context "wrong order" do
              let(:actual) { %(
              <root>
                <first/>
                <third/>
                <second/>
              </root>) }

              it "returns diff" do
                expect(subject).to eq([
                  Difference.new("second", "third"),
                  Difference.new("third", "second")
                ])
              end

            end
          end

        end

        context "when allow_unexpected_keys is true" do

          let(:allow_unexpected_keys) { true }

          context "simple xml" do

            let(:expected_xml_string) { %(<tag attr="attr_val">text</tag>) }

            context "when extra tag" do
              let(:actual) { %(<tag attr="attr_val"><another_tag/>text</tag>) }

              it { expect(subject).to be_empty }
            end

            context "when extra attribute" do
              let(:actual) { %(<tag attr="attr_val" another_attr="x">text</tag>)  }
              it { expect(subject).to be_empty }
            end

          end

        end

      end
    end
  end
end
