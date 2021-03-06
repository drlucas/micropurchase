# Since descriptions can be in Github Formatted Markdown, this is a
# little mixin that adds a html_description method
module Swagger::Mixins
end

module Swagger::Mixins::Description
  def html_description
    unless description.blank?
      MarkdownRender.new(description).to_s
    end
  end

  def inline_html_description
    unless description.blank?
      html_description.gsub(/^<p>/, '').gsub(%r{</p>$}, '').html_safe
    end
  end
end
