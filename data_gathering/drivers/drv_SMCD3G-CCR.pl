#
#	Broadband Status
#	DRIVER
#		Devices Supported: SMCD3G-CCR  
#
#	Driver Author: Lee Thompson <thompsonl@logh.net>
#
#=============================================================================
#	TO DO:
#		data normalization
#			obtain/parse data
#				use temporary storag
#				lookup etc data
#				flag not available items
#			        data available in standardized %struct
#		true initialization function
#		create methods for set/get variables
#		error handling
#		testing
#		build driver template from this
#		documentation
#=============================================================================
#	Developer Notes
#=============================================================================
#	All public subs prefixed with driver (i.e. driverMyFunction)
#	All private subs prefixed with privateDriver (i.e. privateDriverMyFunction)
#
#	While not required, should prefix driver variables with driver or something
#	or properly reference main variables.
#
#	If a field or other data is not available, return NO_FIELD
#
#	Drivers MUST implement the following functions
#		driverGetDeviceData
#		driverGetVersion
#		driverGetDevices
#		...
#=============================================================================


use strict;
use warnings;
use Switch;
use WWW::Mechanize 1.73;


use constant{
	DRIVER_FAMILY => "comcast_business_01",			# not sure how useful this is?
	DRIVER_DEVICES => "SMCD3G-CCR",				# Use bar | to separate
	DRIVER_VERSION => "201607201308",
#
# 	Driver Debug Options
#
	DRIVER_OPT_DEBUG_DUMP_HTTP => 1,
	DRIVER_OPT_DUMP_PATH => "debug",
	DRIVER_OPT_DUMP_FILE_INFO => "info",
	DRIVER_OPT_DUMP_FILE_STATUS => "status",
	DRIVER_OPT_DUMP_FILE_NETWORK => "network",
	DRIVER_OPT_DUMP_EXTENSION => "txt",
	DRIVER_OPT_DUMP_HTTP_SUFFIX => "_raw",
#
#	HTTP Options
#
	MAX_RETRY_DELAY => 900,
	WWW_STACK_DEPTH => 0,
	WWW_AUTO_CHECK => 0,
	WWW_NOPROXY => 0,
	WWW_QUIET => 0,
#
#	HTTP Constants
#
	HTML_MIME => "text/html",
#
#	Driver Defaults
#
	DEFAULT_USER_AGENT => "Windows Mozilla",
	DEFAULT_CONTENT_HASH => 0,
	DEFAULT_RETRY_COUNT => 5,
	DEFAULT_RETRY_DELAY => 10,
	DRIVER_OPTION_REQUIRE_LOGOUT => 0,
#
#	Broadband Device Driver Defaults
#
	DRIVER_DEVICE_CARRIER => "COMCAST",				#	Carrier or NON_SPECIFIC
	DRIVER_DEVICE_TYPE => "CMRouter",				#	Carrier or General Type
	DRIVER_DEVICE_TECHNOLOGY => "DOCSIS",				#	Technology (DOCSIS, ADSL, etc)
	DRIVER_DEVICE_TECHNOLOGY_VERSION => 3,				#	Technology Version (if applicable)
	DRIVER_DEVICE_TECHNOLOGY_GROUP => "Cable Modem",		#	Technology Family
	DRIVER_DEVICE_MANUFACTURER => "SMC Networks",			#	Device Maker
	DRIVER_DEVICE_MODEL => "SMCD3G-CCR",				#	Device Model
	DRIVER_DEVICE_PROTOCOL => "http",				#	Protocol to Access
	DRIVER_DEVICE_URL_LOGIN => 0,					#	Login URL
	DRIVER_DEVICE_URL_STATUS => "user/feat-gateway-status.asp",	# 	Status Page URL
	DRIVER_DEVICE_URL_INFO =>  "user/feat-gateway-modem.asp",	#	Info Page URL
	DRIVER_DEVICE_URL_NETWORK =>  "user/feat-gateway-network.asp",	#	Network Page URL
	DRIVER_DEVICE_URL_LOGOUT => "gocusform/logout",			#	Logout Page URL
	DRIVER_DEVICE_FIELD_LOGIN_FORM_NUMBER => 1,			#	Form Number for Login
	DRIVER_DEVICE_FIELD_LOGIN_USERNAME => "user",			#	Form Field Name
	DRIVER_DEVICE_FIELD_LOGIN_PASSWORD => "pws",			#	Form Field Password
	DRIVER_DEVICE_ADDRESS => "10.1.10.1",				#	LAN IP Address
	DRIVER_DEVICE_USERNAME => "cusadmin",				#	Username
	DRIVER_DEVICE_PASSWORD => "highspeed",				#	Password
	DRIVER_DEVICE_IS_OEM => 1,					#	Is an OEM Model?
	DRIVER_DEVICE_REQUIRE_LOGIN => 1,				#	Is login required?
	DRIVER_DEVICE_REQUIRE_LOGOUT => 0,				#	Is logout required?
	DRIVER_DATA_SEPARATOR => "|",
#
#	Units of Measure
#
	DRIVER_MEASURE_MODULATION => "QAM",

	DRIVER_MEASURE_DOWNSTREAM_FREQUENCY => "MHz",
	DRIVER_MEASURE_DOWNSTREAM_POWER => "dBmV",
	DRIVER_MEASURE_DOWNSTREAM_SYMBOL_RATE => "Msym/sec",
	DRIVER_MEASURE_DOWNSTREAM_SNR => "dB",

	DRIVER_MEASURE_UPSTREAM_FREQUENCY => "Hz",
	DRIVER_MEASURE_UPSTREAM_SYMBOL_RATE => "KSym/sec",
	DRIVER_MEASURE_UPSTREAM_POWER => "dBmV",

	DRIVER_MEASURE_MILLISECOND => "ms",
#	
#	Fields
#
	DRIVER_INFO_DOWNSTREAM_FREQUENCY => "var CmDownstreamFrequencyBase",
	DRIVER_INFO_DOWNSTREAM_MODULATION => "var CmDownstreamQamBase",
	DRIVER_INFO_DOWNSTREAM_POWER => "var CmDownstreamChannelPowerdBmVBase",
	DRIVER_INFO_DOWNSTREAM_LOCK => "var CmDownstreamDSLockStatusBase",
	DRIVER_INFO_DOWNSTREAM_RATE => "var CmDownstreamChannelPowerdBmVBase",
	DRIVER_INFO_DOWNSTREAM_SNR => "var CmDownstreamSnrBase",
	DRIVER_INFO_DOWNSTREAM_CHANNEL => NO_FIELD,

	DRIVER_INFO_UPSTREAM_FREQUENCY => "var CmUpstreamFrequencyBase",
	DRIVER_INFO_UPSTREAM_MODULATION => "var CmUpstreamModuBase",
	DRIVER_INFO_UPSTREAM_POWER => "var CmUpstreamChannelPowerBase",
	DRIVER_INFO_UPSTREAM_LOCK => "var CmUpstreamLockStatusBase",
	DRIVER_INFO_UPSTREAM_RATE => "var CmUpstreamBwBase",
	DRIVER_INFO_UPSTREAM_SNR => NO_FIELD,
	DRIVER_INFO_UPSTREAM_CHANNEL => "var CmUpstreamChannelIdBase",

	DRIVER_INFO_WAN_STATUS => "var cable_status",					# same as DRIVER_NETWORK_WAN_STATUS
	DRIVER_INFO_TOD_SUCCESS => "var TodSuccess",					# Time of Day Status (0 not set, 1 set)
	
	DRIVER_WAN_TYPE_STATIC => "Fixed",
	DRIVER_WAN_TYPE_DHCP => "Dynamic",

	DRIVER_DEFAULT_INTERNET_INFO_V4 => "0.0.0.0|0.0.0.0|0.0.0.0|0.0.0.0|0.0.0.0|00h:00m:00s|",

	DRIVER_NETWORK_PUBLIC_LAN_V4 => "var PublicLanInfoBase",
	DRIVER_NETWORK_PUBLIC_WAN_V4 => "var WANInfoBase",
	DRIVER_NETWORK_PRIVATE_LAN_V4 => "var LanIpInfoBase",				# third field is DHCP Server (1/0) enable/disable
	DRIVER_NETWORK_PRIVATE_MAC => "var UsedDeviceMacAddress",
	DRIVER_NETWORK_PUBLIC_MAC => "var CmMacAddress",
	DRIVER_NETWORK_DHCP_SERVER_CONFIG_V4 => "var DhcpsInfoBase",			# FIRST|LAST|LEASE
	DRIVER_NETWORK_PUBLIC_WAN_DHCP_V4 => "var wanDataIpAddress",
	DRIVER_NETWORK_PUBLIC_WAN_DHCP_SUBNET_V4 => "var WanDataSubnetMask",
	DRIVER_NETWORK_PUBLIC_WAN_DHCP_GATEWAY_V4 => "var WanDataGateway",
	DRIVER_NETWORK_INTERNET_INFO_V4 => "var InternetInfoBase",			# PUBLIC IPv4|SUBNET MASK|GATEWAY|DNS1|DNS2|DHCP LEASE REMAINING|UNKNOWN
	DRIVER_NETWORK_WAN_STATUS => "var cable_status",				# same as DRIVER_INFO_WAN_STATUS
	DRIVER_NETWORK_PUBLIC_WAN_DHCP_LEASE => NO_FIELD,				# parse from DRIVER_NETWORK_INTERNET_INFO_V4 (6th field)
	DRIVER_NETWORK_STATIC_IP_BLOCK => NO_FIELD,					# parse from DRIVER_NETWORK_PUBLIC_LAN_V4 (2nd and 5th Field)

	DRIVER_NETWORK_PUBLIC_WAN_V6 => "var WANIPv6addr",
	DRIVER_NETWORK_DHCP_SERVER_CONFIG_V6 => "var Dhcp6sInfoBase",
	DRIVER_NETWORK_DHCP_DNS_PRIMARY_V6 => "var Dhcp6sDns1",
	DRIVER_NETWORK_DHCP_DNS_SECONDARY_V6 => "var Dhcp6sDns2",
	DRIVER_NETWORK_PRIVATE_LAN_V6 => "var LanDns6InfoBase",
	DRIVER_NETWORK_DNS_PRIMARY_V6 => "var Dns6_1",
	DRIVER_NETWORK_DNS_SECONDARY_V6 => "var Dns6_2",

	DRIVER_NETWORK_PRIVATE_LAN_GATEWAY_V6 => "LAN Gateway IPv6 Address",
	DRIVER_NETWORK_PREFIX_DELEGATIONS_V6 => "LAN IPv6 Prefixs Delegations",
	
	DRIVER_MODIFIER_WAN_STATUS => 0xffff,

	DRIVER_STATUS_SYSTEMTIME => "var systimebase",					# has extra quotes and ;
	DRIVER_STATUS_RGSTATUS => "var RGStatus",					# 0 = bridge mode, 1 = (RG) residential gateway
	DRIVER_STATUS_OPERATING_MODE => NO_FIELD,
	DRIVER_STATUS_VENDOR => "Vendor Name",
	DRIVER_STATUS_HARDWARE_VERSION => "Hardware Version",
	DRIVER_STATUS_SERIAL_NUMBER => "Serial Number",
	DRIVER_STATUS_FIRMWARE_VERSION => "Firmware Version",
	DRIVER_STATUS_UPTIME => "System Uptime",
#
#	Strings
#
	STRING_DUMPING_RAW => "Dumping raw data to",
	STRING_DATA_DUMP_SUCCESS => "Data Dump Write Successful",
	STRING_DATA_DUMP_FAILED => "Data Dump Write Failed",
	STRING_LOGIN_SUCCESS => "Login Success",
	STRING_BROWSE_SUCCESS => "Browse Success",
	STRING_REQUESTING_URL => "Requesting URL",
	STRING_CURRENT_URL => "Current URI",
	STRING_INITIAL_PAGE_IS_LOGIN => "Initial Page is Login",
	STRING_SUBMITTING_LOGIN_FORM => "Submitting Login Form",
	STRING_TITLE => "Title",
	STRING_MIME => "MIME",
	STRING_EXTRACTING_DATA => "Extracting Data",
	STRING_REQUESTING_LOGIN_PAGE => "Requesting Login Page",
	STRING_ATTEMPTING_TO_GET_LOGIN_PAGE => "Attempting to Get Login Page",
	STRING_ATTEMPTING_TO_GET_STATUS_PAGE => "Attempting to Get Status Page",
	STRING_ATTEMPTING_TO_GET_INFO_PAGE => "Attempting to Get Info Page",
	STRING_ATTEMPTING_TO_GET_NETWORK_PAGE => "Attempting to Get Network Page",
	STRING_ATTEMPTING_TO_LOGOUT => "Attemping to Logout",
	STRING_ERROR_PREFIX => "ERROR: ",
	STRING_ERROR_LOGGING_OUT => "Error Logging Out",
	STRING_ERROR_ABORTED => "Aborted",
	STRING_ERROR_UNKNOWN => "Unknown Error",
	STRING_ERROR_BROWSE_FAILED => "Browse Failed",
	STRING_ERROR_NO_START_PAGE => "Failed to get Initial Page",
	STRING_ERROR_NO_LOGIN_PAGE => "Failed to get LOGIN page",
	STRING_ERROR_NO_PAGE => "Failed to get page",
	STRING_ERROR_NO_LOGOUT_PAGE => "Logout Required But No Page Defined",
	STRING_ERROR_LOGIN_FAILED => "Login Failed",
	STRING_WARNING_LOGOUT_NOT_REQUIRED => "Logout Not Required",

	DRIVER_TRIMWHITESPACE => 1,
	
};

