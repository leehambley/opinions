require 'test_helper'

module Opinions

  class AcceptanceTestOpinionsOpinionated < MiniTest::Acceptance::TestCase

    def test_mixing_in_opinionated_makes_the_opinions_method_available

      refute ExampleObject.respond_to?(:opinions)
      ExampleObject.send(:include, Opinionated)
      assert ExampleObject.respond_to?(:opinions)

    end

    def test_using_the_pollable_opinions_method_registers_them_as_supported_opinions

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example_one, :example_two, :example_three)

      assert_equal [:example_one, :example_two, :example_three], ExampleObject.registered_opinions

    end

    def test_the_registered_opinions_have_their_instance_methods_created

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example_opinion)

      assert ExampleObject.new.respond_to?(:example_opinion)
      assert ExampleObject.new.respond_to?(:cancel_example_opinion)
      assert ExampleObject.new.respond_to?(:example_opinion_opinions)
      assert ExampleObject.new.respond_to?(:have_example_opinion_on)

    end

    def test_creating_an_opinion_persits_it_to_the_backend

      t = Time.now

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example_opinion)

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:write_keys, true, [{ 'ExampleObject:example_opinion:123:ExampleTarget' => {'456' => t},
                                                    'ExampleTarget:example_opinion:456:ExampleObject' => {'123' => t} }])

      assert_equal true, example_object.example_opinion(example_target, t)

      Opinions.backend.verify

    end

    def test_calcelling_an_opinion_removes_both_sides_of_the_relationship_from_the_backend

      t = Time.now

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example_opinion)

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:remove_sub_keys, true, [[["ExampleTarget:example_opinion:456:ExampleObject", "123"],
                                                        ["ExampleObject:example_opinion:123:ExampleTarget", "456"]]])

      assert_equal true, example_object.cancel_example_opinion(example_target)

      Opinions.backend.verify

    end

    def test_opinions_retrieved_from_the_backend_en_masse

      t = Time.now

      ExampleObject.send(:include, Opinionated)
      ExampleObject.send(:opinions, :example_opinion)

      example_target = ExampleTarget.new
      example_target.id = '456'

      example_object = ExampleObject.new
      example_object.id = '123'

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:keys_matching, ["ExampleObject:example_opinion:123:ExampleTarget"], ["ExampleObject:example_opinion:123*"])
      Opinions.backend.expect(:read_key, {"456" => t}, ["ExampleObject:example_opinion:123:ExampleTarget"])

      expected_opinion = Opinion.new(target: example_target,
                                     object: example_object,
                                     opinion: :example_opinion,
                                     created_at: t)

      assert_equal expected_opinion, example_object.example_opinion_opinions.first

      Opinions.backend.verify

    end



  end

end
