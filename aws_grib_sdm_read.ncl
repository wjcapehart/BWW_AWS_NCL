load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  directory = "./"

  url_root  = "http://52.27.3.199:8080/thredds/dodsC/processed/"

  start_date_string = "2017-04-01"
  end_date_string   = "2017-04-17"

  localle = "smt"

  title_string      = "bww_" + localle + "_500mb_"

  start_time          = 0
    start_time@units  = "days since " + start_date_string + " 00:00:00"
  end_time            = 0
    end_time@units    = "days since " +  end_date_string  + " 00:00:00"

  time_units = "days since 2016-01-01 00:00:00"


   member_table_name = (/ "alb", \
                          "csu", \
                          "psu", \
                          "smt", \
                          "ttu", \
                          "und", \
                          "uwm" /)

   member_table_nens = (/ 13, \
                          01, \
                          09, \
                          03, \
                          08, \
                          04, \
                          09 /)

   ne = member_table_nens(ind(member_table_name .eq. localle))


  start_time_arch = cd_convert(start_time, time_units)
  end_time_arch   = cd_convert(end_time,   time_units)

  nt = toint(end_time_arch-start_time_arch)+1

  ; Crack open a temporary wrf file and grab our study area.  (This will be bigger than our acutal area.)

  initital_setup_url = "http://52.27.3.199:8080/thredds/dodsC/processed/170428/smt01_17042800.grb"

  f = addfile(initital_setup_url, "r")


  latw = f->XLAT(0,:,:)
  lonw = f->XLONG(0,:,:)

  ;;; local region to clip
  lat_min = 34. ; degrees North
  lat_max = 55. ; degrees North

  lon_min = 247. - 360. ; degrees East
  lon_max = 268. - 360.; degrees East

  wrf_region_ind = region_ind(latw,lonw,lat_min,lat_max,lon_min,lon_max)

  i_min = wrf_region_ind(2)
  i_max = wrf_region_ind(3)
  j_min = wrf_region_ind(0)
  j_max = wrf_region_ind(1)

  delete(latw)
  delete(lonw)

  longitude = f->XLONG(0, j_min:j_max, i_min:i_max)
  latitude  = f->XLAT( 0, j_min:j_max, i_min:i_max)

  delete(f)

    delete(latitude@_ChunkSizes)
    delete(latitude@stagger)
    delete(latitude@MemoryOrder)
    delete(latitude@coordinates)
    delete(latitude@FieldType)

    delete(longitude@_ChunkSizes)
    delete(longitude@stagger)
    delete(longitude@MemoryOrder)
    delete(longitude@coordinates)
    delete(longitude@FieldType)

  longitude@description = "Longitude"
  latitude@description  = "Latitude"

  longitude@long_name = "Longitude"
  latitude@long_name  = "Latitude"

  longitude@standard_name = "longitude"
  latitude@standard_name  = "latitude"


   nx_wrf = i_max - i_min + 1
   ny_wrf = j_max - j_min + 1


   forecast_time               = ispan(0, 84, 3)
   forecast_time!0             = "forecast_time"
   forecast_time&forecast_time = forecast_time
   forecast_time@units         = "hours"
   forecast_time@description   = "Hours Into Forecast"
   forecast_time@long_name     = forecast_time@description

   nt_wrf = dimsizes(forecast_time)

   time_steps = ispan(0, nt_wrf-1, 1)

   ensemble_member = "psu"+sprinti("%0.2i",ispan(1,ne,1))
   ensemble_member!0 = "ensemble_member"
   ensemble_member&ensemble_member = ensemble_member
   ensemble_member@description = "Ensemble ID"
   ensemble_member@long_name   = "Ensemble ID"

   isobaric_height                 = (/ 500. /)
   isobaric_height!0               = "isobaric_height"
   isobaric_height&isobaric_height = isobaric_height
   isobaric_height@description     = "Isobaric Height"
   isobaric_height@long_name       =  isobaric_height@description
   isobaric_height@standard_name   = "pressure"
   isobaric_height@positive        = "down"
   isobaric_height@unit            = "hPa"


   product_interval  = 3
      product_interval@units = "day"

   time = fspan(start_time_arch, end_time_arch, nt)
      time@description   = "time"
      time@long_name     = "time"
      time@standard_name = "time"
      time@calendar      = "standard"
      time@units         = time_units
      time!0             = "time"
      time&time          = time




   z_500_arch = new((/ nt, ne, nt_wrf, 1, ny_wrf, nx_wrf /), float)
      printVarSummary(z_500_arch)
      printVarSummary(ensemble_member)
      printVarSummary(forecast_time)
      z_500_arch!0               = "time"
      z_500_arch!1               = "ensemble_member"
      z_500_arch!2               = "forecast_time"
      z_500_arch!3               = "isobaric_height"
      z_500_arch!4               = "south_north"
      z_500_arch!5               = "west_east"
      z_500_arch&time            = time
      z_500_arch&ensemble_member = ensemble_member
      z_500_arch&forecast_time   = forecast_time
      z_500_arch&isobaric_height = isobaric_height
      z_500_arch@description     = "Geopotential Height"
      z_500_arch@long_name       =  z_500_arch@description
      z_500_arch@standard_name   = "geopotential_height"
      z_500_arch@units           = "m"

   do t = 0, nt-1

      do e = 0, ne-1

         date_decompose = cd_calendar(time(t), -5)

         member = localle + sprinti("%0.2i", (e+1))

         day_dir = sprinti("%0.2i",      date_decompose(0,0)-2000) + \
                   sprinti("%0.2i",      date_decompose(0,1))      + \
                   sprinti("%0.2i",      date_decompose(0,2))

         urlfile1 =  url_root  + \
                     "/"       + \
                     day_dir   + \
                     "/"       + \
                     member    + \
                     day_dir   + \
                     "00.grb"

         print(" - "+member+ "_" + file_date )



          z_500_arch(t, e, :, 1, :, :) = f->Geopotential_height_isobaric(:,{500},j_min:j_max, i_min:i_max)

          print(avg(z_500_arch(t, e, :, 1, :, :)))

      end do

   end do

end
