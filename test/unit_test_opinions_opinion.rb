require 'test_helper'

module Opinions

  class UnitTestOpinion < MiniTest::Unit::TestCase

    def test_an_argument_error_is_raised_when_instantiated_without_a_target
      assert_raises KeyError do
        Opinion.new(object: true, opinion: true)
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_object
      assert_raises KeyError do
        Opinion.new(target: true, opinion: true)
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_opinion
      assert_raises KeyError do
        Opinion.new(object: true, target: true)
      end
    end

    def test_opinions_with_the_same_properties_compare_equal
      o, t = Class.new, Class.new
      opinion_one = Opinion.new(opinion: :test, target: t, object: o)
      opinion_two = Opinion.new(opinion: :test, target: t, object: o)
      assert_equal opinion_one, opinion_two
    end

    def test_opinions_with_different_properties_do_not_compare_equal
      opinion_one = Opinion.new(opinion: :test, target: Class.new, object: Class.new)
      opinion_two = Opinion.new(opinion: :test, target: Class.new, object: Class.new)
      refute_equal opinion_one, opinion_two
    end

    def test_the_creation_time_is_readable_via_an_accessor_default_nil
      assert_nil Opinion.new(object: true, target: :example, opinion: true).created_at
    end

    def test_the_target_is_readable_via_an_accessor
      assert_equal :example, Opinion.new(object: true, target: :example, opinion: true).target
    end

    def test_the_object_is_readable_via_an_accessor
      assert_equal :example, Opinion.new(object: :example, target: true, opinion: true).object
    end

    def test_the_opinion_is_readable_via_an_accessor
      assert_equal :example, Opinion.new(object: true, target: true, opinion: :example).opinion
    end

    def test_the_target_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_target = ::ExampleTarget.new
      example_target.id = 456
      opinion = Opinion.new(object: example_object, target: example_target, opinion: :example)
      assert_equal 'ExampleTarget:example:456:ExampleObject', opinion.target_key
    end

    def test_the_object_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_object.id = 123
      example_target = ::ExampleTarget.new
      opinion = Opinion.new(object: example_object, target: example_target, opinion: :example)
      assert_equal 'ExampleObject:example:123:ExampleTarget', opinion.object_key
    end

  end

end
