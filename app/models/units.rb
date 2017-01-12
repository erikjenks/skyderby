module Units
  UNITS = {
    metric: {
      speed: 'kmh',
      altitude: 'm',
      distance: 'm'
    },
    imperial: {
      speed: 'mph',
      altitude: 'ft',
      distance: 'mi'
    }
  }.with_indifferent_access.freeze

  def self.[](unit_system)
    UNITS[unit_system]
  end
end
