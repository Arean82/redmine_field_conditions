# frozen_string_literal: true

module RedmineFieldConditions
  module Patches
    module CustomFieldsHelperPatch
      def self.included(base)
        base.class_eval do
          include RedmineFieldConditionsHelper
        end
      end
    end
  end
end

# ✅ Ensure it’s included only once
unless CustomFieldsHelper.included_modules.include?(RedmineFieldConditions::Patches::CustomFieldsHelperPatch)
  CustomFieldsHelper.send(:include, RedmineFieldConditions::Patches::CustomFieldsHelperPatch)
end
