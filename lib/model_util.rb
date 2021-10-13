# frozen_string_literal: true
require "set"

module ModelUtil
  class << self
    def terms_query(model_klass, terms)
      data = terms_to_names_n_ids(terms)
      t = model_klass.arel_table
      t[:public_id].in(data[:public_id]).or(t[:name].in(data[:name]))
    end

    def terms_to_names_n_ids(terms)
      ids = Set.new
      names = Set.new

      terms.each do |t|
        if t[0] == '@'
          ids << UuidUtil.uuid_s_to_bin(t[1..-1])
        else
          names << t
        end
      end

      {
        public_id: ids.to_a,
        name: names.to_a
      }
    end
  end
end
