# frozen_string_literal: true

require 'spec_helper'
require 'term/ansicolor'
require 'pact/xml/diff_formatter'

module Pact
  module XML
    describe DiffFormatter do
      let(:diff) do
        {
          body:
          [
            Difference.new('a', 'b', 'Expected a but got b'),
            Difference.new('x', 'y', 'Expected x but got y')
          ]
        }
      end

      subject { DiffFormatter.call(diff, options) }

      let(:colour) { false }
      let(:options) { { colour: colour } }

      let(:expected_coloured) do
        "EXPECTED : #{::Term::ANSIColor.red('a')}"
      end
      let(:actual_coloured) do
        "ACTUAL   : #{::Term::ANSIColor.green('b')}"
      end

      describe '.call' do
        context 'when no diffs' do
          let(:diff) { {} }

          it { expect(subject).to be_empty }
        end

        context 'when diffs' do
          it { expect(subject.split("\n").size).to eq 6 }
        end

        context 'when color_enabled is true' do
          let(:colour) { true }

          it 'formats the diff nicely with color' do
            expect(subject).to include expected_coloured
            expect(subject).to include actual_coloured
          end
        end

        context 'when color_enabled is false' do
          let(:colour) { false }

          it 'formats the diff nicely without color' do
            expect(subject).to_not include expected_coloured
            expect(subject).to_not include actual_coloured
          end
        end
      end
    end
  end
end
