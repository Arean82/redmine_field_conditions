# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module CustomTablePatch
      def self.included(base)
        base.class_eval do
          # Include helper modules
          include RedmineFieldConditions
          include RedmineFieldConditions::Utils
          include RedmineFieldConditions::Validator

          # ✅ Store and serialize 'conditions' in JSON format
          store :conditions, accessors: [:rules, :expr], coder: JSON

          # ✅ Make sure Redmine strong parameters allow saving this
          safe_attributes 'conditions'

          # ✅ Validate before saving
          validate :validate_field_conditions

          # ✅ Visibility logic for custom tables
          def visible_to?(issue)
            return true if User.current.admin?
            check_condition(self.conditions, issue)
          end
        end
      end
    end
  end
end

# ✅ Include patch only once
unless CustomTable.included_modules.include?(RedmineFieldConditions::Patches::CustomTablePatch)
  CustomTable.send(:include, RedmineFieldConditions::Patches::CustomTablePatch)
end
