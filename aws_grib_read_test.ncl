begin

  testfile = "http://52.27.3.199:8080/thredds/dodsC/processed/170428/smt01_17042800.grb"
  
  f = addfile(testfile, "r")
  
  print(f)


end
