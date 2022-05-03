# frozen_string_literal: true

require_relative './modules/m2_1'
require_relative './modules/m2_2'

module GemName
  class C2
    include Modules::M2_1
    extend Modules::M2_2
  end
end
