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
	]

	def set_custom_object
		@custom_field = @custom_table if @custom_table
	end

	def set_parameter_name
		@param_name = "custom_field"
		@param_name = "custom_table" if @custom_table
	end

	def ensure_conditions_initialized
	  return unless @custom_field
	
	  raw = @custom_field.conditions
	
	  # 🔒 Step 1 — Force parse strings into a Ruby hash safely
	  if raw.is_a?(String)
	    parsed = nil
	    begin
	      unless raw.strip.empty?
	        parsed = YAML.safe_load(raw, permitted_classes: [Symbol], aliases: true) rescue nil
	        parsed ||= JSON.parse(raw) rescue nil
	      end
	    rescue StandardError
	      parsed = nil
	    end
	    @custom_field.conditions = parsed.is_a?(Hash) ? parsed : {}
	  elsif !raw.is_a?(Hash)
	    # If it's something else (nil, integer, etc.), reset cleanly
	    @custom_field.conditions = {}
	  end
	
	  # 🔒 Step 2 — Always ensure it's a hash from now on
	  @custom_field.conditions ||= {}
	
	  # 🔒 Step 3 — Initialize expected keys with safe defaults
	  @custom_field.conditions['enabled'] = !!@custom_field.conditions['enabled']
	  @custom_field.conditions['expr']    ||= ''
	  @custom_field.conditions['rules']   = Array(@custom_field.conditions['rules'])
	end




	def build_conditions_form(custom_field, rules, rule_index)
		set_parameter_name unless @param_name

		html = ""

		rule_name = (rules.nil? ? "" : rules['rule']['name'])
		
		elements = label_tag( l("redmine_field_conditions.label_rule_name"))
		elements << text_field_tag( "#{@param_name}[conditions][rule_name][]", rule_name, maxlength:30)
		html << content_tag(:p, elements)
		
		core_fields = Tracker::CORE_FIELDS
		unless custom_field.id.nil?
			core_fields = custom_field.trackers.map{|t| t.core_fields}.uniq.sort.flatten
		end
		selected_field = (rules.nil? ? "" : rules['rule']['field'])

		cf_type = custom_field.type
		if custom_field.is_a?(CustomTable)
			cf_type = "IssueCustomField"
		else
			cf_type = "IssueCustomField" if cf_type.empty? # TODO will it work properly for Document, Project... fields?
		end
		elements = label_tag( l("redmine_field_conditions.label_rule_field"))
		elements << select_tag("#{@param_name}[conditions][rule_field][]", options_for_select(core_fields, selected_field) + options_from_collection_for_select(CustomField.where(type: cf_type).order(:name), "id", "name", selected_field))
		html << content_tag(:p, elements)
		
		elements = label_tag( l("redmine_field_conditions.label_rule_op"))
		elements << select_tag("#{@param_name}[conditions][rule_op][]", options_for_select(OPERATORS, (rules.nil? ? "" : rules['rule']['op'])))
		html << content_tag(:p, elements)
		
		elements = label_tag( l("redmine_field_conditions.label_rule_val"))
		elements << text_field_tag( "#{@param_name}[conditions][rule_val][]", (rules.nil? ? "" : rules['rule']['val']))
		html << content_tag(:p, elements)

		elements = label_tag("")
		elements << button_tag("", type: 'button', class: 'icon-only icon-del', name: "#{@param_name}[conditions][button_delete_rule][]", onclick:"submit_conditions('#{url_for(action: 'remove_rule', controller: 'redmine_field_conditions', rule: rule_index , format: 'js')}')")
		html << content_tag(:p, elements)

		content_tag(:div, html.html_safe, "data-rule": rule_index)
	end

end
