FactoryGirl.define do
  factory :weather_datum do
    actual_on Date.today
    altitude { rand(0..4000) }
    wind_speed { rand(0..25) }
    wind_direction { rand(0..359) }
    weather_datumable factory: :event
  end
end
