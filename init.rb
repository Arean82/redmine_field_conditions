# Ensure plugin's lib path is loaded before requiring anything
plugin_root = File.expand_path(__dir__)
lib_path = File.join(plugin_root, 'lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'redmine_field_conditions'

Redmine::Plugin.register :redmine_field_conditions do
  name 'Redmine Field Conditions'
  author 'Marcel Bonnet'
  description 'Adds conditions for custom fields to dynamically change rules for its exhibition or filling requirement.'
  version '0.0.5'
  url 'https://github.com/marcelbonnet/redmine_field_conditions'
  author_url 'https://github.com/marcelbonnet'
  requires_redmine :version_or_higher => '4.0.0'
end

# Load plugin hooks safely
require_dependency 'redmine_field_conditions/hooks/custom_table_hook'
require_dependency 'redmine_field_conditions/hooks/custom_table_view_hook'
require_dependency 'redmine_field_conditions/hooks/custom_field_view_hook'
require_dependency 'redmine_field_conditions/patches/custom_field_patch'
require_dependency 'redmine_field_conditions/patches/custom_fields_helper_patch'
require_dependency 'redmine_field_conditions/patches/issue_patch'
require_dependency 'redmine_field_conditions/patches/custom_table_patch'
# Apply patches to Redmine classes


Rails.configuration.to_prepare do
  CustomField.send :include, RedmineFieldConditions::Patches::CustomFieldPatch
  CustomFieldsHelper.send :include, RedmineFieldConditions::Patches::CustomFieldsHelperPatch
  Issue.send :include, RedmineFieldConditions::Patches::IssuePatch
end
