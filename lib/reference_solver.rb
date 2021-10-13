# frozen_string_literal: true

class ReferenceSolver
  attr_reader :workspace

  def initialize(workspace)
    @workspace = workspace
  end

  def map_to_ids(ref_type, attr, input)
    query = ModelUtil.terms_query(ref_type, input)
    model_attr = ref_type.name.downcase.pluralize.to_sym

    map = Hash[input.map { |k| [k, nil] }]

    @workspace
      .public_send(model_attr)
      .select(:id, :name, :public_id)
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
