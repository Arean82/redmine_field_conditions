# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          # ✅ Override visible_custom_field_values to respect conditions
          def visible_custom_field_values(user = nil)
            values = super(user)
            return values if User.current.admin?

            values.select { |cfv| cfv.custom_field.visible_to?(self) }
          end

          # TODO: these can be extended later if you want to control editability or required fields dynamically
          def editable_custom_field_values(user = nil)
            super(user)
          end

          def required_attribute_names(user = nil)
            super(user)
          end
        end
      end
    end
  end
end

# ✅ Include only once
unless Issue.included_modules.include?(RedmineFieldConditions::Patches::IssuePatch)
  Issue.send(:include, RedmineFieldConditions::Patches::IssuePatch)
end
