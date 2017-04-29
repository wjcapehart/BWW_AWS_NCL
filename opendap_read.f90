program test_opendap

  use netcdf
  implicit none

  integer, parameter :: NT=12

  real, dimension(NT) :: time

  integer :: ncstat             ! generic netcdf status return variable
  integer :: netcdf_id_file     ! netcdf file id
  integer :: netcdf_id_time     ! netcdf lon variable ID


  character (len=*), parameter :: opendap_file_url =  &
                                  "http://test.opendap.org/opendap/data/nc/3fnoc.nc"

  print*, "testing file " // opendap_file_url

  ncstat =  nf90_open(opendap_file_url, &
                      NF90_NOWRITE,     &
                      netcdf_id_file)

  print*, "nf90_open " , netcdf_id_file

  ncstat =  nf90_inq_varid(netcdf_id_file, &
                           "time",         &
                           netcdf_id_time)

  print*, "nf90_inq_varid " , netcdf_id_time

  ncstat =  nf90_get_var(netcdf_id_file, &
                         netcdf_id_time, &
                         time)

  print*, "nf90_get_var " , time


end program test_opendap
