class LogController < ViewController
  helper :log
  def development
    @title = application_title('message_log_development')
    @development_log = development_log
    render :action => 'development'
  end

  def tracking
    @title = application_title('message_log_tracking')
    @tracking_log = tracking_log
    render :action => 'tracking'
  end
end
