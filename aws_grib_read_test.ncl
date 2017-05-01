begin

  testfile = "http://52.27.3.199:8080/thredds/catalog/runs/smt01/170428/catalog.html?dataset=BWWS3/smt01/170428/smt01_17042800.grb"
  
  f = addfile(testfile, "r")
  
  print(f)


end
