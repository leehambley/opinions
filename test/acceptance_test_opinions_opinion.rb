require 'test_helper'

module Opinions

  class AcceptanceTestOpinionsOpinion < MiniTest::Acceptance::TestCase

    def test_checking_if_an_opinion_exists_checks_both_sides_of_the_relationship

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_object.id = 123
      example_target.id = 456

      opinion = Opinion.new({ target:  example_target,
                              object:  example_object,
                              opinion: :example })

      Opinions.backend = ::MiniTest::Mock.new

      Opinions.backend.expect(:read_sub_key, false, [opinion.target_key, example_object.id.to_s])
      Opinions.backend.expect(:read_sub_key, false, [opinion.object_key, example_target.id.to_s])

      refute opinion.exists?

      Opinions.backend.verify

    end

    def test_creating_an_opinion_creates_both_sides_of_the_relationship

      t = Time.now.utc

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.id = 123
      example_object.id = 456

      opinion = Opinion.new({ target:  example_target,
                              object:  example_object,
                              opinion: :example })

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:write_keys, true, [{ opinion.target_key => {example_object.id.to_s => t},
                                                    opinion.object_key => {example_target.id.to_s => t}}])

      opinion.persist(time: t)

      Opinions.backend.verify

    end

    def test_removing_an_opinion_removes_both_sides_of_the_relationship

      t = Time.now.utc

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.id = 123
      example_object.id = 456

      opinion = Opinion.new({ target:  example_target,
                              object:  example_object,
                              opinion: :example })

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:remove_sub_keys, true, [[ [opinion.target_key, example_object.id.to_s],
                                                         [opinion.object_key, example_target.id.to_s] ]])

      opinion.remove

      Opinions.backend.verify

    end

    def test_removing_one_opinion_without_removing_other_opinions

      t = Time.now.utc

      example_target     = ::ExampleTarget.new
      example_object_one = ::ExampleObject.new
      example_object_two = ::ExampleObject.new

      example_target.id     = 123
      example_object_one.id = 456
      example_object_two.id = 789

      opinion_one = Opinion.new({ target:  example_target,
                                  object:  example_object_one,
                                  opinion: :example })

      opinion_two = Opinion.new({ target:  example_target,
                                  object:  example_object_two,
                                  opinion: :example })

      Opinions.backend = ::MiniTest::Mock.new
      Opinions.backend.expect(:remove_sub_keys, true, [[ [opinion_one.target_key, example_object_one.id.to_s],
                                                         [opinion_one.object_key, example_target.id.to_s] ]])

      opinion_one.remove

      Opinions.backend.verify

    end

  end

end
