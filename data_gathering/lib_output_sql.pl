#
#	Broadband Status
#	LIBRARY
#		Output
#
#	Author: Lee Thompson <thompsonl@logh.net>
#
#=============================================================================

#=============================================================================
#	Developer Notes
#=============================================================================
# 	This is a prototype library for reporting to SQL
#
#	This has a lot of hard coding for now and a dirty hack.
#=============================================================================

use DBI;

use strict;
use warnings;

use constant{
	NO_DATA => "!!!",

	OUTPUT_LIBRARY_NAME => "output_sql",
	OUTPUT_LIBRARY_DESCRIPTION => "SQL Reporter",
	OUTPUT_LIBRARY_VERSION => "201607201618",

	OUTPUT_OPT_SQL_DBI_DRIVER => "mysql",
	OUTPUT_OPT_SQL_DBI_RAISE_ERROR => 1,

	OUTPUT_OPT_SQL_ADDRESS => "localhost",
	OUTPUT_OPT_SQL_PORT => 3306,
	OUTPUT_OPT_SQL_USER => "root",
	OUTPUT_OPT_SQL_PASSWORD => "hammond",

	OUTPUT_OPT_SQL_MODEM_ID => 1,
	OUTPUT_OPT_SQL_CIRCUIT_ID => 1,
	OUTPUT_OPT_SQL_WAN_ID => 1,
	
	OUTPUT_OPT_SQL_DATABASE => "network",
	OUTPUT_OPT_SQL_STATUS_TABLE => "status",

	SCHEMA_STATUS_ID => "status_id",
	SCHEMA_STATUS_TIME => "status_time",
	SCHEMA_STATUS_WAN_ID => "wan_id",
	SCHEMA_STATUS_CIRCUIT_ID => "circuit_id",
	SCHEMA_STATUS_MODEM_ID => "modem_id",

	SCHEMA_STATUS_DOWNSTREAM_FREQUENCY => "downstream_frequency",
	SCHEMA_STATUS_DOWNSTREAM_MODULATION => "downstream_modulation",
	SCHEMA_STATUS_DOWNSTREAM_POWER => "downstream_power",
	SCHEMA_STATUS_DOWNSTREAM_LOCK => "downstream_lock",
	SCHEMA_STATUS_DOWNSTREAM_RATE => "downstream_rate",
	SCHEMA_STATUS_DOWNSTREAM_SNR => "downstream_snr",
	SCHEMA_STATUS_DOWNSTREAM_CHANNEL => "downstream_channel",
	SCHEMA_STATUS_UPSTREAM_FREQUENCY => "upstream_frequency",
	SCHEMA_STATUS_UPSTREAM_MODULATION => "upstream_modulation",
	SCHEMA_STATUS_UPSTREAM_POWER => "upstream_power",
	SCHEMA_STATUS_UPSTREAM_LOCK => "upstream_lock",
	SCHEMA_STATUS_UPSTREAM_RATE => "upstream_rate",
	SCHEMA_STATUS_UPSTREAM_SNR => "upstream_snr",
	SCHEMA_STATUS_UPSTREAM_CHANNEL => "upstream_channel",
	SCHEMA_STATUS_CONNECTION => "connection_status",
	SCHEMA_STATUS_TOD => "tod_status",

};

my $opt_sql_dbi_driver = OUTPUT_OPT_SQL_DBI_DRIVER;
my $opt_sql_address = OUTPUT_OPT_SQL_ADDRESS;
my $opt_sql_port = OUTPUT_OPT_SQL_PORT;
my $opt_sql_user = OUTPUT_OPT_SQL_USER;
my $opt_sql_password = OUTPUT_OPT_SQL_PASSWORD;
my $opt_sql_dbi_raise_error = OUTPUT_OPT_SQL_DBI_RAISE_ERROR;
my $opt_sql_database = OUTPUT_OPT_SQL_DATABASE;
my $opt_sql_status_table = OUTPUT_OPT_SQL_STATUS_TABLE;

my $schema_status_wan_id = SCHEMA_STATUS_WAN_ID;
my $schema_status_circuit_id = SCHEMA_STATUS_CIRCUIT_ID;
my $schema_status_modem_id = SCHEMA_STATUS_MODEM_ID;
my $schema_status_downstream_frequency = SCHEMA_STATUS_DOWNSTREAM_FREQUENCY;
my $schema_status_downstream_modulation = SCHEMA_STATUS_DOWNSTREAM_MODULATION;
my $schema_status_downstream_power = SCHEMA_STATUS_DOWNSTREAM_POWER;
my $schema_status_downstream_lock = SCHEMA_STATUS_DOWNSTREAM_LOCK;
my $schema_status_downstream_rate = SCHEMA_STATUS_DOWNSTREAM_RATE;
my $schema_status_downstream_snr = SCHEMA_STATUS_DOWNSTREAM_SNR;
my $schema_status_downstream_channel = SCHEMA_STATUS_DOWNSTREAM_CHANNEL;
my $schema_status_upstream_frequency = SCHEMA_STATUS_UPSTREAM_FREQUENCY;
my $schema_status_upstream_modulation = SCHEMA_STATUS_UPSTREAM_MODULATION;
my $schema_status_upstream_power = SCHEMA_STATUS_UPSTREAM_POWER;
my $schema_status_upstream_lock = SCHEMA_STATUS_UPSTREAM_LOCK;
my $schema_status_upstream_rate = SCHEMA_STATUS_UPSTREAM_RATE;
my $schema_status_upstream_snr = SCHEMA_STATUS_UPSTREAM_SNR;
my $schema_status_upstream_channel = SCHEMA_STATUS_UPSTREAM_CHANNEL;
my $schema_status_connection = SCHEMA_STATUS_CONNECTION;
my $schema_status_tod = SCHEMA_STATUS_TOD;