# Temporary Initialization Routine

# HTTP

my $http_user_agent = DEFAULT_USER_AGENT;
my $http_stack_depth = WWW_STACK_DEPTH;
my $http_auto_check = WWW_AUTO_CHECK;
my $http_no_proxy = WWW_NOPROXY;
my $http_quiet = WWW_QUIET;
my $opt_retry_count = DEFAULT_RETRY_COUNT;
my $opt_retry_delay = DEFAULT_RETRY_DELAY;

# Device

my $device_type = DRIVER_DEVICE_TYPE;
my $device_carrier = DRIVER_DEVICE_CARRIER;
my $device_manufacturer = DRIVER_DEVICE_MANUFACTURER;
my $device_model = DRIVER_DEVICE_MODEL;
my $device_protocol = DRIVER_DEVICE_PROTOCOL;
my $device_oem = DRIVER_DEVICE_IS_OEM;
my $device_address = DRIVER_DEVICE_ADDRESS;
my $device_username = DRIVER_DEVICE_USERNAME;
my $device_password = DRIVER_DEVICE_PASSWORD;
my $device_login_page = DRIVER_DEVICE_URL_LOGIN;
my $device_status_page = DRIVER_DEVICE_URL_STATUS;
my $device_network_page = DRIVER_DEVICE_URL_NETWORK;
my $device_info_page = DRIVER_DEVICE_URL_INFO;
my $device_logout_page = DRIVER_DEVICE_URL_LOGOUT;
my $device_data_separator = DRIVER_DATA_SEPARATOR;

