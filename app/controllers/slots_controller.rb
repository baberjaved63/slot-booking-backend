class SlotsController < ApplicationController
  def index
    if params["date"].present? && params["duration"].to_i > 0
      available_slots = compute_available_slots
      render json: { slots: available_slots }, status: :ok
    else
      render json: { errors: "Invalid inputs" }, status: :not_found
    end
  end

  def create
    slot = Slot.new(slot_params)
    if slot.save
      available_slots = compute_available_slots
      render json: { slots: available_slots }, status: :ok
    else
      render json: { errors: response["error"] }, status: :not_found
    end
  end

  private

  def slot_params
    { start: params["slot"].to_time.utc, end: params["slot"].to_datetime.utc + params["duration"].minutes }
  end

  def compute_available_slots
    datetime = params["date"].to_time
    Slot.compute_slots(datetime, params["duration"])
  end
end