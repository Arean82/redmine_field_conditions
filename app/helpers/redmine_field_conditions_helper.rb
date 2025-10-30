module RedmineFieldConditionsHelper

  OPERATORS = [
    ['=~', 'regex'],
    ['=', 'eq'],
    ['!=', 'ne'],
    ['>', 'gt'],
    ['>=', 'ge'],
    ['<', 'lt'],
    ['<=', 'le'],
    ['value', 'getvalue']
  ].freeze

  ##
  # Make sure @custom_field or @custom_table is properly set
  #
  def set_custom_object
    @custom_field = @custom_table if @custom_table
  end

  ##
  # Determine whether we’re working with a field or table
  #
  def set_parameter_name
    @param_name = @custom_table ? "custom_table" : "custom_field"
  end

  ##
  # Safely load YAML/JSON/String conditions and normalize into @parsed_conditions (Hash)
  #
  def ensure_conditions_initialized
    return unless @custom_field

    raw = @custom_field.conditions
    parsed = {}

    # Parse YAML or JSON only — never modify original
    if raw.is_a?(Hash)
      parsed = raw
    elsif raw.is_a?(String)
      begin
        unless raw.strip.empty?
          parsed = YAML.safe_load(raw, permitted_classes: [Symbol], aliases: true)
          parsed = JSON.parse(raw) if parsed.nil?
        end
      rescue StandardError
        parsed = {}
      end
    end

    # Normalize to a proper hash with required keys
    parsed = {} unless parsed.is_a?(Hash)
    parsed['enabled'] = !!parsed['enabled']
    parsed['expr']    ||= ''
    parsed['rules']   = Array(parsed['rules'])

    # Keep parsed version for the view
    @parsed_conditions = parsed
  end

  ##
  # Build HTML form for a single condition rule
  #
  def build_conditions_form(custom_field, rules, rule_index)
    set_parameter_name unless @param_name
    html = ""

    rule_name = (rules.nil? ? "" : rules.dig('rule', 'name'))
    elements = label_tag(l("redmine_field_conditions.label_rule_name"))
    elements << text_field_tag("#{@param_name}[conditions][rule_name][]", rule_name, maxlength: 30)
    html << content_tag(:p, elements)

    # Tracker core fields
    core_fields = if custom_field.id.nil?
                    Tracker::CORE_FIELDS
                  else
                    custom_field.trackers.map(&:core_fields).uniq.sort.flatten
                  end
    selected_field = (rules.nil? ? "" : rules.dig('rule', 'field'))

    # Determine custom field type
    cf_type =
      if custom_field.is_a?(CustomTable)
        "IssueCustomField"
      else
        custom_field.type.presence || "IssueCustomField"
      end

    elements = label_tag(l("redmine_field_conditions.label_rule_field"))
    elements << select_tag(
      "#{@param_name}[conditions][rule_field][]",
      options_for_select(core_fields, selected_field) +
        options_from_collection_for_select(CustomField.where(type: cf_type).order(:name), "id", "name", selected_field)
    )
    html << content_tag(:p, elements)

    elements = label_tag(l("redmine_field_conditions.label_rule_op"))
    elements << select_tag(
      "#{@param_name}[conditions][rule_op][]",
      options_for_select(OPERATORS, (rules.nil? ? "" : rules.dig('rule', 'op')))
    )
    html << content_tag(:p, elements)

    elements = label_tag(l("redmine_field_conditions.label_rule_val"))
    elements << text_field_tag(
      "#{@param_name}[conditions][rule_val][]",
      (rules.nil? ? "" : rules.dig('rule', 'val'))
    )
    html << content_tag(:p, elements)

    elements = label_tag("")
    elements << button_tag(
      "",
      type: 'button',
      class: 'icon-only icon-del',
      name: "#{@param_name}[conditions][button_delete_rule][]",
      onclick: "submit_conditions('#{url_for(action: 'remove_rule', controller: 'redmine_field_conditions', rule: rule_index , format: 'js')}')"
    )
    html << content_tag(:p, elements)

    content_tag(:div, html.html_safe, "data-rule": rule_index)
  end
end
