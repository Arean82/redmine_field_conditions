module RedmineFieldConditions
  module Hooks
    class CustomFieldViewHook < Redmine::Hook::ViewListener
      # Explicitly include helper so view context can see set_custom_object, etc.
      include ::RedmineFieldConditionsHelper
      include ::CustomFieldsHelper

      def view_custom_fields_form_upper_box(context = {})
        view = context[:controller].view_context
        view.extend(::RedmineFieldConditionsHelper)
        view.extend(::CustomFieldsHelper)
        view.render(
          partial: 'custom_fields/hooks/fields_conditions',
          locals: context
        )
      end
    end
  end
end