my $device_field_login_form_number = DRIVER_DEVICE_FIELD_LOGIN_FORM_NUMBER;
my $device_field_login_form_username = DRIVER_DEVICE_FIELD_LOGIN_USERNAME;
my $device_field_login_form_password = DRIVER_DEVICE_FIELD_LOGIN_PASSWORD;



# Paths

my $dump_path = DRIVER_OPT_DUMP_PATH;
my $dump_file_info = DRIVER_OPT_DUMP_FILE_INFO;
my $dump_file_status = DRIVER_OPT_DUMP_FILE_STATUS;
my $dump_file_network = DRIVER_OPT_DUMP_FILE_NETWORK;
my $dump_file_extension = DRIVER_OPT_DUMP_EXTENSION;
my $dump_file_http_suffix = DRIVER_OPT_DUMP_HTTP_SUFFIX;

# Options

my $opt_hash_content = parseBoolean(DEFAULT_CONTENT_HASH);
my $opt_driver_dump_http = DRIVER_OPT_DEBUG_DUMP_HTTP;
my $opt_driver_logout = DRIVER_OPTION_REQUIRE_LOGOUT;
my $opt_driver_login = DRIVER_DEVICE_REQUIRE_LOGIN;

# Internals

my $data_timestamp;
my $connection_status = NO_DATA;

