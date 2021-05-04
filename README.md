
= Lessons Learned

* Make sure the toolpaths go a bit deeper than the stock if you are cutting
  all the way through - maybe 0.5mm for wood

* Fix the toolchange gcode to allow you to jog/move the mill to re-set the z
  axis height 

* Include a waterline pass with a straight-tool (i.e. not a tapered dia tool) so
  that you can get full-depth features' contours traced correctly.

* Would be super nice to get the spindle to turn off when the job is done -
  get a relay/switch to hook up to the buildbotics controller.

* get your stock super close to part(s) thickness before you start milling -
  it will save so much time.

* don't forget to account for tool taper on really small diameter tools -
  limits your cutting depth to pretty shallow.

* limit switches would be nice - but not as nice as a tool height setting
  probe/device for tool changes

* use exclude regions in finishing toolpaths to avoid re-going over large flat
  surfaces that were already good from a larger tool or earlier pass.

