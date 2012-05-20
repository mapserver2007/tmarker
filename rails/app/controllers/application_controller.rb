# Make it available sinatra project
TMARKER_ROOT = File.dirname(File.expand_path($PROGRAM_NAME))
$: << TMARKER_ROOT + "/../sinatra/"
$: << TMARKER_ROOT + "/../extension/"
require 'models/common/util'

class ApplicationController < ActionController::Base
  # helper :all # include all helpers, all the time
  rescue_from ActionController::RoutingError, :with => :error
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'base'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  def session_validate(forward_url = nil)
    if current_user.nil? || current_user.login != params[:id]
      unless forward_url.nil?
        flash[:forward_to] = forward_url
        redirect_to(login_url)
      else
        error
      end
    end
  end

  def save_tab_session(tab_id)
    session[:tab_id] = tab_id
  end

  def m(key)
    Setting.read_config(key)
  end

  def application_title(subtitle = nil, param = nil)
    subtitle = m(subtitle) if !subtitle.nil?
    subtitle = subtitle % param if !param.nil?
    Setting.title(subtitle)
  end

  def default_item_role
    m("role")
  end

  def current_method
    caller.first.scan(/`(.*)'/).to_s
  end

  def path_to_sinatra
    File::expand_path(File.dirname(__FILE__) + '/../../../sinatra/')
  end

  def path_to_extension
    File::expand_path(File.dirname(__FILE__) + '/../../../extention/')
  end

  def url_for_apache
    "http://summer-lights.jp/tmarker/"
  end

  def feed_header
    Setting.read_feed_config
  end

  def error
    @title = application_title('error_404')
    render :template => 'view/error', :status => '404'
  end
end
