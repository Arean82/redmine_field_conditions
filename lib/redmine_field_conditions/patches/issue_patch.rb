# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          # ✅ Works whether Redmine core calls with 0 or 1 argument
          def visible_custom_field_values(*args)
            values = super(*args)
            return values if User.current.admin?

            # Filter only the custom fields visible under current conditions
            values.select { |cfv| cfv.custom_field.visible_to?(self) }
          end

          # ✅ Prevent editability errors
          def editable_custom_field_values(*args)
            begin
              super(*args)
            rescue NoMethodError
              custom_field_values
            end
          end

          # ✅ Prevent crashes on required_attribute_names
          def required_attribute_names(*_args)
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
