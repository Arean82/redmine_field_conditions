# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module CustomFieldPatch
      def self.included(base)
        base.class_eval do
          # Include plugin helper modules
          include RedmineFieldConditions
          include RedmineFieldConditions::Utils
          include RedmineFieldConditions::Validator

          # ✅ Store and serialize 'conditions' as JSON
          store :conditions, accessors: [:rules, :expr], coder: JSON

          # ✅ Allow 'conditions' to be saved via safe attributes (Redmine 5+)
          safe_attributes 'conditions'

          # ✅ Validate field conditions before saving
          validate :validate_field_conditions

          # ✅ Define visibility logic (works for Issues and other objects)
          def visible_to?(obj)
            return true if User.current.admin?

            case obj
            when Issue
              check_condition(self.conditions, obj)
            else
              true
            end
          end

          # (Optional placeholders for future use)
          def editable_to?(obj); end
          def required_to?(obj); end
          def multiple_to?(obj); end
        end
      end
    end
  end
end

# Ensure patch is included only once
unless CustomField.included_modules.include?(RedmineFieldConditions::Patches::CustomFieldPatch)
  CustomField.send(:include, RedmineFieldConditions::Patches::CustomFieldPatch)
end
