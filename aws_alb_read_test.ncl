load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;;;  suny albany customized

begin

  directory = "./"

  ;;; fix me!!!
  url_root  = "http://52.27.3.199:8080/thredds/dodsC/runs/"

  start_date_string = "2016-02-01"
  end_date_string   = "2017-04-26"

  localle = "alb"

  title_string      = "bww_" + localle + "_500mb_"

  start_time          = 0
    start_time@units  = "days since " + start_date_string + " 00:00:00"
  end_time            = 0
    end_time@units    = "days since " +  end_date_string  + " 00:00:00"

  time_units = "days since 2016-01-01 00:00:00"

   member_dir_name   = (/ "alb", \
                          "csu", \
                          "psu", \
                          "sdm", \
                          "ttu", \
                          "und", \
                          "uwm" /)

   member_table_name = (/ "alb", \
                          "csu", \
                          "psu", \
                          "smt", \
                          "ttu", \
                          "und", \
                          "uwm" /)

   member_table_nens = (/ 13-1, \
                          01, \
                          09, \
                          03, \
                          08, \
                          04, \
                          09 /)

   member_table_pinterval = (/ 01, \
                               01, \
                               03, \
                               03, \
                               03, \
                               03, \
                               03 /)

   university = ind(member_table_name .eq. localle)

   ne = member_table_nens(university)

   product_interval = member_table_pinterval(university)
      product_interval@units = "day"

  start_time_arch = cd_convert(start_time, time_units)
  end_time_arch   = cd_convert(end_time,   time_units)

  nt = toint(end_time_arch-start_time_arch)+1

  ; Crack open a temporary wrf file and grab our study area.  (This will be bigger than our acutal area.)

  initital_setup_url = "http://52.27.3.199:8080/thredds/dodsC/runs/alb10/170602/alb10_17060200.nc4"

  f = addfile(initital_setup_url, "r")


  latw = f->$"latitude_-90_to_and90_surface"$(0,:,:)
  lonw = f->$"east_longitude_0-360_surface"$(0,:,:)

  ;;; local region to clip
  lat_min = 34. ; degrees North
  lat_max = 55. ; degrees North

  lon_min = 247. ; degrees East
  lon_max = 268. ; degrees East

  wrf_region_ind = region_ind(latw,lonw,lat_min,lat_max,lon_min,lon_max)

  i_min = wrf_region_ind(2)
  i_max = wrf_region_ind(3)
  j_min = wrf_region_ind(0)
  j_max = wrf_region_ind(1)

  delete(latw)
  delete(lonw)

  longitude = f->$"latitude_-90_to_and90_surface"$(0, j_min:j_max, i_min:i_max)
  latitude  = f->$"east_longitude_0-360_surface"$( 0, j_min:j_max, i_min:i_max)

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

   ensemble_member = localle+sprinti("%0.2i",ispan(1,ne,1))
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




   time = fspan(start_time_arch, end_time_arch, nt)
      time@description   = "time"
      time@long_name     = "time"
      time@standard_name = "time"
      time@calendar      = "standard"
      time@units         = time_units
      time!0             = "time"
      time&time          = time




   z_500_arch = new((/ ne, nt, nt_wrf, 1, ny_wrf, nx_wrf /), float)
      z_500_arch!1               = "time"
      z_500_arch!0               = "ensemble_member"
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
      delete(z_500_arch@Isobaric)
      delete(z_500_arch@Grib1_Level_Type)
      delete(z_500_arch@Grib1_Parameter_Name)
      delete(z_500_arch@Grib1_Parameter)
      delete(z_500_arch@Grib1_TableVersion)
      delete(z_500_arch@Grib1_Subcenter)
      delete(z_500_arch@Grib1_Center)
      delete(z_500_arch@Grib_Variable_Id)
      delete(z_500_arch@coordinates)
      delete(z_500_arch@isobaric1)
      delete(z_500_arch@_FillValue)
      delete(z_500_arch@missing_value)
      delete(z_500_arch@grid_mapping)
      print(getFillValue(z_500_arch))
      z_500_arch@_FillValue           = getFillValue(new((/10/), float))
      z_500_arch@coordinates      = "time isobaric_height latitdue longitude"
   printVarSummary(z_500_arch)


   delete(latitude@missing_value)
   delete(latitude@grid_mapping)
   delete(latitude@Grib1_Level_Desc)
   delete(latitude@Grib1_Parameter_Name)
   delete(latitude@Grib1_Parameter)
   delete(latitude@Grib1_TableVersion)
   delete(latitude@Grib1_Subcenter)
   delete(latitude@Grib1_Center)
   delete(latitude@Grib_Variable_Id)
   delete(latitude@Grib1_Level_Type)
   delete(latitude@coordinates)
   delete(latitude@time1)
   delete(latitude@_FillValue)
   latitude@units = "degrees north"


   delete(latitude@missing_value)
   delete(latitude@grid_mapping)
   delete(latitude@Grib1_Level_Desc)
   delete(latitude@Grib1_Parameter_Name)
   delete(latitude@Grib1_Parameter)
   delete(latitude@Grib1_TableVersion)
   delete(latitude@Grib1_Subcenter)
   delete(latitude@Grib1_Center)
   delete(latitude@Grib_Variable_Id)
   delete(latitude@Grib1_Level_Type)
   delete(latitude@coordinates)
   delete(latitude@time1)
   delete(latitude@_FillValue)
   latitude@units = "degrees north"


   do t = 0, nt-1, product_interval

      do e = 0, ne-1

         date_decompose = cd_calendar(time(t), -5)

         member = localle + sprinti("%0.2i", (e+1))

         day_dir = sprinti("%0.2i",      date_decompose(0,0)-2000) + \
                   sprinti("%0.2i",      date_decompose(0,1))      + \
                   sprinti("%0.2i",      date_decompose(0,2))

         urlfile1 =  url_root                    + \
                     member                      + \
                     "/"                         + \
                     day_dir                     + \
                     "/"                         + \
                     member                      + \
                     "_"                         + \
                     day_dir                     + \
                     "00.nc4"

         print(" - " + member+ "_" + day_dir )
         print(" "   + urlfile1)

         if (isfilepresent(urlfile1)) then

            f = addfile(urlfile1, "r")
            print(f)
            print("reading "+member + \
                           "_"                         + \
                          day_dir                     + \
                         "00.nc4")

            z_500_arch(e, t, :, 0, :, :) = (/ f->Geopotential_height_isobaric(:,{500},j_min:j_max, i_min:i_max) /)

         else

            ; begin wrf (all data in one file) search : albEE_YYMMDDHH.nc

            urlfile1 =  url_root                    + \
                        member + \
                        "/"                         + \
                        day_dir                     + \
                        "/"                         + \
                        member                      + \
                        "_"                         + \
                        day_dir                     + \
                        "00.nc"

            if (isfilepresent(urlfile1)) then

               f = addfile(urlfile1, "r")
               print("      reading height")
               z4d = wrf_user_getvar(f,    "z", -1)
               print("      reading pressure")
               p4d = wrf_user_getvar(f, "pres", -1)
               print("      interpolating to 500hPa")

               z_500_arch(e, t, :, 0, :, :) = (/ wrf_user_intrp3d(z3d(:,:,j_min:j_max, i_min:i_max), \
                                                                              p3d(:,:,j_min:j_max, i_min:i_max), \
                                                                              "h", 500.0, 0., False) /)

            else

               ; traditional wrf single hour files, wrfout_d01_yyyy-mm-dd_00:00:00

               ;local_time = time(t) + forecast_time(h)/24.
            ;      local_time@units = time_units

               wrf_fx_decompose = cd_calendar(time(t), -5)

               local_time := sprinti("%0.4i-", wrf_fx_decompose(0,0)) + \
                             sprinti("%0.2i-", wrf_fx_decompose(0,1)) + \
                             sprinti("%0.2i_", wrf_fx_decompose(0,2)) + \
                             sprinti("%0.2i:", wrf_fx_decompose(0,3)) + \
                             sprinti("%0.2i:", wrf_fx_decompose(0,4)) + \
                             sprinti("%0.2i",  wrf_fx_decompose(0,5))

               urlfile1 =  url_root                    + \
                           member                       + \
                           "/"                         + \
                           day_dir                     + \
                           "/"                         + \
                           "wrfout_d01_"               + \
                           "_"                         + \
                           local_time

               if (isfilepresent(urlfile1)) then

                  do hh = 0, nt_wrf, 1
                     local_time := sprinti("%0.4i-", wrf_fx_decompose(hh,0)) + \
                                   sprinti("%0.2i-", wrf_fx_decompose(hh,1)) + \
                                   sprinti("%0.2i_", wrf_fx_decompose(hh,2)) + \
                                   sprinti("%0.2i:", wrf_fx_decompose(hh,3)) + \
                                   sprinti("%0.2i:", wrf_fx_decompose(hh,4)) + \
                                   sprinti("%0.2i",  wrf_fx_decompose(hh,5))

                     urlfile1 =  url_root                    + \
                                  member                      + \
                                  "/"                         + \
                                  day_dir                     + \
                                  "/"                         + \
                                  "wrfout_d01_"               + \
                                  "_"                         + \
                                  local_time


                     f = addfile(urlfile1+".nc", "r")

                     z4d = wrf_user_getvar(f,    "z", 0)
                     p4d = wrf_user_getvar(f, "pres", 0)

                     z_500_arch(e, t, hh, 0, :, :) = (/ wrf_user_intrp3d(z3d(:,j_min:j_max, i_min:i_max), \
                                                                         p3d(:,j_min:j_max, i_min:i_max), \
                                                                         "h", 500.0, 0., False) /)


                  end do
               end if
            end if
         end if
         print(day_dir+" "+avg(z_500_arch(e, t, :, 0, :, :)))
      end do
   end do



   setfileoption("nc", "Format",  "NetCDF4")

   file_output_name = directory + "./" + title_string + start_date_string + "_" + end_date_string + ".nc"

   system("rm -frv "+file_output_name)
   fout = addfile(file_output_name,"c")
   fout->time = time

   delete(fout)

   print(" Processing NCKS Command:  ncks -D 3 -h --mk_rec_dmn time "+ file_output_name + " temp.nc")
   system(" ncks -D 3 -h --mk_rec_dmn time "+ file_output_name + " temp.nc")
   print(" Processing Move Command:   mv -v temp.nc " + file_output_name)
   system(" mv -v temp.nc " + file_output_name)
   print(" Processing NcDump Command:  $NETCDF/bin/ncdump -h  "+ file_output_name)
   system(" $NETCDF/bin/ncdump -h  "+ file_output_name)
   print(file_output_name)
   fout = addfile(file_output_name, "rw")
   print(fout)
   fout@title                      = "Big Weather Web WRF Ensemble Files Northern Great Plains"
   fout@institution                = "SD School of Mines"
   fout@source                     = "Big Weather Web Project"
   fout@references                 = "http://www.bigweatherweb.org"
   fout@start_date                 = start_date_string
   fout@end_date                   = end_date_string
   fout@map_projection             = "lambert_conformal_conic"
   fout@dx                         = 20000.0
   fout@dy                         = 20000.0
   fout@dt                         =    90.0
   fout@central_latitude           =    39.5
   fout@central_lontitude          =   -98.5
   fout@reference_latitude_1       =    39.5
   fout@reference_latitude_2       =    39.5
   fout@subset_southwest_latitude  = latitude(0,0)
   fout@subset_southwest_longitude = longitude(0,0)
   fout@subset_southeast_latitude  = latitude(0,nx_wrf-1)
   fout@subset_southeast_longitude = longitude(0,nx_wrf-1)
   fout@subset_northwest_latitude  = latitude(ny_wrf-1,0)
   fout@subset_northwest_longitude = longitude(ny_wrf-1,0)
   fout@subset_northeast_latitude  = latitude(ny_wrf-1,nx_wrf-1)
   fout@subset_northeast_longitude = longitude(ny_wrf-1,nx_wrf-1)
   fout->ensemble_member           = ensemble_member
   fout->forecast_time             = forecast_time
   fout->isobaric_height           = isobaric_height
   fout->latitude                  = latitude
   fout->longitude                 = longitude
   fout->geopotential_height       = z_500_arch

   delete(fout)

   system("$NETCDF/bin/nccopy -k 3 -d 9  " + file_output_name + " " +file_output_name+"4")
   if (isfilepresent(file_output_name+"4")) then
      system("rm -v " + file_output_name )
   end if



end
