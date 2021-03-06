require 'test_helper'

module Spinach
  class Parser
    describe Visitor do
      let(:feature) { Feature.new }
      let(:visitor) { Visitor.new }

      describe '#visit' do
        it 'makes ast accept self' do
          ast = stub('AST')
          ast.expects(:accept).with(visitor)

          visitor.visit(ast)
        end

        it 'returns the feature' do
          ast = stub_everything
          visitor.instance_variable_set(:@feature, feature)
          visitor.visit(ast).must_equal feature
        end
      end

      describe '#visit_Feature' do
        before do
          @scenarios = [stub_everything, stub_everything, stub_everything]
          @node  = stub(scenarios: @scenarios, name: 'Go shopping')
        end

        it 'sets the name' do
          visitor.visit_Feature(@node)
          visitor.feature.name.must_equal 'Go shopping'
        end

        it 'iterates over its children' do
          @scenarios.each do |scenario|
            scenario.expects(:accept).with visitor
          end

          visitor.visit_Feature(@node)
        end
      end

      describe '#visit_Scenario' do
        before do
          @steps = [stub_everything, stub_everything, stub_everything]
          @tags  = [stub_everything, stub_everything, stub_everything]
          @node  = stub(
            tags:  @tags,
            steps: @steps,
            name:  'Go shopping on Saturday morning',
            line: 3
          )
        end

        it 'adds the scenario to the feature' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.length.must_equal 1
        end

        it 'sets the name' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.first.name.must_equal 'Go shopping on Saturday morning'
        end

        it 'sets the line' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.first.line.must_equal 3
        end

        it 'sets the tags' do
          @tags.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Scenario(@node)
        end

        it 'iterates over its children' do
          @steps.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Scenario(@node)
        end
      end

      describe '#visit_Tag' do
        it 'adds the tag to the current scenario' do
          tags     = ['tag1', 'tag2', 'tag3']
          scenario = stub(tags: tags)
          visitor.instance_variable_set(:@current_scenario, scenario)

          visitor.visit_Tag(stub(name: 'tag4'))
          scenario.tags.must_equal ['tag1', 'tag2', 'tag3', 'tag4']
        end
      end

      describe '#visit_Step' do
        before do
          @node  = stub(name: 'Baz', line: 3, keyword: 'Given')
          @steps = [stub(name: 'Foo'), stub(name: 'Bar')]
        end

        it 'adds the scenario to the feature' do
          scenario = stub(steps: @steps)
          visitor.instance_variable_set(:@current_scenario, scenario)

          visitor.visit_Step(@node)
          scenario.steps.length.must_equal 3
        end

        it 'sets the name' do
          scenario = stub(steps: [])
          visitor.instance_variable_set(:@current_scenario, scenario)

          visitor.visit_Step(@node)

          scenario.steps.first.name.must_equal 'Baz'
        end

        it 'sets the keyword' do
          scenario = stub(steps: [])
          visitor.instance_variable_set(:@current_scenario, scenario)

          visitor.visit_Step(@node)

          scenario.steps.first.keyword.must_equal 'Given'
        end

        it 'sets the line' do
          scenario = stub(steps: [])
          visitor.instance_variable_set(:@current_scenario, scenario)

          visitor.visit_Step(@node)

          scenario.steps.first.line.must_equal 3
        end
      end
    end
  end
end
