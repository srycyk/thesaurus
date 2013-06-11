
module ApplicationHelper
  def js_partial(partial, locals={})
    escape_javascript(render partial, locals)
  end
end
