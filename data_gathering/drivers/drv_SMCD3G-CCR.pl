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
#			remove included units of measure?
#		logging driver should be TRACE not DEBUG
#		true initialization function
#		parse all the data
#			partial
#		build structures to send back to data gathering program
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
	DRIVER_FAMILY => "comcast_business_01",
	DRIVER_DEVICES => "SMCD3G-CCR",				# Use bar | to separate
	DRIVER_VERSION => "201507022044",
	
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
	DEFAULT_DUMP_PATH => ".",
	DEFAULT_DUMP_FILE_INFO => "info.txt",
	DEFAULT_DUMP_FILE_STATUS => "status.txt",
	DEFAULT_DUMP_FILE_NETWORK => "network.txt",
	DEFAULT_DUMP_HTTP => 1,
	DEFAULT_DUMP_DATA => 1,
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
	DRIVER_DEVICE_URL_LOGIN => "/",					#	Login URL
	DRIVER_DEVICE_URL_STATUS => "user/feat-gateway-status.asp",	# 	Status Page URL
	DRIVER_DEVICE_URL_INFO =>  "user/feat-gateway-modem.asp",	#	Info Page URL
	DRIVER_DEVICE_URL_NETWORK =>  "user/feat-gateway-network.asp",	#	Network Page URL
	DRIVER_DEVICE_URL_LOGOUT => "gocusform/logout",			#	Logout Page URL
	DRIVER_DEVICE_ADDRESS => "10.1.10.1",				#	LAN IP Address
	DRIVER_DEVICE_USERNAME => "cusadmin",				#	Username
	DRIVER_DEVICE_PASSWORD => "highspeed",				#	Password
	DRIVER_DEVICE_IS_OEM => 1,					#	Is an OEM Model?
	DRIVER_DEVICE_REQUIRE_LOGIN => 1,				#	Is login required?
	DRIVER_DEVICE_REQUIRE_LOGOUT => 0,				#	Is logout required?
#
#	Units of Measure
#
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
	DRIVER_INFO_LOD_SUCCESS => "var TodSuccess",					# Time of Day Status (0 not set, 1 set)
	
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

# Paths

my $dump_path = DEFAULT_DUMP_PATH;
my $dump_file_info = DEFAULT_DUMP_FILE_INFO;
my $dump_file_status = DEFAULT_DUMP_FILE_STATUS;
my $dump_file_network = DEFAULT_DUMP_FILE_NETWORK;

# Options

