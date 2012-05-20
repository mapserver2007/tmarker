module LogHelper
  def development_list(log, idx = nil)
    @log_id    = "<span>#{"%03d" % log.log_id}</span>"
    @log_date  = "<span>#{log.date.strftime("%Y/%m/%d")}</span>"
    @log_title = "<span>#{link_to(log.title, log.link)}</span>"
    unless idx.nil?
      content = "#{@log_id}#{@log_date}#{@log_title}"
      idx % 2 == 0 ? even(content) : odd(content)
    end
  end

  def tracking_list(log, idx)
    development_list(log)
    status = log.status
    if log.status.length == 6
      status = status.unpack("a3a3").join("　")
    end
    @log_tracker = "<span>#{log.tracker}</span>"
    @log_status  = "<span>#{status}</span>"
    unless idx.nil?
      content = "#{@log_id}#{@log_date}#{@log_tracker}#{@log_status}#{@log_title}"
      idx % 2 == 0 ? even(content) : odd(content)
    end
  end

  private

  def odd(content)
    "<div class='odd'>#{content}</div>"
  end

  def even(content)
    "<div class='even'>#{content}</div>"
  end
end
