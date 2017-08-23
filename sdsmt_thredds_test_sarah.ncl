;;; install libraries to manage WRF-specific tasks

load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ; your local directory

  directory = "./"

  ;;; thredds server path to catalog
  url_root  = "http://kyrill.ias.sdsmt.edu:8080/thredds/dodsC/BWW_GENS/"

  ;;; times over which we will be looping

  start_date_string = "2017-01-01"
  end_date_string   = "2017-02-01"

  ;;; time step for forecasts

  hours_between_forecast = 6
     hours_between_forecast@units = "hours"

  ;;; location string

  localle = "UCONUS"

  ;;; title string for graph

  title_string      = "gens_" + localle + "_500mb_"

  start_time          = 0
    start_time@units  = "days since " + start_date_string + " 00:00:00"
  end_time            = 0
    end_time@units    = "days since " +  end_date_string  + " 00:00:00"

  ;;; create a standard time refernece
  time_units = "days since 2016-01-01 00:00:00"

  ; convert time units to our standardized time reference

  start_time_arch = cd_convert(start_time, time_units)
  end_time_arch   = cd_convert(end_time,   time_units)

  time_of_forecast_products = fspan(start_time_arch, end_time_arch, hours_between_forecast)

  ; Crack open a temporary wrf file and grab our study area.  (This will be bigger than our acutal area.)

  initital_setup_url = "http://kyrill.ias.sdsmt.edu:8080/thredds/dodsC/BWW_GENS/2017/01/01/gens003_UCONUS_ALL_2017-01-01_00.wrf_ci_turb.grib2"

  ; crack open file
  f = addfile(initital_setup_url, "r")

   ; extract latitude and longitude
   lat = f->lat
   lon = f->lon

   ; extract geopotential height at 500 hpa (uses Pascals)

   z_500 = f->Geopotential_height_isobaric_ens(:,0,{50000},:,:)

   ; create a plot object
   wks = gsn_open_wks("pdf","ce")                  ; send graphics to PNG file

   ; do the default plot
   res = True
      res@gsnAddCyclic = False
      res@mpMinLonF = min(lon)
      res@mpMaxLonF = max(lon)
      res@mpMinLatF = min(lat)
      res@mpMaxLatF = max(lat)
   plot = gsn_csm_contour_map(wks,z_500(0,:,:),res)      ; create a default plot



end