1;

#-----------------------------------------------------------
# External Methods
#-----------------------------------------------------------
sub outputGetName{
	return OUTPUT_LIBRARY_NAME;
}

sub outputGetDescription{
	return OUTPUT_LIBRARY_DESCRIPTION;
}

sub outputGetVersion{
	return OUTPUT_LIBRARY_VERSION;
}

sub outputReportInfo{
	my $reference = shift;
	my $retval = 0;
	my $field_name;
	my $field_data;
	my $reftype;

	my $dsn;
	my $database_handle;
	my $sql_handle;
	my $sql_statement;
	my $sql_fields;
	my $sql_values;

	my $data_modem_id = OUTPUT_OPT_SQL_MODEM_ID;
	my $data_circuit_id = OUTPUT_OPT_SQL_CIRCUIT_ID;
	my $data_wan_id = OUTPUT_OPT_SQL_WAN_ID;

	my $data_downstream_frequency;
	my $data_downstream_modulation;
	my $data_downstream_power;
	my $data_downstream_lock;
	my $data_downstream_rate;
	my $data_downstream_snr;
	my $data_downstream_channel;
	my $data_upstream_frequency;
	my $data_upstream_modulation;
	my $data_upstream_power;
	my $data_upstream_lock;
	my $data_upstream_rate;
	my $data_upstream_snr;
	my $data_upstream_channel;
	my $data_wan_status;
	my $data_tod_status;


	return $retval unless defined $reference;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";


#	go through array and gather data

	foreach my $line (@{$reference}) {
		($field_name,$field_data) = split(/=/,$line);

		#	If there's no data, null it out

		if ($field_data eq NO_DATA) {
			$field_data = "";
		}

		# 	Downstream

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_FREQUENCY") {
			$data_downstream_frequency = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_MODULATION") {
			$data_downstream_modulation = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_POWER") {
			$data_downstream_power = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_LOCK") {
			$data_downstream_lock = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_RATE") {
			$data_downstream_rate = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_SNR") {
			$data_downstream_snr = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_CHANNEL") {
			$data_downstream_channel = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_DOWNSTREAM_CHANNEL") {
			$data_downstream_channel = $field_data;
		}

		# 	Upstream

		if ($field_name eq "DRIVER_INFO_UPSTREAM_FREQUENCY") {
			$data_upstream_frequency = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_MODULATION") {
			$data_upstream_modulation = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_POWER") {
			$data_upstream_power = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_LOCK") {
			$data_upstream_lock = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_RATE") {
			$data_upstream_rate = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_SNR") {
			$data_upstream_snr = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_CHANNEL") {
			$data_upstream_channel = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_UPSTREAM_CHANNEL") {
			$data_upstream_channel = $field_data;
		}

		#	Misc

		if ($field_name eq "DRIVER_INFO_WAN_STATUS") {
			$data_wan_status = $field_data;
		}

		if ($field_name eq "DRIVER_INFO_TOD_SUCCESS") {
			$data_tod_status = $field_data;
		}
	}


	# 	Set up DSN

	$dsn = "DBI:$opt_sql_dbi_driver:database=$opt_sql_database;host=$opt_sql_address";

	#	Connect to SQL
	
	$database_handle = DBI->connect("$dsn",$opt_sql_user, $opt_sql_password, {RaiseError => $opt_sql_dbi_raise_error});

	# 	Build SQL Statement

	$sql_fields = "$schema_status_wan_id,$schema_status_circuit_id,$schema_status_modem_id,$schema_status_downstream_frequency,$schema_status_downstream_modulation,$schema_status_downstream_power,$schema_status_downstream_lock,$schema_status_downstream_rate,$schema_status_downstream_snr,$schema_status_downstream_channel,$schema_status_upstream_frequency,$schema_status_upstream_modulation,$schema_status_upstream_power,$schema_status_upstream_lock,$schema_status_upstream_rate,$schema_status_upstream_snr,$schema_status_upstream_channel,$schema_status_connection,$schema_status_tod";
	$sql_values = "$data_modem_id,$data_circuit_id,$data_wan_id,'$data_downstream_frequency','$data_downstream_modulation','$data_downstream_power','$data_downstream_lock','$data_downstream_rate','$data_downstream_snr','$data_downstream_channel','$data_upstream_frequency','$data_upstream_modulation','$data_upstream_power','$data_upstream_lock','$data_upstream_rate','$data_upstream_snr','$data_upstream_channel',$data_wan_status,$data_tod_status";
	$sql_statement = "INSERT INTO `$opt_sql_status_table` ($sql_fields) VALUES ($sql_values);";

	#	Execute SQL Statement

	$sql_handle = $database_handle->prepare($sql_statement);

	if ($sql_handle) {
		$sql_handle->execute();
		$sql_handle->finish();
		$retval = 1;
	} else {
		$retval = 0;
	}
	
	# 	Disconnect

	$database_handle->disconnect();

	return $retval;
}