my $opt_hash_content = parseBoolean(DEFAULT_CONTENT_HASH);
my $opt_driver_dump_http = DEFAULT_DUMP_HTTP;
my $opt_driver_dump_data = DEFAULT_DUMP_DATA;
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
sub driverGetDeviceData{
	# pass in data?
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

	writelog("Requesting URL: $url",DEBUG);
	
	# this function will vary by driver, some devices may have more pages, others less

	# some kind of availability check here

	# ability to do content type decoding if needed

	# should follow redirects if needed

	# to do
	# login should only occur if opt_driver_login is true

	$flag_continue = 1;

	if ($flag_continue) {

		# Get Login Page

		$browser->get($url);

		if ($browser->success) {

			# Submit Form

			$flag_continue = 1;

			$http_title = $browser->title();
			$http_mime = $browser->content_type();
			$http_content = $browser->content;
			$http_status = $browser->status();
			$http_message = $browser->response()->status_line;
			$current_uri = $browser->uri();

			$http_title = NO_DATA unless defined $http_title;

			writelog("Browse Success",DEBUG);

			writelog("Current URI: $current_uri",DEBUG);
			writelog("Title: $http_title",DEBUG);
			writelog("Mime: $http_mime",DEBUG);
	
			writelog("Submitting Login Form",DEBUG);

			# to do: form field number and field names should be soft

			$result = $browser->submit_form(
					form_number => 1,
                              		fields => {
						user => $device_username,
						pws => $device_password
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
		
				writelog("Login Success",DEBUG);
				writelog("Current URI: $current_uri",DEBUG);
				writelog("Title: $http_title",DEBUG);
				writelog("Mime: $http_mime",DEBUG);

				#	STATUS

				if ($flag_continue) {
					# Get Page for Data

					$url = "$device_protocol://$device_address/$device_status_page";

					writelog("Attemping to Get Status Page",DEBUG);

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

						writelog("Browse Success",DEBUG);

						writelog("Current URI: $current_uri",DEBUG);
						writelog("Title: $http_title",DEBUG);
						writelog("Mime: $http_mime",DEBUG);

						if ($opt_driver_dump_data) {
							$pathname = "$dump_path/$dump_file_status";

							if (rawToFile($http_content,$pathname)) {
									writelog("Status Data Dump Written Successfully",DEBUG);
								} else {
									writelog("Status Data Dump Write Failed",DEBUG);
							}
						}

						$flag_continue = 1;

						if ($flag_continue) {
								writelog("Extracting Data: STATUS",DEBUG);

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
						}

						$retcode = RESPONSE_OK;
						$error = NO_ERROR;

					} else {
						$flag_continue = 0;
						writelog("Aborted",DEBUG);
					}
				} else {
					$flag_continue = 0;
					writelog("Aborted",DEBUG);
				}

				#	DEVICE INFO

				if ($flag_continue) {
					# Get Page for Info

					$url = "$device_protocol://$device_address/$device_info_page";

					writelog("Attemping to Get Info Page",DEBUG);

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

						writelog("Browse Success",DEBUG);

						writelog("Current URI: $current_uri",DEBUG);
						writelog("Title: $http_title",DEBUG);
						writelog("Mime: $http_mime",DEBUG);

						if ($opt_driver_dump_data) {
							$pathname = "$dump_path/$dump_file_info";

							if (rawToFile($http_content,$pathname)) {
									writelog("Info Data Dump Written Successfully",DEBUG);
								} else {
									writelog("Info Data Dump Write Failed",DEBUG);
							}
						}

						$flag_continue = 1;

						if ($flag_continue) {
								writelog("Extracting Data: INFO",DEBUG);

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_FREQUENCY,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_FREQUENCY=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_MODULATION,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_MODULATION=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_POWER,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_POWER=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_LOCK,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_LOCK=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_RATE,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_RATE=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_SNR,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_SNR=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_DOWNSTREAM_CHANNEL,$http_content);
								push(@driver_info,"DRIVER_INFO_DOWNSTREAM_CHANNEL=$buffer");


								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_FREQUENCY,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_FREQUENCY=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_MODULATION,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_MODULATION=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_POWER,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_POWER=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_LOCK,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_LOCK=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_RATE,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_RATE=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_SNR,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_SNR=$buffer");

								$buffer = getQuotedValuesFromHTML(DRIVER_INFO_UPSTREAM_CHANNEL,$http_content);
								push(@driver_info,"DRIVER_INFO_UPSTREAM_CHANNEL=$buffer");

								$buffer = getValuesFromHTML(DRIVER_INFO_WAN_STATUS,$http_content);
								$connection_status = forceNumeric($buffer);
								push(@driver_info,"DRIVER_INFO_WAN_STATUS=$buffer");

								$buffer = getValuesFromHTML(DRIVER_INFO_LOD_SUCCESS,$http_content);
								$buffer = forceNumeric($buffer);
								push(@driver_info,"DRIVER_INFO_LOD_SUCCESS=$buffer");

						}

						$retcode = RESPONSE_OK;
						$error = NO_ERROR;

					} else {
						$flag_continue = 0;
						writelog("Aborted",DEBUG);
					}
				}

				#	NETWORK STATUS

				if ($flag_continue) {
					# Get Page for Network Status

					$url = "$device_protocol://$device_address/$device_network_page";

					writelog("Attemping to Get Network Page",DEBUG);

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

						writelog("Browse Success",DEBUG);

						writelog("Current URI: $current_uri",DEBUG);
						writelog("Title: $http_title",DEBUG);
						writelog("Mime: $http_mime",DEBUG);

						if ($opt_driver_dump_data) {
							$pathname = "$dump_path/$dump_file_network";

							if (rawToFile($http_content,$pathname)) {
									writelog("Network Data Dump Written Successfully",DEBUG);
								} else {
									writelog("Network Data Dump  Write Failed",DEBUG);
							}
						}

						$flag_continue = 1;

						if ($flag_continue) {
								writelog("Extracting Data: NETWORK",DEBUG);

# getValuesFromHTML
# getValuesFromHTMLTable
# getQuotedValuesFromHTML
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
						writelog("Aborted",DEBUG);
					}
				}

				#	Set Flag (to do : should be smarter)


				if ($flag_continue) {
					$flag_data_gathered = 1;
					$data_timestamp = time;
				}

				#	LOGOUT

				if ($flag_continue) {
					if ($opt_driver_logout) {
						# Logout if Requested

						$url = "$device_protocol://$device_address/$device_logout_page";
	
						writelog("Attemping to Logout",DEBUG);
	
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

						writelog("Browse Success",DEBUG);

						writelog("Current URI: $current_uri",DEBUG);
						writelog("Title: $http_title",DEBUG);
						writelog("Mime: $http_mime",DEBUG);

						$flag_continue = 0;
						$retcode = RESPONSE_OK;
							$error = NO_ERROR;
						} else {
							$flag_continue = 0;
							writelog("Error Logging Out",DEBUG);
						}
					}
				} else {
					$flag_continue = 0;
					writelog("Aborted",DEBUG);
				}
			} else {
				$flag_continue = 0;
				writelog("Login Failed",DEBUG);
			}
		} else {
			writelog("Failed to get Login Page",DEBUG);
		}
	} else {
		writelog("Aborted",DEBUG);
	}

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



