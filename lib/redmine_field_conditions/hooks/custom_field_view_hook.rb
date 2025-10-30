module RedmineFieldConditions
  module Hooks
    class CustomFieldViewHook < Redmine::Hook::ViewListener
      # This replaces `render_on` and ensures helpers are available
      def view_custom_fields_form_upper_box(context = {})
        view = context[:controller].view_context

        # Inject helpers so the partial can call set_custom_object etc.
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
