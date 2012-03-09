require 'test_helper'

module Opinions

  class AcceptanceTestOpinionsKeyLoader < MiniTest::Acceptance::TestCase

    def test_it_should_call_find_for_both_keys

      example_object = ExampleObject.new(123)
      example_target = ExampleTarget.new(456)

      kl = KeyLoader.new("ExampleTarget:opinion:123")

      assert_equal example_object, kl.object

    end

  end

end
