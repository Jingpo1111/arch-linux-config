-- Float rules
hl.window_rule({ match = { class = "^de\\.haeckerfelix\\.Shortwave$" },                   float = true })
hl.window_rule({ match = { class = "^Signal$" },                                          float = true })
hl.window_rule({ match = { class = "^com\\.github\\.rafostar\\.Clapper$" },               float = true })
hl.window_rule({ match = { class = "^app\\.drey\\.Warp$" },                               float = true })
hl.window_rule({ match = { class = "^net\\.davidotek\\.pupgui2$" },                       float = true })
hl.window_rule({ match = { class = "^yad$" },                                             float = true })
hl.window_rule({ match = { class = "^eog$" },                                             float = true })
hl.window_rule({ match = { class = "^io\\.github\\.alainm23\\.planify$" },                float = true })
hl.window_rule({ match = { class = "^io\\.gitlab\\.theevilskeleton\\.Upscaler$" },        float = true })
hl.window_rule({ match = { class = "^com\\.github\\.unrud\\.VideoDownloader$" },          float = true })
hl.window_rule({ match = { class = "^io\\.gitlab\\.adhami3310\\.Impression$" },           float = true })
hl.window_rule({ match = { class = "^io\\.missioncenter\\.MissionCenter$" },              float = true, size = "1290 950"})
hl.window_rule({ match = { class = "^org\\.pulseaudio\\.pavucontrol$" },                  float = true, size = "1221 619", })
hl.window_rule({ match = { title = "^File Operation Progress$" },                         float = true, size = "600 50", })
hl.window_rule({ match = { class = "^xfce-polkit$" },                                     float = true, size = "600 50", })
hl.window_rule({ match = { class = "^blueman-manager$" },                                 float = true, size = "600 300", })
hl.window_rule({ match = { title = "^Choose files to upload$" },                          float = true, size = "800 500", no_anim = true, no_shadow = true, border_size = 0, no_blur = true, center = 1, })
hl.window_rule({ match = { title = "^All Files$" },                                       float = true, size = "800 600", })
hl.window_rule({ match = { title = "^Affinity Photo 2$" },                                no_anim = true, no_shadow = true, border_size = 0, no_blur = true, no_dim = true, immediate = true, decorate = false, opaque = true, tonemap = off, })


hl.window_rule({ match = { class = "^[Ss]team$", title = "^Steam Settings$" }, float = true })
hl.window_rule({ match = { class = "^[Ss]team$", title = "^Friends List$" }, float = true })


-- Idle inhibit rules
hl.window_rule({ match = { class = "^(.*celluloid.*|.*mpv.*|.*vlc.*)$" },                                                                                            idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "^.*[Ss]potify.*$" },                                                                                                             idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "^(.*LibreWolf.*|.*floorp.*|.*brave-browser.*|.*firefox.*|.*chromium.*|.*zen.*|.*vivaldi.*)$" },                                  idle_inhibit = "fullscreen" })

-- Picture-in-picture
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture).*$" }, tag = "picture-in-picture" })
hl.window_rule({ match = { tag = "picture-in-picture" }, float = true, pin = true, keep_aspect_ratio = true, move = "73% 72%", size = "25% 25%" })

-- Misc rules
hl.window_rule({ match = { class = "^.*jetbrains.*$", title = "^win[0-9]+$" }, no_initial_focus = true })

