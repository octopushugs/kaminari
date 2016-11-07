# frozen_string_literal: true
require 'kaminari/activerecord/paginable_without_count'

module Kaminari
  module ActiveRecordRelationMethods
    def entry_name(options = {})
      model_name.human(options.reverse_merge(:default => model_name.human.pluralize(options[:count])))
    end

    def without_count
      extend(::Kaminari::PaginableWithoutCount)
    end

    def reset #:nodoc:
      @total_count = nil
      super
    end

    def total_count(column_name = :all, _options = nil) #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        c = except(:offset, :limit, :order)

        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?

        # .group returns an OrderedHash that responds to #count
        c = c.count(column_name)
        if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
          c.count
        else
          c.respond_to?(:count) ? c.count(column_name) : c
        end
      end
    end
  end
end
