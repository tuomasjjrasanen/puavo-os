define [
  "jquery"
  "underscore"
  "backbone"
  "socket.io"
  "cs!app/models/wlanhostmodel"
  "cs!app/models/schoolmodel"
  "cs!app/models/wlanclientcollection"
  "cs!app/views/lightbox"
  "cs!app/views/mainlayout"
], (
  $
  _
  Backbone
  io
  WlanHostModel
  SchoolModel
  WlanClientCollection
  Lightbox
  MainLayout
) -> $ ->

  [__, org, schoolId] = window.location.pathname.split("/")

  $(".organisation").text org

  schoolModel = new SchoolModel
    name: org

  loading = $(".loading")

  clients = new WlanClientCollection

  historySize = 2000

  loading.text "Loading #{ historySize } entries from history..."
  $.get "/log/#{ org }/#{ schoolId }/wlan?limit=#{ historySize }", (logArr, status, res) ->

    if status isnt "success"
      console.info res
      throw new Error "failed to fetch previous log data"

    console.info "Loaded #{ logArr.length } entries from db"

    loading.text "Updating models..."
    for packet in logArr
      schoolModel.logEvent()
      clients.update packet

    layout = new MainLayout
      clients: clients
      model: schoolModel

    layout.render()
    $("body").append layout.el

    console.info "Render complete"

    loading.text "Connecting to real time events..."

    Backbone.history.start
      pushState: true
      root: "/#{ org }/#{ schoolId }/wlan/"

    socket = io.connect()

    collName = "log:#{ org }:wlan"
    console.info "Listening #{ collName }"

    socket.on collName, (packet) ->
      console.info "#{ packet.mac } #{ packet.event } to/from #{ packet.hostname }", packet
      schoolModel.logEvent()
      clients.update packet

    socket.on "connect", ->
      loading.remove()
      console.info "Connected to websocket server"



