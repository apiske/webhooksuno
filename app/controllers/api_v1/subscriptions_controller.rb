# frozen_string_literal: true

class ApiV1::SubscriptionsController < ApiController
  before_action :fetch_subscription, only: [:show, :update]
  before_action :process_subscriptions_input, only: [:update, :create]

  requires_workspace_capability :receiver

  def index
    render_collection_paginated(@workspace.subscriptions)
  end

  def show
    render_single(@subscription)
  end

  def create
    @subscription = Subscription.new
    @subscription.attributes = @processor.values_for_model
    @subscription.state = Subscription::State[:active]
    @subscription.receiver_binding = @receiver_binding
    @subscription.router = @receiver_binding.router
    @subscription.destination_type = Subscription::DestinationType[:https]
    @subscription.workspace = @workspace

    return unless with_common_record_checks do
      @subscription.save!
    end

    render_single(@subscription, :created)
  end

  def update
    @subscription.attributes = @processor.values_for_model

    if @subscription.receiver_binding_id_changed?
      binding_attr = @processor.api_definition.attrs['binding']
      @processor.add_error_fmt(binding_attr, nil,
        "The binding attribute cannot be changed after the Subscription is created")
    end

    return if fail_on_invalid_processor!(@processor)

    return unless with_common_record_checks do
      @subscription.save!
    end

    render_single(@subscription)
  end

  private

  def fetch_subscription
    uuid = UuidUtil.uuid_s_to_bin(params[:id])

    @subscription = @workspace.subscriptions
      .eager_load(:receiver_binding)
      .find_by!(public_id: uuid)
  end

  def processor_entity_name
    :subscription
  end

  def process_input(*args)
    return if fail_on_invalid_body_payload!

    @processor = Apidef::Processor.new(
      action_name,
      api_ctx,
      processor_entity_name,
      ref_solver)
    @processor.process_input(body_obj["data"])

    fail_on_invalid_processor!(@processor)
  end

  def process_subscriptions_input
    return if process_input

    receiver_binding_id = @processor.values_for_model[:receiver_binding_id]
    @receiver_binding = @workspace.receiver_bindings.find(receiver_binding_id)

    @sender_workspace = @receiver_binding.router.workspace
    topics_attr = @processor.api_definition.attrs['topics']
    topic_ref_solver = ReferenceSolver.new(@sender_workspace)
    topics_raw_value = @processor.raw_values['topics']
    topic_ids, errors = topics_attr.type.raw_to_final_value(
      topics_attr,
      topics_raw_value,
      @processor,
      ref_solver: topic_ref_solver)

    errors.each do |err|
      @processor.add_error_fmt(topics_attr, topics_raw_value, err)
    end

    return if fail_on_invalid_processor!(@processor)

    @processor.set_attr_value(topics_attr, topic_ids)
  end
end
