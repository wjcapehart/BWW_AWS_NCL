# test of opendap with fortran netcdf code

default :	opendap_read

opendap_read :	opendap_read.f90
		gfortran -o opendap_read -I$(NETCDFINC) -L$(NETCDFLIB) -lnetcdff opendap_read.f90

debug :	opendap_read.f90
				gfortran -ggdb -o opendap_read -I$(NETCDFINC) -L$(NETCDFLIB)  -lnetcdff opendap_read.f90

clean :
	rm opendap_read
