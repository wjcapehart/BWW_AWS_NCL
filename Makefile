default:	opendap_read

opendap_read:	opendap_read.f90
		gfortran -o opendap_read -I$(NETCDFINC) -L$(NETCDFLIB) -lnetcdff opendap_read.f90
