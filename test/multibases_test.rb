# frozen_string_literal: true

require 'test_helper'

class MultibasesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Multibases::VERSION
  end

  def test_that_it_has_a_spec_number
    refute_nil ::Multibases.multibase_version
  end
end
