begin

  testfile = "https://nomads.ncdc.noaa.gov/thredds/dodsC/gfs-004/201705/20170504/gfs_4_20170504_0600_384.grb2"

  print("file to test: "+testfile)

  f = addfile(testfile, "r")

  printVarSummary(f)

  isobaric_height = f->isobaric1

  printVarSummary(isobaric_height)

  z500 = f->Geopotential_height(:,{50000},:,:)

  printVarSummary(z500)

  print(avg(z500))

end
