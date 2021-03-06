begin

  testfile = "http://52.27.3.199:8080/thredds/dodsC/processed/170428/smt01_17042800.grb"

  print("file to test: "+testfile)

  f = addfile(testfile, "r")

  printVarSummary(f)

  isobaric_height = f->isobaric1

  printVarSummary(isobaric_height)

  z500 = f->Geopotential_height_isobaric(:,{500},:,:)

  printVarSummary(z500)

  print(avg(z500))

end
