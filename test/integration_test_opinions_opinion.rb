require 'test_helper'

module Opinions

  class IntegrationTestOpinionsOpinion < MiniTest::Integration::TestCase

    def test_opinions_do_not_exist_until_persisted

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      opinion = Opinion.new(object: example_object, target: example_target, opinion: :example)

      refute opinion.exists?

    end

    def test_opinions_exist_once_persisted

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      opinion_one = Opinion.new(object: example_object, target: example_target, opinion: :example)

      refute opinion_one.exists?
      assert opinion_one.persist
      assert opinion_one.exists?

    end

    def test_opinions_that_are_the_same_can_be_treated_as_equal

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      opinion_one = Opinion.new(object: example_object, target: example_target, opinion: :example)
      opinion_two = Opinion.new(object: example_object, target: example_target, opinion: :example)

      refute opinion_one.exists?
      refute opinion_two.exists?

      [opinion_one, opinion_two].sample.persist

      assert opinion_one.exists?
      assert opinion_two.exists?

    end

  end

end
