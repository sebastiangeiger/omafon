class HashObject
  def initialize(content)
    @content = content
  end
  def method_missing(method,*args,&block)
    if @content.has_key? method
      @content[method]
    else
      super(method,args,block)
    end
  end
  def fits_criteria?(options)
    options.inject(true) do |all_attributes_fit, desired_attribute|
      desired_key, desired_value = desired_attribute
      if @content.has_key? desired_key
        this_on_fits = (@content[desired_key] == desired_value)
      else
        this_on_fits = false
      end
      all_attributes_fit &&= this_on_fits
    end
  end
end
