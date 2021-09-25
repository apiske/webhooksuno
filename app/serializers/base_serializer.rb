
class BaseSerializer
  include ::Spyderweb::Kellogs::Serializer

  def serialize_tags(obj)
    return [] unless obj.tag_ids.present?
    obj.workspace.tags
      .where(id: obj.tag_ids)
      .select(:name, :public_id)
  end
end
