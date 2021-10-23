# frozen_string_literal: true

class ReferenceSolver
  attr_reader :workspace

  def initialize(workspace)
    @workspace = workspace
  end

  def map_to_id(ref_type, attr, input)
    t = ref_type.arel_table
    query = if input[0] == "@"
        public_id = UuidUtil.uuid_s_to_bin(input[1..-1])
        t[:public_id].eq(public_id)
      else
        t[:name].eq(input)
      end

    model_attr = ref_type.name.underscore.pluralize.to_sym

    @workspace
      .public_send(model_attr)
      .select(:id, :name, :public_id)
      .where(query)
      .first
  end

  def map_to_ids(ref_type, attr, input)
    query = ModelUtil.terms_query(ref_type, input)
    model_attr = ref_type.name.underscore.pluralize.to_sym

    map = Hash[input.map { |k| [k, nil] }]

    @workspace
      .public_send(model_attr)
      .select(:id, :name, :public_id)
      .where(query)
      .each do |obj|
        if map.key?(obj.name)
          map[obj.name] = obj.id
        else
          id_ref = "@" + UuidUtil.uuid_bin_to_s(obj.public_id)
          if map.key?(id_ref)
            map[id_ref] = obj.id
          end
        end
      end

    map
  end
end
