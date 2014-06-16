module Differ
  class Change # :nodoc:
    attr_accessor :insert, :delete
    def initialize(options = {})
      @insert = options[:insert] || ''
      @delete = options[:delete] || ''
    end

    def insert?
      !@insert.empty?
    end

    def delete?
      !@delete.empty?
    end

    def change?
      insert? && delete?
    end

    def to_s
      Differ.format.call(self)
    end
    alias_method :inspect, :to_s

    def ==(other)
      insert == other.insert && delete == other.delete
    end
  end
end
