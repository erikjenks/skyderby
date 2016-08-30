# ||               event_rounds GET    (/:locale)/events/:event_id/rounds(.:format)                rounds#index {:locale=>/en|de|es|ru/}
# ||                            POST   (/:locale)/events/:event_id/rounds(.:format)                rounds#create {:locale=>/en|de|es|ru/}
# ||            new_event_round GET    (/:locale)/events/:event_id/rounds/new(.:format)            rounds#new {:locale=>/en|de|es|ru/}
# ||           edit_event_round GET    (/:locale)/events/:event_id/rounds/:id/edit(.:format)       rounds#edit {:locale=>/en|de|es|ru/}
# ||                event_round GET    (/:locale)/events/:event_id/rounds/:id(.:format)            rounds#show {:locale=>/en|de|es|ru/}
# ||                            PATCH  (/:locale)/events/:event_id/rounds/:id(.:format)            rounds#update {:locale=>/en|de|es|ru/}
# ||                            PUT    (/:locale)/events/:event_id/rounds/:id(.:format)            rounds#update {:locale=>/en|de|es|ru/}
# ||                            DELETE (/:locale)/events/:event_id/rounds/:id(.:format)            rounds#destroy {:locale=>/en|de|es|ru/}
# ||          event_competitors GET    (/:locale)/events/:event_id/competitors(.:format)           competitors#index {:locale=>/en|de|es|ru/}
# ||                            POST   (/:locale)/events/:event_id/competitors(.:format)           competitors#create {:locale=>/en|de|es|ru/}
# ||       new_event_competitor GET    (/:locale)/events/:event_id/competitors/new(.:format)       competitors#new {:locale=>/en|de|es|ru/}
# ||      edit_event_competitor GET    (/:locale)/events/:event_id/competitors/:id/edit(.:format)  competitors#edit {:locale=>/en|de|es|ru/}
# ||           event_competitor GET    (/:locale)/events/:event_id/competitors/:id(.:format)       competitors#show {:locale=>/en|de|es|ru/}
# ||                            PATCH  (/:locale)/events/:event_id/competitors/:id(.:format)       competitors#update {:locale=>/en|de|es|ru/}
# ||                            PUT    (/:locale)/events/:event_id/competitors/:id(.:format)       competitors#update {:locale=>/en|de|es|ru/}
# ||                            DELETE (/:locale)/events/:event_id/competitors/:id(.:format)       competitors#destroy {:locale=>/en|de|es|ru/}
# ||         event_event_tracks GET    (/:locale)/events/:event_id/event_tracks(.:format)          event_tracks#index {:locale=>/en|de|es|ru/}
# ||                            POST   (/:locale)/events/:event_id/event_tracks(.:format)          event_tracks#create {:locale=>/en|de|es|ru/}
# ||      new_event_event_track GET    (/:locale)/events/:event_id/event_tracks/new(.:format)      event_tracks#new {:locale=>/en|de|es|ru/}
# ||     edit_event_event_track GET    (/:locale)/events/:event_id/event_tracks/:id/edit(.:format) event_tracks#edit {:locale=>/en|de|es|ru/}
# ||          event_event_track GET    (/:locale)/events/:event_id/event_tracks/:id(.:format)      event_tracks#show {:locale=>/en|de|es|ru/}
# ||                            PATCH  (/:locale)/events/:event_id/event_tracks/:id(.:format)      event_tracks#update {:locale=>/en|de|es|ru/}
# ||                            PUT    (/:locale)/events/:event_id/event_tracks/:id(.:format)      event_tracks#update {:locale=>/en|de|es|ru/}
# ||                            DELETE (/:locale)/events/:event_id/event_tracks/:id(.:format)      event_tracks#destroy {:locale=>/en|de|es|ru/}
# ||              results_event GET    (/:locale)/events/:id/results(.:format)                     events#results {:locale=>/en|de|es|ru/}
# ||                     events GET    (/:locale)/events(.:format)                                 events#index {:locale=>/en|de|es|ru/}
# ||                            POST   (/:locale)/events(.:format)                                 events#create {:locale=>/en|de|es|ru/}
# ||                  new_event GET    (/:locale)/events/new(.:format)                             events#new {:locale=>/en|de|es|ru/}
# ||                 edit_event GET    (/:locale)/events/:id/edit(.:format)                        events#edit {:locale=>/en|de|es|ru/}
# ||                      event GET    (/:locale)/events/:id(.:format)                             events#show {:locale=>/en|de|es|ru/}
# ||                            PATCH  (/:locale)/events/:id(.:format)                             events#update {:locale=>/en|de|es|ru/}
# ||                            PUT    (/:locale)/events/:id(.:format)                             events#update {:locale=>/en|de|es|ru/}
# ||                            DELETE (/:locale)/events/:id(.:format)