#
#	Broadband Status
#	LIBRARY
#		Alerts
#
#	Author: Lee Thompson <thompsonl@logh.net>
#
#=============================================================================
# to do:
#	make library
#		smtp
#		growl/etc
#		snmp ?
#
#=============================================================================

#=============================================================================
#	Developer Notes
#=============================================================================
#
#=============================================================================

use strict;
use warnings;

use constant{
	ALERTS_LIBRARY_NAME => "alerts",
	ALERTS_LIBRARY_DESCRIPTION => "alerting",
	ALERTS_LIBRARY_VERSION => "YYYYMMDDHHMM",
};


1;


#-----------------------------------------------------------
# External Methods
#-----------------------------------------------------------
sub alertsGetName{
	return ALERTS_LIBRARY_NAME;
}

sub alertsGetDescription{
	return ALERTS_LIBRARY_DESCRIPTION;
}

sub alertsGetVersion{
	return ALERTS_LIBRARY_VERSION;
}


