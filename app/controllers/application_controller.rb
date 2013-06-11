
class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def template_renderer(options={})
    template = options[:template] || 'index'
    json = options[:json]

    respond_to do |format|
      format.html { render template }
      format.js { render template }
      format.json do
        if Fixnum === json
          render nothing: true, status: json
        elsif String === json
          render json: {'error' => json}, status: 404
        elsif json.respond_to? :call
          render json: json.call
        elsif json
          render json: json
        else
          render nothing: true, status: 500
        end
      end
    end
  end
end
