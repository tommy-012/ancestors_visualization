# frozen_string_literal: true

require_relative './m1_1_1'
require_relative './m1_1_2'

module GemName
  module Modules
    module M1_1
      include M1_1_1
      extend M1_1_2

      def m1_1
      end
    end
  end
end