# Flags

my $flag_data_gathered = 0;

# Arrays

my @driver_info = ();
my @driver_status = ();
my @driver_network = ();

#	defaults but probably want methods to access and set

#	drive overrides of config/defaults

if (DRIVER_DEVICE_REQUIRE_LOGOUT > 0) {
	$opt_driver_logout = DRIVER_DEVICE_REQUIRE_LOGOUT;
}

$BBStatus::global_trimwhitespace = DRIVER_TRIMWHITESPACE;

1;

#-----------------------------------------------------------
# Interface to Driver Settings
#-----------------------------------------------------------
sub driverGetVersion{
	return DRIVER_VERSION;
}

sub driverGetDataTimestamp{
	return $data_timestamp;
}

#-----------------------------------------------------------
# Count Data Entries
#-----------------------------------------------------------
sub driverNumberOfDataEntries{
	my $counter = 0;
	
	$counter = $counter + @driver_info;
	$counter = $counter + @driver_status;
	$counter = $counter + @driver_network;

	return $counter;
}

#-----------------------------------------------------------
# Get Actual Data for Device
#-----------------------------------------------------------
sub driverGetDeviceDataInfo{
	my $reference = shift;
	my $retval = 0;
	my $reftype;

	return $retval unless defined $reference;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";
		
	(@{$reference}) = @driver_info;
	
	$retval = @driver_info;

	return $retval;

}

sub driverGetDeviceDataNetwork{
	my $reference = shift;
	my $retval = 0;
	my $reftype;

	return $retval unless defined $reference;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";
		
	(@{$reference}) = @driver_network;
	
	$retval = @driver_network;

	return $retval;

}

sub driverGetDeviceDataStatus{
	my $reference = shift;
	my $retval = 0;
	my $reftype;

	return $retval unless defined $reference;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";
	
	(@{$reference}) = @driver_status;
	
	$retval = @driver_status;

	return $retval;

}

sub driverGetConnectionStatus{
	my $retval = 0;
	my $retmsg = ERROR_UNKNOWN;
	
	if ($connection_status ne NO_DATA) {
		($retval,$retmsg) = privateDriverGetComcastCableStatus($connection_status);
	}

	return ($retval,$retmsg);
}

#-----------------------------------------------------------
# Public Functions
#-----------------------------------------------------------
#	Main Call
#-----------------------------------------------------------

