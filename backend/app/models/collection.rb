require 'forwardable'

class Collection
  extend Forwardable
  def_delegators :collection, :size, :select

  def initialize
    @collection = ActualCollection.new(@@filters)
  end

  private

  def collection
    @collection
  end

  def self.validates_uniqueness_of(field)
    @@filters ||= {}
    @@filters[:unique] ||= []
    @@filters[:unique] << field
  end

  class ActualCollection
    extend Forwardable
    def_delegators :@collection, :size, :select
    def initialize(filters)
      @filters = filters
      @collection = []
    end

    def <<(candidate)
      run_filters(candidate)
      @collection << candidate
    end

    private
    def run_filters(candidate)
      run_unique_filters(@filters[:unique],candidate)
    end
    def run_unique_filters(fields,candidate)
      not_unique = fields.select do |field|
        @collection.map{|member| member.send(field)}.include?(candidate.send(field))
      end
      unless not_unique.empty?
        raise "The following fields were not unique: #{not_unique}"
      end
    end
  end
end

