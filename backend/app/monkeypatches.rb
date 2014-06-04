class Hash
  def symbolize_keys
    self.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
  end
end

class String
  def camelize
    split('_').map(&:capitalize).join('')
  end
end