sub driverGetDeviceData{
	my $retcode = RESPONSE_ERROR;
	my $error = ERROR_INVALID;

	# to do
	#	reference to array

	# to do
	#	initialize array
	#	mark anything not applicable to the driver as NOT_APPLICABLE

	# to do
	#	do initial tests if requested (ping, tcp, etc)

	#	use device interface to get data
	($retcode,$error) = privateDriverQuestionDevice();

	#	normalize data and populate array
	#	return REPONSE_OK if the array populated correctly, otherwise RESPONSE_ERROR and why

	

	return ($retcode,$error);
}	
#-----------------------------------------------------------
# Private Functions
#-----------------------------------------------------------
# Comcast Cable Status Lookup
#-----------------------------------------------------------
sub privateDriverGetComcastCableStatus{
	my $cablestatus = shift;
	my $retval = 0;
	my $retmsg;

	# may need to do cable_status&=0xffff;

	return ($retval,$retmsg) unless defined $cablestatus;

	$retmsg = ERROR_UNKNOWN_STATUS;

	switch ($cablestatus) {
		case 1 { $retmsg = "Initializing" }
		case 2 { $retmsg = "Initializing Hardware" }
		case 3 { $retmsg = "Acquiring Downstream Channel" }
		case 4 { $retmsg = "Acquiring Upstream Channel" }
		case 5 { $retmsg = "Acquiring Upstream Channel" }
		case 6 { $retmsg = "Binding DHCP" }
		case 7 { $retmsg = "Acquiring Time-of-Day" }
		case 8 { $retmsg = "Downloading CM Configuration File" }
		case 9 { $retmsg = "Downloading CM Configuration File" }
		case 10 { $retmsg = "Registering Connection" }
		case 11 { $retmsg = "Connection Registered" }
		case 12 { $retmsg = "Traffic Enabled" }
		case 13 { $retmsg = "Connection Refused by CMTS" }
	}

	if ($retmsg ne ERROR_UNKNOWN_STATUS) {
		$retval = 1;
	}

	return ($retval,$retmsg);
}

#-----------------------------------------------------------
# Comcast Threshold Tests
#-----------------------------------------------------------
# Downstream (Rx) Receive Power Level
# RECOMMENDED: -7 dBmV to +7 dBmV 
# ACCEPTABLE: -8 dBmV to -10 dBmV, +8 dBmV to +10 dBmV
# MAXIMUM: -11 dBmV to -15 dBmV, +11 dBmV to +15 dBmV
# OUT OF SPEC: -15 dBmV and below, +15 dBmV and above
#
# SNR
# 256 QAM: 30 dB minimum. 33 dB or higher recommended. (often used in downstream channels)
# 64 QAM: 24 dB minimum. 27 dB or higher recommended. (often used in downstream channels)
# 16 QAM: 18 dB minimum. 21 dB or higher recommended. (often used in upstream channels)
# QPSK: 12 dB minimum. 15 dB or higher recommended. (often used in upstream channels)
# 
# Upstream (tx) Transmit Power Level
# RECOMMENDED: 35 dBmV - 49 dBmV
# MAXIMUM: 52 dBmV maximum for A-TDMA & TDMA (DOCSIS 3.0)
# MAXIMUM: 53 dBmV maximum for S-CDMA DOCSIS 2.0 (All Modulations)
# MAXIMUM: 54 dBmV maximum for 32 QAM and 64 QAM. (A-TDMA DOCSIS 2.0)
# MAXIMUM: 55 dBmV maximum for 8 QAM and 16 QAM. (DOCSIS 1.0, 1.1)
# MAXIMUM: 58 dBmV maximum for QPSK. (DOCSIS 1.0, 1.1)
#
# This function will need INFO data to test with
sub privateDriverTestThresholds{
}

#-----------------------------------------------------------
# Comcast Operating Mode
#-----------------------------------------------------------
sub privateDriverGetComcastOperatingMode{
	my $opmode = shift;
	my $retval = NO_DATA;

	return $retval unless defined $opmode;

	$opmode = int($opmode);

	switch ($opmode) {
		case 0 { $retval = OPERATING_MODE_BRIDGE } 
		case 1 { $retval = OPERATING_MODE_GATEWAY } 
	}

	return $retval;
}

