class Skyderby.views.RoundGlobeView extends Backbone.View

  lines_by_competitor: {}

  events:
    'change input': 'on_change_visibility'

  initialize: ->
    @listenToOnce(Skyderby, 'cesium_api:ready', @on_maps_api_ready)
    @listenToOnce(Skyderby, 'cesium_api:failed', @on_maps_api_failed)
    Skyderby.helpers.init_cesium_api()

  on_maps_api_failed: ->

  on_maps_api_ready: ->
    @setup_viewer()
    @draw_competitors()

    @$('.round-map-loading').hide()

  setup_viewer: ->
    @viewer = new Cesium.Viewer(@$('#cesium-container')[0],
      infoBox: false,
      homeButton: false,
      baseLayerPicker: false,
      geocoder: false,
      sceneModePicker: false,
      selectionIndicator: false,
      scene3DOnly: true
    )

    terrainProvider = new Cesium.CesiumTerrainProvider(
      url : '//assets.agi.com/stk-terrain/world'
    )
    @viewer.terrainProvider = terrainProvider
 
  draw_competitors: ->
    for competitor_data in @data
      console.log(competitor_data)
