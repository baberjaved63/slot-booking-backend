class Slot < ApplicationRecord
  def self.compute_slots(date, duration)
    date = date.midnight if date.to_datetime > DateTime.now.to_datetime
    date = time_to_next_quarter_hour(date).change(sec: 0)

    slots = all_slots(date)
    starting_slots = Slot.where(start: date.midnight..date.end_of_day)
    ending_slots = Slot.where(end: date.midnight..date.end_of_day)
    records_slots = (starting_slots + ending_slots).uniq.pluck(:start, :end)
    counter = 0
    number_of_quaters = (duration.to_f / 15).ceil
    reserved_slots = []

    while slots.count > counter
      possible_slot_indices = (counter..counter+number_of_quaters)
      possible_slots = slots[possible_slot_indices]
      counter_changed = false

      possible_slots.each_with_index do |p_slot, index|
        next if !(records_slots.any? { |r| r.first <= p_slot && r.last > p_slot })

        reserved_slots = possible_slots[0..index]
        counter_changed = true
      end
      if counter_changed
        slots -= reserved_slots
        counter -= 1
      end

      counter += 1
    end

    slots
  end

  private

  def self.all_slots(date)
    [date].tap { |array| array << array.last + 15.minutes while array.last < date.next_day }
  end

  def self.time_to_next_quarter_hour(time)
    array = time.to_a
    quarter = ((array[1] % 60) / 15.0).ceil
    array[1] = (quarter * 15) % 60
    Time.utc(*array) + (quarter == 4 ? 3600 : 0)
  end

  def self.extract(arr, first, last)
    return nil unless ([first, last]-arr).empty? && arr.index(first) <= arr.index(last)
    arr.select { |s| s==first..s==last ? true : false }
  end
end
