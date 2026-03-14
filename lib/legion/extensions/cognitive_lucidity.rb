# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_lucidity/version'
require 'legion/extensions/cognitive_lucidity/helpers/constants'
require 'legion/extensions/cognitive_lucidity/helpers/dream_state'
require 'legion/extensions/cognitive_lucidity/helpers/journal_entry'
require 'legion/extensions/cognitive_lucidity/helpers/lucidity_engine'
require 'legion/extensions/cognitive_lucidity/runners/cognitive_lucidity'
require 'legion/extensions/cognitive_lucidity/client'

module Legion
  module Extensions
    module CognitiveLucidity
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
