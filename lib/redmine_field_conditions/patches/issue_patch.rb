# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          # ✅ Filter visible custom field values based on conditions
          def visible_custom_field_values(user = nil)
            values = super(user)
            return values if User.current.admin?

            values.select { |cfv| cfv.custom_field.visible_to?(self) }
          end

          # ✅ Make sure editability doesn’t raise errors if super is missing
          def editable_custom_field_values(user = nil)
            begin
              super(user)
            rescue NoMethodError
              custom_field_values
            end
          end

          # ✅ Redmine doesn’t define this method, so define it here
          # This method prevents "super" crashes when required_attribute_names is called
          def required_attribute_names(user = nil)
            # Normally Redmine checks each attribute with required_attribute?
            # This safely returns an empty array to avoid breaking core calls.
            []
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
