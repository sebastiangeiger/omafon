module Observable
  def on(event_name,&block)
    @callbacks ||= {}
    @callbacks[event_name] ||= []
    @callbacks[event_name] << block
  end
  def trigger(event_name, *payload)
    @callbacks ||= {}
    (@callbacks[event_name] || []).each do |callback|
      callback.call(payload)
    end
  end
end
