# frozen_string_literal: true

require_relative './modules/m1_1'
require_relative './modules/m1_2'

module GemName
  class C1 < C2
    include Modules::M1_1
    extend Modules::M1_2
  end
end
