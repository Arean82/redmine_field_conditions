module RedmineFieldConditions
  module Hooks
    class CustomFieldViewHook < Redmine::Hook::ViewListener
      include RedmineFieldConditionsHelper  # 👈 Add this line

      render_on :view_custom_fields_form_upper_box,
                partial: 'custom_fields/hooks/fields_conditions'
    end
  end
end
