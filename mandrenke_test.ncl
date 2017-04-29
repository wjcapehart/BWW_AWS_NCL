begin

  fname = "http://test.opendap.org/opendap/data/nc/3fnoc.nc"
  f     = addfile(fname,"r")
  print(f)
  time = f->time
  print(time)

end