#-----------------------------------------------------------
# Get Device Data from Interface
#-----------------------------------------------------------
sub privateDriverQuestionDevice{
	my $retcode = RESPONSE_ERROR;
	my $error = ERROR_INVALID;
	my $url = "";
	my $http_title;
	my $http_mime;
	my $http_content;
	my $http_status;
	my $http_message;
	my $current_uri;
	my $login_form_fields;
	my $buffer;
	my $result;
	my $flag_continue = 0;
	my $pathname;

	my $browser = WWW::Mechanize->new(
		autocheck => $http_auto_check,
		agent => $http_user_agent,
		noproxy => $http_no_proxy,
		quiet => $http_quiet,
		stack_depth => $http_stack_depth,
	);

	$url = "$device_protocol://$device_address";

	writelog(STRING_REQUESTING_URL . ": $url",TRACE);
	
	# ability to do content type decoding if needed

	# should follow redirects if needed

	$flag_continue = 1;

	if ($flag_continue) {

		# Get Initial Page

		$browser->get($url);

		if ($browser->success) {

			$flag_continue = 1;

			$http_title = $browser->title();
			$http_mime = $browser->content_type();
			$http_content = $browser->content;
			$http_status = $browser->status();
			$http_message = $browser->response()->status_line;
			$current_uri = $browser->uri();

			$http_title = NO_DATA unless defined $http_title;

			writelog(STRING_BROWSE_SUCCESS,TRACE);

			writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
			writelog(STRING_TITLE . ": $http_title",TRACE);
			writelog(STRING_MIME . ": $http_mime",TRACE);

			if ($opt_driver_login) {
				if ($device_login_page) {
					writelog(STRING_REQUESTING_LOGIN_PAGE,TRACE);

					$flag_continue = 1;

					$url = "$device_protocol://$device_address/$device_login_page";
	
					writelog(STRING_ATTEMPTING_TO_GET_LOGIN_PAGE,TRACE);
	
					$browser->get($url);

					if ($browser->success) {
						$flag_continue = 1;
		
						$http_title = $browser->title();
						$http_mime = $browser->content_type();
						$http_content = $browser->content;
						$http_status = $browser->status();
						$http_message = $browser->response()->status_line;
						$current_uri = $browser->uri();

						$http_title = NO_DATA unless defined $http_title;

						writelog(STRING_BROWSE_SUCCESS,TRACE);

						writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
						writelog(STRING_TITLE . ": $http_title",TRACE);
						writelog(STRING_MIME . ": $http_mime",TRACE);

					} else {
						$flag_continue = 0;

						writelog(STRING_ERROR_PREFIX . STRING_ERROR_NO_LOGIN_PAGE,TRACE);
					}

				} else {
					$flag_continue = 1;

					writelog(STRING_INITIAL_PAGE_IS_LOGIN,TRACE);
				}

				if ($flag_continue) {
					$flag_continue = 1;

					writelog(STRING_SUBMITTING_LOGIN_FORM,TRACE);

					$result = $browser->submit_form(
						form_number => $device_field_login_form_number,
                	              		fields => {
							$device_field_login_form_username => $device_username,
							$device_field_login_form_password => $device_password
						} 
					);

					if ($result->is_success) {
						$flag_continue = 1;

						$http_title = $browser->title();
						$http_mime = $browser->content_type();
						$http_content = $browser->content;
						$http_status = $browser->status();
						$http_message = $browser->response()->status_line;
						$current_uri = $browser->uri();

						$http_title = NO_DATA unless defined $http_title;
		
						writelog(STRING_LOGIN_SUCCESS,TRACE);
						writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
						writelog(STRING_TITLE . ": $http_title",TRACE);
						writelog(STRING_MIME . ": $http_mime",TRACE);
					} else {
						$flag_continue = 0;
						writelog(STRING_ERROR_PREFIX . STRING_ERROR_LOGIN_FAILED,TRACE);
					}
				} else {
					$flag_continue = 0;
					writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
				}
			} else {
				$flag_continue = 1;
				writelog(STRING_WARNING_LOGOUT_NOT_REQUIRED,TRACE);
			}

			#	STATUS

			if ($flag_continue) {

				$url = "$device_protocol://$device_address/$device_status_page";
	
				writelog(STRING_ATTEMPTING_TO_GET_STATUS_PAGE,TRACE);
	
				$browser->get($url);
	
				if ($browser->success) {
	
					# Get Data
					# STATUS
	
					$http_title = $browser->title();
					$http_mime = $browser->content_type();
					$http_content = $browser->content;
					$http_status = $browser->status();
					$http_message = $browser->response()->status_line;
					$current_uri = $browser->uri();

					$http_title = NO_DATA unless defined $http_title;
	
					writelog(STRING_BROWSE_SUCCESS,TRACE);

					writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
					writelog(STRING_TITLE . ": $http_title",TRACE);
					writelog(STRING_MIME . ": $http_mime",TRACE);

					if ($opt_driver_dump_http) {
						$pathname = "$dump_path/$dump_file_status" . $dump_file_http_suffix . "." . $dump_file_extension;
						
						writelog("STATUS: " . STRING_DUMPING_RAW . " $pathname",TRACE);

						if (rawToFile($http_content,$pathname)) {
								writelog(STRING_DATA_DUMP_SUCCESS,TRACE);
							} else {
								writelog(STRING_DATA_DUMP_FAILED,TRACE);
						}
					}
	
					$flag_continue = 1;

					if ($flag_continue) {
						writelog(STRING_EXTRACTING_DATA . ": STATUS",TRACE);
	
						$buffer = getValuesFromHTML(DRIVER_STATUS_SYSTEMTIME,$http_content);
						(my $junk,$buffer) = parseQuotes($buffer);
						push(@driver_status,"DRIVER_STATUS_SYSTEMTIME=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_STATUS_RGSTATUS,$http_content);
						push(@driver_status,"DRIVER_STATUS_RGSTATUS=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_STATUS_OPERATING_MODE,$http_content);
						if ($buffer eq NO_DATA) {
							$buffer = privateDriverGetComcastOperatingMode(forceNumeric(getQuotedValuesFromHTML(DRIVER_STATUS_RGSTATUS,$http_content)));
						}
						push(@driver_status,"DRIVER_STATUS_OPERATING_MODE=$buffer");
	
						$buffer = getValuesFromHTMLTable(DRIVER_STATUS_VENDOR,$http_content);
						push(@driver_status,"DRIVER_STATUS_VENDOR=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_STATUS_HARDWARE_VERSION,$http_content);
						push(@driver_status,"DRIVER_STATUS_HARDWARE_VERSION=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_STATUS_SERIAL_NUMBER,$http_content);
						push(@driver_status,"DRIVER_STATUS_SERIAL_NUMBER=$buffer");
					
						$buffer = getValuesFromHTMLTable(DRIVER_STATUS_UPTIME,$http_content);
						push(@driver_status,"DRIVER_STATUS_UPTIME=$buffer");

						$retcode = RESPONSE_OK;
						$error = NO_ERROR;
					} else {
						$flag_continue = 0;
						writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
					}
				} else {
					$flag_continue = 0;
					writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
				}
			}

			#	DEVICE INFO

			if ($flag_continue) {
				# Get Page for Info

				$url = "$device_protocol://$device_address/$device_info_page";

				writelog(STRING_ATTEMPTING_TO_GET_INFO_PAGE,TRACE);

				$browser->get($url);

				if ($browser->success) {

					# Get Data
					# INFO

					$http_title = $browser->title();
					$http_mime = $browser->content_type();
					$http_content = $browser->content;
					$http_status = $browser->status();
					$http_message = $browser->response()->status_line;
					$current_uri = $browser->uri();

					$http_title = NO_DATA unless defined $http_title;

					writelog(STRING_BROWSE_SUCCESS,TRACE);

					writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
					writelog(STRING_TITLE . ": $http_title",TRACE);
					writelog(STRING_MIME . ": $http_mime",TRACE);

					if ($opt_driver_dump_http) {
						$pathname = "$dump_path/$dump_file_info" . $dump_file_http_suffix . "." . $dump_file_extension;

						writelog("INFO: " . STRING_DUMPING_RAW . " $pathname",TRACE);

						if (rawToFile($http_content,$pathname)) {
								writelog(STRING_DATA_DUMP_SUCCESS,TRACE);
							} else {
								writelog(STRING_DATA_DUMP_FAILED,TRACE);
						}
					}

					$flag_continue = 1;

					if ($flag_continue) {
						writelog(STRING_EXTRACTING_DATA . " INFO",TRACE);

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_FREQUENCY,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_FREQUENCY=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_MODULATION,$http_content);
						$buffer = removeSubstring($buffer,DRIVER_MEASURE_MODULATION);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_MODULATION=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_POWER,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_POWER=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_LOCK,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_LOCK=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_RATE,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_RATE=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_SNR,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_SNR=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_CHANNEL,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_DOWNSTREAM_CHANNEL=$buffer");


						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_FREQUENCY,$http_content);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_FREQUENCY=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_MODULATION,$http_content);
						$buffer = removeSubstring($buffer,DRIVER_MEASURE_MODULATION);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_MODULATION=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_POWER,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_POWER=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_LOCK,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_LOCK=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_RATE,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_RATE=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_SNR,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_SNR=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_CHANNEL,$http_content);
						$buffer = reformatData($buffer,$device_data_separator);
						push(@driver_info,"DRIVER_INFO_UPSTREAM_CHANNEL=$buffer");

						$buffer = getValuesFromHTML(DRIVER_INFO_WAN_STATUS,$http_content);
						$buffer = forceNumeric($buffer);
						push(@driver_info,"DRIVER_INFO_WAN_STATUS=$buffer");

						$buffer = getValuesFromHTML(DRIVER_INFO_TOD_SUCCESS,$http_content,,1);
						$buffer = forceNumeric($buffer);
						push(@driver_info,"DRIVER_INFO_TOD_SUCCESS=$buffer");

						$retcode = RESPONSE_OK;
						$error = NO_ERROR;

					} else {
						$flag_continue = 0;
						writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
					}
				} else {
					$flag_continue = 0;
					writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
				}
			}

			#	NETWORK STATUS

			if ($flag_continue) {
		
				$url = "$device_protocol://$device_address/$device_network_page";

				writelog(STRING_ATTEMPTING_TO_GET_NETWORK_PAGE,TRACE);

				$browser->get($url);

				if ($browser->success) {

					# Get Data
					# NETWORK

					$http_title = $browser->title();
					$http_mime = $browser->content_type();
					$http_content = $browser->content;
					$http_status = $browser->status();
					$http_message = $browser->response()->status_line;
					$current_uri = $browser->uri();

					$http_title = NO_DATA unless defined $http_title;

					writelog(STRING_BROWSE_SUCCESS,TRACE);

					writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
					writelog(STRING_TITLE . ": $http_title",TRACE);
					writelog(STRING_MIME . ": $http_mime",TRACE);

					if ($opt_driver_dump_http) {
						$pathname = "$dump_path/$dump_file_network" . $dump_file_http_suffix . "." . $dump_file_extension;

						writelog("NETWORK" . STRING_DUMPING_RAW . " $pathname",TRACE);

						if (rawToFile($http_content,$pathname)) {
								writelog(STRING_DATA_DUMP_SUCCESS,TRACE);
							} else {
								writelog(STRING_DATA_DUMP_FAILED,TRACE);
						}
					}

					$flag_continue = 1;

					if ($flag_continue) {
						writelog("Extracting Data: NETWORK",TRACE);

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_LAN_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_LAN_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_WAN_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PRIVATE_LAN_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PRIVATE_LAN_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PRIVATE_MAC,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PRIVATE_MAC=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DHCP_SERVER_CONFIG_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DHCP_SERVER_CONFIG_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_WAN_DHCP_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_DHCP_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_WAN_DHCP_SUBNET_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_DHCP_SUBNET_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_WAN_DHCP_GATEWAY_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_DHCP_GATEWAY_V4=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_INTERNET_INFO_V4,$http_content);
						push(@driver_network,"DRIVER_NETWORK_INTERNET_INFO_V4=$buffer");

						$buffer = getValuesFromHTML(DRIVER_NETWORK_WAN_STATUS,$http_content);
						$connection_status = int($buffer);
						push(@driver_network,"DRIVER_NETWORK_WAN_STATUS=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_NETWORK_PUBLIC_WAN_DHCP_LEASE,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_DHCP_LEASE=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_NETWORK_STATIC_IP_BLOCK,$http_content);
						push(@driver_network,"DRIVER_NETWORK_STATIC_IP_BLOCK=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PUBLIC_WAN_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PUBLIC_WAN_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DHCP_SERVER_CONFIG_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DHCP_SERVER_CONFIG_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DHCP_DNS_PRIMARY_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DHCP_DNS_PRIMARY_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DHCP_DNS_SECONDARY_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DHCP_DNS_SECONDARY_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_PRIVATE_LAN_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PRIVATE_LAN_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DNS_PRIMARY_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DNS_PRIMARY_V6=$buffer");

						$buffer = getQuotedValuesFromHTML(DRIVER_NETWORK_DNS_SECONDARY_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_DNS_SECONDARY_V6=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_NETWORK_PRIVATE_LAN_GATEWAY_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PRIVATE_LAN_GATEWAY_V6=$buffer");

						$buffer = getValuesFromHTMLTable(DRIVER_NETWORK_PREFIX_DELEGATIONS_V6,$http_content);
						push(@driver_network,"DRIVER_NETWORK_PREFIX_DELEGATIONS_V6=$buffer");
					}

					$retcode = RESPONSE_OK;
					$error = NO_ERROR;
				} else {
					$flag_continue = 0;
					writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
				}
			} else {
				$flag_continue = 0;
				writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
			}

			#	Set Flag (to do : should be smarter)


			if ($flag_continue) {
				$flag_data_gathered = 1;
				$data_timestamp = time;
			}

			#	LOGOUT

			if ($flag_continue) {
				if ($opt_driver_logout) {
					if ($device_logout_page) {
						# Logout if Requested

						$url = "$device_protocol://$device_address/$device_logout_page";
	
						writelog(STRING_ATTEMPTING_TO_LOGOUT,TRACE);
	
						$browser->get($url);

						if ($browser->success) {
							# Logout

							$http_title = $browser->title();
							$http_mime = $browser->content_type();
							$http_content = $browser->content;
							$http_status = $browser->status();
							$http_message = $browser->response()->status_line;
							$current_uri = $browser->uri();

							$http_title = NO_DATA unless defined $http_title;
	
							writelog(STRING_BROWSE_SUCCESS,TRACE);

							writelog(STRING_CURRENT_URL . ": $current_uri",TRACE);
							writelog(STRING_TITLE . ": $http_title",TRACE);
							writelog(STRING_MIME . ": $http_mime",TRACE);

							$flag_continue = 0;
							$retcode = RESPONSE_OK;
							$error = NO_ERROR;
						} else {
							$flag_continue = 0;
							writelog(STRING_ERROR_PREFIX . STRING_ERROR_LOGGING_OUT,TRACE);
						}
					} else {
						$flag_continue = 0;
						writelog(STRING_ERROR_PREFIX . STRING_ERROR_NO_LOGOUT_PAGE,TRACE);
					}
				} else {
					writelog(STRING_WARNING_LOGOUT_NOT_REQUIRED,TRACE);
				}
			} else {
				$flag_continue = 0;
				writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
			}
		} else {
			writelog(STRING_ERROR_PREFIX . STRING_ERROR_NO_START_PAGE,TRACE);
		}
	} else {
		writelog(STRING_ERROR_PREFIX . STRING_ERROR_ABORTED,TRACE);
	}

	return ($retcode,$error);
}

