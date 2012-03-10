require 'test_helper'

module Opinions

  class IntegrationTestOpinionsOpinionated < MiniTest::Integration::TestCase

    def test_voting_on_any_confirming_object
      
      example_target = ExampleTarget.new
      example_target.id = 456

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example)

      example_object = ExampleObject.new
      example_object.id = 123

      example_object.example(example_target)

      assert Opinion.new(target: example_target, object: example_object, opinion: :example).exists?

    end

    def test_cancelling_a_vote_on_any_conforming_object

      example_target = ExampleTarget.new
      example_target.id = 456

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example)

      example_object = ExampleObject.new
      example_object.id = 123
      
      expected_opinion = Opinion.new(target: example_target, object: example_object, opinion: :example)
      expected_opinion.persist

      example_object.cancel_example(example_target)

      refute Opinion.new(target: example_target, object: example_object, opinion: :example).exists?

    end

    def test_retrieving_votes_from_the_backend

      example_target_one = ExampleTarget.new
      example_target_one.id = 456

      example_target_two = ExampleTarget.new
      example_target_two.id = 789

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example)

      example_object = ExampleObject.new
      example_object.id = 123

      expected_opinion_one = Opinion.new(target: example_target_one, object: example_object, opinion: :example)
      expected_opinion_one.persist

      expected_opinion_two = Opinion.new(target: example_target_two, object: example_object, opinion: :example)
      expected_opinion_two.persist

      assert_equal 2, example_object.example_opinions.count

    end

  end

end
