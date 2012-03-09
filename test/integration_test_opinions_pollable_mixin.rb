require 'test_helper'

module Opinions

  class IntegrationTestEmptionsPollable < MiniTest::Integration::TestCase

    def test_being_voted_by_any_conforming_object

      example_object = ExampleObject.new
      example_object.id = 123

      ExampleTarget.send(:include, Pollable)
      ExampleTarget.send(:opinions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      example_target.example_by(example_object)

      assert Opinion.new(target: example_target, object: example_object, opinion: :example).exists?

    end

    def test_cancelling_an_vote_by_any_conforming_object

      example_object = ExampleObject.new
      example_object.id = 123

      ExampleTarget.send(:include, Pollable)
      ExampleTarget.send(:opinions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      expected_opinion = Opinion.new(target: example_target, object: example_object, opinion: :example)
      expected_opinion.persist

      example_target.cancel_example_by(example_object)

      refute Opinion.new(target: example_target, object: example_object, opinion: :example).exists?

    end

    def test_counting_the_number_of_votes

      skip

      example_object_one = ExampleObject.new
      example_object_one.id = 123

      example_object_two = ExampleObject.new
      example_object_two.id = 456

      ExampleTarget.send(:include, Pollable)
      ExampleTarget.send(:opinions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      expected_opinion_one = Opinion.new(target: example_target, object: example_object_one, opinion: :example)
      expected_opinion_one.persist

      expected_opinion_two = Opinion.new(target: example_target, object: example_object_two, opinion: :example)
      expected_opinion_two.persist

      assert_equal 2, example_target.example_votes.count

    end


  end

end
