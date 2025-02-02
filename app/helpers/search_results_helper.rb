module SearchResultsHelper
  include ActionView
  include SearchColumns

  def link_to_ling(ling)
    "<a href='/groups/#{current_group.to_param}/lings/#{ling.to_param}'>#{h(ling.name)}</a>".html_safe
  end

  def link_to_property(property)
    "<a href='/groups/#{current_group.to_param}/properties/#{property.to_param}'>#{h(property.name)}</a>".html_safe
  end

  def row_methods
    @row_methods ||= {
      :ling_0     => lambda { |v| link_to_ling(v.ling) },
      :ling_1     => lambda { |v| link_to_ling(v.ling) },
      :property_0 => lambda { |v| link_to_property(v.property) },
      :property_1 => lambda { |v| link_to_property(v.property) },
      :value_0    => lambda { |v| v.value  },
      :value_1    => lambda { |v| v.value  },
      :example_0  => lambda { |v| v.examples.map(&:name).join(", ") },
      :example_1  => lambda { |v| v.examples.map(&:name).join(", ") }
    }
  end

  def search_result_attributes(parent, child = nil)
    {}.tap do |attrs|
      attrs[:class] = "search_result row"
      attrs["data-parent-value"] = parent.id
      attrs["data-child-value"]  = child.id unless child.nil?
    end
  end

  def display_save_search_form?(search)
    user_signed_in? && search.new_record? && !current_user.reached_max_search_limit?(current_group)
  end
end
