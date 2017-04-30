#
#	Broadband Status
#	RESOURCE LIBRARY
#		Data Fields
#
#	Author: Lee Thompson <thompsonl@logh.net>
#
#=============================================================================
#	NOT YET IMPLEMENTED
#
#	This is simply a bunch of constants used to define fields so
#	if something gets changed later, it only needs changed in one place.
#=============================================================================

use strict;
use warnings;

use constant{
	#	Global

	UNSUPPORTED => "unsupported",
	FUNCTION_UNSUPPORTED => "Function not supported",
	DEVICE_UNSUPPORTED => "Device is not supported",
	NOT_APPLICABLE => -1,

	RESPONSE_NA => -1,
	RESPONSE_ERROR => 0,
	RESPONSE_OK => 1,
	NO_RECORD => "*",
	NO_FIELD => "*",
	NO_ERROR => "OK",
	NO_DATA => "******",
	NOT_REQUIRED => "0",

	#	Device 

	#		Tests

	DEVICE_ICMP_RESULT => "icmp_result",
	DEVICE_ICMP_TIME => "icmp_time",

	DEVICE_TCP_PORT => "tcp_port",
	DEVICE_TCP_RESULT => "tcp_result",
	DEVICE_TYPE => "device_type",

	#		Technology

	DEVICE_BROADBAND_TECHNOLOGY => "broadband_technology",
	DEVICE_BROADBAND_TECHNOLOGY_VERSION => "broadband_technology_version",

	#		Connection

	DEVICE_CONNECTION_STATUS => "connection_status",
	DEVICE_CONNECTION_MODULATION_MODE => "connection_modulation_mode",
	DEVICE_CONNECTION_PATH_MODE => "connection_path_mode",
	DEVICE_CONNECTION_ENCAPSULATION => "connection_encapsulation",
	DEVICE_CONNECTION_MULTIPLEXING => "connection_multiplexing",
	DEVICE_CONNECTION_QOS => "connection_qos",
	DEVICE_CONNECTION_PCR_RATE => "connection_pcr_rate",
	DEVICE_CONNECTION_SCR_RATE => "connection_scr_rate",
	DEVICE_CONNECTION_AUTODETECT => "connection_autodetect",
	DEVICE_CONNECTION_VPI => "connection_vpi",
	DEVICE_CONNECTION_VCI => "connection_vci",
	DEVICE_CONNECTION_ENABLED => "connection_enabled",
	DEVICE_CONNECTION_PVC_STATUS => "connection_pvc_status",
	
	#		Downstream

	DEVICE_DOWNSTREAM_CHANNEL_COUNT => "downstream_channel_count",
	DEVICE_DOWNSTREAM_DATA_RATE => "downstream_data_rate",
	DEVICE_DOWNSTREAM_ATTENUATION => "downstream_attenuation",
	DEVICE_DOWNSTREAM_TRANSMIT_POWER => "downstream_transmit_power",
	DEVICE_DOWNSTREAM_MARGIN => "downstream_margin",
	DEVICE_DOWNSTREAM_FREQUENCY => "downstream_frequency",
	DEVICE_DOWNSTREAM_MODULATION => "downstream_modulation",
	DEVICE_DOWNSTREAM_POWER => "downstream_power",
	DEVICE_DOWNSTREAM_LOCK_STATUS => "downstream_lock",
	DEVICE_DOWNSTREAM_SYMBOL_RATE => "downstream_symbol_rate",
	DEVICE_DOWNSTREAM_SNR => "downstream_snr",
	DEVICE_DOWNSTREAM_CHANNEL_ID => "downstream_channel_id",

	#		Upstream

	DEVICE_UPSTREAM_CHANNEL_COUNT => "upstream_channel_count",
	DEVICE_UPSTREAM_DATA_RATE => "upstream_data_rate",
	DEVICE_UPSTREAM_ATTENUATION => "upstream_attenuation",
	DEVICE_UPSTREAM_TRANSMIT_POWER => "upstream_transmit_power",
	DEVICE_UPSTREAM_MARGIN => "upstream_margin",
	DEVICE_UPSTREAM_FREQUENCY => "upstream_frequency",
	DEVICE_UPSTREAM_MODULATION => "upstream_modulation",
	DEVICE_UPSTREAM_POWER => "upstream_power",
	DEVICE_UPSTREAM_LOCK_STATUS => "upstream_lock",
	DEVICE_UPSTREAM_SYMBOL_RATE => "upstream_symbol_rate",
	DEVICE_UPSTREAM_SNR => "upstream_snr",
	DEVICE_UPSTREAM_CHANNEL_ID => "upstream_channel_id",

	#		Network

	DEVICE_NETWORK_ADDRESS_ASSIGNMENT_TYPE => "network_address_assignment_type",

	DEVICE_NETWORK_ADDRESS_WAN_COUNT => "network_address_wan_count",
	DEVICE_NETWORK_ADDRESS_WAN => "network_address_wan",
	DEVICE_NETWORK_ADDRESS_WAN_MAC => "network_address_wan_mac",
	DEVICE_NETWORK_ADDRESS_WAN_MASK => "network_address_wan_mask",
	DEVICE_NETWORK_ADDRESS_WAN_GATEWAY => "network_address_wan_gateway",
	DEVICE_NETWORK_ADDRESS_WAN_DNS_PRIMARY => "network_address_wan_dns1",
	DEVICE_NETWORK_ADDRESS_WAN_DNS_SECONDARY => "network_address_wan_dns2",
	DEVICE_NETWORK_ADDRESS_WAN_LEASE_REMAINING => "network_address_wan_lease",
	DEVICE_NETWORK_ADDRESS_WAN_BLOCK => "network_address_wan_block",

	DEVICE_NETWORK_ADDRESS_LAN_COUNT => "network_address_lan_count",
	DEVICE_NETWORK_ADDRESS_WAN => "network_address_wan",
	DEVICE_NETWORK_ADDRESS_LAN_MAC => "network_address_lan_mac",
	DEVICE_NETWORK_ADDRESS_LAN_MASK => "network_address_lan_mask",
	DEVICE_NETWORK_ADDRESS_LAN_GATEWAY => "network_address_lan_gateway",
	DEVICE_NETWORK_ADDRESS_LAN_DNS_PRIMARY => "network_address_lan_dns1",
	DEVICE_NETWORK_ADDRESS_LAN_DNS_SECONDARY => "network_address_lan_dns2",
	DEVICE_NETWORK_ADDRESS_LAN_LEASE_REMAINING => "network_address_lan_lease",
	DEVICE_NETWORK_ADDRESS_LAN_BLOCK => "network_address_lan_block",

	#		Device Services

	DEVICE_SERVICE_DHCPD_ENABLED => "service_dhcpd_enabled",
	DEVICE_SERVICE_DHCPD_START =>  "service_dhcpd_range_start",
	DEVICE_SERVICE_DHCPD_END =>  "service_dhcpd_range_end",
	DEVICE_SERVICE_DHCPD_LEASE =>  "service_dhcpd_lease",
	DEVICE_SERVICE_DNSD_ENABLED => "service_dnsd_enabled",
	DEVICE_SERVICE_UPNP_ENABLED => "service_upnp_enabled",
	DEVICE_SERVICE_WIFI_ENABLED => "service_wifi_enabled",

	#		Device Status

	DEVICE_STATUS_TIME_OF_DAY => "status_timeofday_status",
	DEVICE_STATUS_OPERATING_MODE => "status_operating_mode",

	#		Device Information

	DEVICE_INFO_MANUFACTURER => "info_manufacturer",
	DEVICE_INFO_MODEL => "info_model",
	DEVICE_INFO_HARDWARE_VERSION => "info_hardware_version",
	DEVICE_INFO_FIRMWARE_VERSION => "info_firmware_version",
	DEVICE_INFO_UPTIME => "info_uptime",
	
	#	Measures
	
	MEASURE_POWER_DBMV => "dBmV",
	MEASURE_SIGNAL_DB => "dB",
	MEASURE_FREQ_GHZ => "GHz",
	MEASURE_FREQ_MHZ => "MHz",
	MEASURE_FREQ_HZ => "Hz",
	MEASURE_TIME_MILLISECONDS => "ms",
	MEASURE_TIME_SECONDS => "s",
	MEASURE_TIME_MINUTES => "m",
	MEASURE_TIME_HOURS => "h",
	MEASURE_TIME_DAYS => "d",
	MEASURE_TIME_YEARS => "y",
	MEASURE_RATE_SYMBOLS_MSEC => "Msym",
	MEASURE_RATE_KILOBITS => "kbps",
	MEASURE_RATE_MEGABITS => "mbps",
	MEASURE_RATE_GIGABITS => "gbps",
	MEASURE_RATE_KILOBYTES => "Kbps",
	MEASURE_RATE_MEGABYTES => "Mbps",
	MEASURE_RATE_GIGABYTES => "Gbps",
};

1;

	

