# frozen_string_literal: true

class ApiV1::SubscriptionsController < ApiController
  class SubscriptionContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
      optional(:key).value(:string)
      optional(:topics).array(:string)
      optional(:destination_url).value(:string)
      # TODO: destination_type
      # TODO: add binding_id
    end

    rule(:name).validate(:entity_name)
    rule(:key).validate(:uuid_or_name)
    rule(:topics).validate(:uuid_or_names)
    rule(:destination_url) do
      next if value.nil?

      # TODO: validate URL
    end
  end

  before_action :fetch_subscription, only: [:show, :update]
  before_action :fetch_receiver_binding, only: [:create, :update]

  def index
    render_collection(@workspace.subscriptions.order(name: :asc).all)
  end

  def show
    render_single(@subscription)
  end

  def create
    attributes = SubscriptionContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    subscription = Subscription.new
    set_subscription_attributes(subscription, attributes)

    subscription.state = Subscription::State[:unverified]
    subscription.destination_type = Subscription::DestinationType[:https]
    subscription.workspace = @workspace
    subscription.receiver_binding = @receiver_binding
    subscription.router_id = @receiver_binding.router.id
    subscription.save!

    render status: :created, json: {
      data: {
        id: subscription.public_uuid
      }
    }
  end

  def update
    attributes = SubscriptionContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    set_subscription_attributes(@subscription, attributes)
    @subscription.save!

    head 204
  end

  private

  def fetch_subscription
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @subscription = @workspace.subscriptions
      .eager_load(:receiver_binding)
      .find_by!(public_id: uuid)
  end

  def fetch_receiver_binding
    if @subscription
      @receiver_binding = @subscription.receiver_binding
    else
      binding_id = body_obj["data"].delete("binding_id")
      # TODO: validate binding_id

      uuid = UuidUtil.uuid_s_to_bin(binding_id)

      binding_request = BindingRequest
        .find_by!(public_id: uuid)

      @receiver_binding = binding_request
        .receiver_bindings
        .eager_load(router: [:workspace])
        .find_by!(workspace_id: @workspace.id)
    end

    @sender_workspace = @receiver_binding.router.workspace
  end

  def set_subscription_attributes(router, data)
    if data.key?(:key)
      keys_query = ModelUtil.terms_query(Key, [data[:key]])
      key = @workspace.keys.where(keys_query).first!
      router.key = key
    end

    if data.key?(:topics)
      topics_query = ModelUtil.terms_query(Topic, data[:topics])
      topic_ids = @sender_workspace.topics.where(topics_query).select(:id).map(&:id)
      router.topic_ids = topic_ids
    end

    if data.key?(:destination_url)
      router.destination_url = data[:destination_url]
    end

    if data.key?(:name)
      router.name = data[:name]
    end
  end
end
