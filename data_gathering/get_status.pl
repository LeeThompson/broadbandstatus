#
#	Broadband Status
#	DATA GATHERING SCRIPT
#
#	Lee Thompson <thompsonl@logh.net>
#
#=============================================================================
# to do:
#	load config
#	validate config
#	range checking
#	config section for broadband device driver?
#	load and configure broadband device driver
#	get info from driver for diagnostics/logging
#	get data (DONE)
#	validate data
#	better data handling
#		data in structure?
#	flesh out/hook up command line options
#	do ping tests? separate libraries?
#	report data to chosen destinations (separate libraries? but want to do any combination)
#	alerts? smtp? growl? (separate libraries? but want to do any combination)
#	error handling
#	testing
#	documentation
#	implement resource library for strings (eventual)
#	config?
#		tests
#		alerts
#		output
#=============================================================================

package BBStatus;

use strict;
use warnings;

use Digest::MD5;
use Encode qw(encode_utf8);
use Getopt::Long;
use HTML::TableExtract;
use POSIX qw( strftime getcwd );
use Switch;
use Time::Local;

use constant{
	PROGRAM_SHORT_NAME => "get_status",
	PROGRAM_NAME => "Information Gathering",
	PROGRAM_ICON => "",
	PROGRAM_VERSION => "201607201308",
	CONFIG_SECTION_MAIN => "configuration",
	CONFIG_SECTION_DATABASE => "database",
	OUTPUT_TYPE_CON => 0,
	OUTPUT_TYPE_SQL => 1,
	OUTPUT_TYPE_CSV => 2,
	DEBUG_INFO_DUMP_FILE => "dump_info",
	DEBUG_STATUS_DUMP_FILE => "dump_status",
	DEBUG_NETWORK_DUMP_FILE => "dump_network",
	DEBUG_OPT_DUMP_DATA => 1,
	DEBUG_OPT_DUMP_USE_DRIVER_PREFIX => 1,
	DEFAULT_VERBOSE => 1,
	DEFAULT_DEBUG => 1,
	DEFAULT_SHOWTIME => 1,
	DEFAULT_TRACE => 0,
	DEFAULT_FATAL => "GENERAL",
	DEFAULT_DATE_FORMAT => "%Y-%m-%d",
	DEFAULT_TIME_FORMAT => "%H:%M:%S",
	DEFAULT_PATH => ".",
	DEFAULT_CONFIG => "broadbandstatus.conf",
	DEFAULT_LOG_FILE => "get_status.log",
	DEFAULT_LOG_TO_FILE => 0,
	DEFAULT_APPEND_LOG_FILE => 0,
	DEFAULT_LOGLEVEL => 5,
	DEFAULT_ARRAY_SEPARATOR => "|",
	DEFAULT_STRING_SEPARATOR => ",",
	DEFAULT_QUOTE_SYMBOL => "'",
	DEFAULT_CONSOLE_OUTPUT => 1,
	DEFAULT_PATH_DEBUG => "debug",
	DEFAULT_PATH_DRIVER => "drivers",
	DEFAULT_DRIVER => "SMCD3G-CCR",
	DEFAULT_DUMP_EXTENSION => "txt",
	DEFAULT_DRIVER_EXTENSION => "pl",
	DEFAULT_DRIVER_PREFIX => "drv_",
	DEFAULT_TRIM_WHITESPACE => 0,
	ALWAYS => 0,
	VERBOSE => 1,
	DEBUG => 2,
	TRACE => 3,
	DEEP => 4,
	ERROR => -1,
	SILENT => -2,
	BOOLEAN => 1,
	APPEND => 1,
	ENCODING_CRLF => "crlf",
	ENCODING_UTF16 => "encoding(UTF-16)",
	LOG_SEPARATOR => "***",

	NO_DATA => "!!!",
	NO_FIELD => "!!!",
	NO_ERROR => "",
	RESPONSE_ERROR => 0,
	RESPONSE_OK => 1,

	ERROR_DRIVER_NOT_FOUND => "Driver not found",
	ERROR_FILE_NOT_FOUND => "File not found",
	ERROR_MISSING_MODEL => "No model given.",
	ERROR_OFFLINE => "Could not contact device.",
	ERROR_INVALID => "Device returned invalid or no data.",
	ERROR_UNKNOWN_STATUS => "Unknown status code.",
	ERROR_UNSUPPORTED => "Not supported",
	ERROR_UNKNOWN => "UNKNOWN",
	OPERATING_MODE_BRIDGE => "Bridging",
	OPERATING_MODE_GATEWAY => "Gateway",

	LIBRARY_DATA_FIELDS => "lib_datafields.pl",
	LIBRARY_FILE_ALERTS => "lib_alerts.pl",
#	LIBRARY_FILE_OUTPUT => "lib_output.pl",
	LIBRARY_FILE_OUTPUT => "lib_output_sql.pl",
	LIBRARY_FILE_TESTS => "lib_tests.pl",
};

# Global

our ($global_trimwhitespace);
$global_trimwhitespace = DEFAULT_TRIM_WHITESPACE;

# Variables, Arrays and Structures

my $device_driver;
my $device_model;

my $debug_path;
my $driver_path;

my $opt_dump_file_network;
my $opt_dump_file_info;
my $opt_dump_file_status; 
my $opt_dump_use_driver_prefix;
my $opt_dump_data;

my $dump_pathname;
my $dump_ext;
my $driver_ext;
my $driver_prefix;

my $output_type;

my $configfile;
my $dateformat;
my $timeformat;

my $logfile;
my $loglevel;

my $opt_showtime;
my $opt_verbose;
my $opt_debug;
my $opt_trace;
my $opt_console_output;
my $opt_silent;
my $opt_loglevel;
my $opt_logfile;

my $driver_pathname;

my $flag_do_processing;
my $flag_response_ok;
my $flag_download_ok;
my $flag_log_to_file;
my $flag_append_log;

my $retval;
my $retcode;

my $last_http_error;
my $error_message;
my $buffer;

my $start_run_time;
my $finish_run_time;
my $elapsed_run_time;

my %device_data;
#
#	device_data{deviceid}{item}
#	
#	should be a NOT_AVAILABLE constant instead of
#	leaving it undef to keep warnings from being annoying
#	
my @device_info_buffer = ();
my @device_status_buffer = ();
my @device_network_buffer = ();

#	Populate Values with Defaults


$opt_dump_file_network = DEBUG_NETWORK_DUMP_FILE;
$opt_dump_file_info = DEBUG_INFO_DUMP_FILE;
$opt_dump_file_status = DEBUG_STATUS_DUMP_FILE;
$opt_dump_use_driver_prefix = parseBoolean(DEBUG_OPT_DUMP_USE_DRIVER_PREFIX);
$opt_dump_data = parseBoolean(DEBUG_OPT_DUMP_DATA);

$device_driver = DEFAULT_DRIVER;

$debug_path = DEFAULT_PATH_DEBUG;
$driver_path = DEFAULT_PATH_DRIVER;

$dump_ext = DEFAULT_DUMP_EXTENSION;
$driver_ext = DEFAULT_DRIVER_EXTENSION;
$driver_prefix = DEFAULT_DRIVER_PREFIX;

$opt_showtime = parseBoolean(DEFAULT_SHOWTIME);
$opt_verbose = parseBoolean(DEFAULT_VERBOSE);
$opt_debug = parseBoolean(DEFAULT_DEBUG);
$opt_trace = parseBoolean(DEFAULT_TRACE);
$opt_console_output = parseBoolean(DEFAULT_CONSOLE_OUTPUT);
$opt_silent = 0;
$opt_loglevel = DEBUG;
$opt_logfile = "";

$dateformat = DEFAULT_DATE_FORMAT;
$timeformat = DEFAULT_TIME_FORMAT;

$logfile = DEFAULT_LOG_FILE;
$loglevel = DEFAULT_LOGLEVEL;

$flag_log_to_file = DEFAULT_LOG_TO_FILE;
$flag_append_log = DEFAULT_APPEND_LOG_FILE;
$flag_do_processing = 0;
$flag_response_ok = 0;
$flag_download_ok = 0;

$retval = 0;
$retcode = 0;
$error_message = "";

$output_type = OUTPUT_TYPE_CON;

$configfile = DEFAULT_CONFIG;


# Process Command Line Options

my $result = GetOptions (
			 "configfile=s" => \$configfile,
		         "silent" => \$opt_silent,
			 "logfile" => \$opt_logfile,
			 "level=s" => \$opt_loglevel,
			 "debug" => \$opt_debug,
			 "verbose" => \$opt_verbose,
			 "trace" => \$opt_trace,
			 "help|?" => sub{showHelp()},
		        );



#-----------------------------------------------------------
# Program Start
#-----------------------------------------------------------

$start_run_time = time;

$retval = readConfig($configfile);

#	Configuration Overrides

if ($opt_silent) {
	$loglevel = SILENT;
}

if ($opt_logfile) {
	$logfile = $opt_logfile;
	$flag_log_to_file = 1;
}

if ($opt_loglevel) {
	$loglevel = $opt_loglevel;
}

# 	Initialize Log

if ($flag_log_to_file) {
	initializeLog();
}

#	Start 

writelog(PROGRAM_NAME . " v" . PROGRAM_VERSION,ALWAYS);
writelog("",ALWAYS);
showDebugLevel();

if ($retval) {
	writelog("Configuration Read",DEBUG);
	$flag_do_processing = 0;
} else {
	writelog("Error reading configuration from $configfile",ERROR);
}

if (!$opt_silent) {
	if ($loglevel < 0) {
		$loglevel = 0;
	}
}

writelog("Checking Configuration",DEBUG);



writelog("Configuration Read",DEBUG);

#	Show Configuration Flags


# Libraries

if (require(LIBRARY_FILE_ALERTS)) {
	writelog("Library: Alerts - LOADED",DEBUG);
	writelog("Alerts Library v" . alertsGetVersion(),DEBUG);
} else {
	writelog("Library: Alerts - FAILED",ERROR);
}

if (require(LIBRARY_FILE_OUTPUT)) {
	writelog("Library: Output - LOADED",DEBUG);
	writelog("Output Library v" . outputGetVersion(),DEBUG);
} else {
	writelog("Library: Output - FAILED",ERROR);
}

if (require(LIBRARY_FILE_TESTS)) {
	writelog("Library: Tests - LOADED",DEBUG);
	writelog("Tests Library v" . testsGetVersion(),DEBUG);
} else {
	writelog("Library: Tests - FAILED",ERROR);
}


#	LOAD AND INITIALIZE DRIVER

#  to do	TEMPORARY DEBUG CRAP

$device_model = "SMCD3G-CCR";
# $device_model = "CG3000DCR";

($retcode,$error_message) = loadDriver($device_model);

if ($retcode) {
	writelog("Driver for $device_model loaded",DEBUG);
	writelog("Driver v" . driverGetVersion(),DEBUG);
	$flag_do_processing = 1;
} else {
	writelog("Could not load driver for $device_model",DEBUG);
	writelog($error_message,DEBUG);
	$flag_do_processing = 0;
}

#	Start It Up

if ($flag_do_processing) {
	# do stuff

	($retcode,$error_message) = driverGetDeviceData($device_model);
	writelog("retcode: $retcode for driverGetDeviceData",DEBUG);

# to do
#	besides driver version, there should be one call into driver that populates a
#	reference away containing validated and normalized data
#
#	this array also works on defines so:
#
# $array{DEVICE_CONNECTION_STATUS} would have the connection status
# $array{DEVICE_DOWNSTREAM_CHANNEL_COUNT} would tell us how many downstream channels there ar
#	each channel woudl be instanced, so:
# $array{DEVICE_DOWNSTREAM_FREQUENCY}{3} would give the frequency for the third downstream channel
#
# it will be up to get_status to pass along the proper format to output and/or alerts




	if ($retcode) {
		# to do 
		#	do actual stuff with data instead of dumping to a file

		$retcode = driverGetDeviceDataStatus(\@device_status_buffer);
		writelog("retcode: $retcode for driverGetDeviceDataStatus",DEBUG);
		if ($opt_dump_data) {
			$dump_pathname = $opt_dump_file_status . "." . $dump_ext;
			if ($opt_dump_use_driver_prefix) {
				$dump_pathname = $device_model . "_" . $dump_pathname;
			}
			$dump_pathname = $debug_path . "/$dump_pathname";
			writelog("Dumping Status Buffer to $dump_pathname",DEBUG);
			dumpToFile(\@device_status_buffer,$dump_pathname);
		}

		$retcode = driverGetDeviceDataInfo(\@device_info_buffer);
		writelog("retcode: $retcode for driverGetDeviceDataInfo",DEBUG);
		if ($opt_dump_data) {
			$dump_pathname = $opt_dump_file_info . "." . $dump_ext;
			if ($opt_dump_use_driver_prefix) {
				$dump_pathname = $device_model . "_" . $dump_pathname;
			}
			$dump_pathname = $debug_path . "/$dump_pathname";
			writelog("Dumping Info Buffer to $dump_pathname",DEBUG);
			dumpToFile(\@device_info_buffer,$dump_pathname);
		}

		$retcode = driverGetDeviceDataNetwork(\@device_network_buffer);
		writelog("retcode: $retcode for driverGetDeviceDataNetwork",DEBUG);
		if ($opt_dump_data) {
			$dump_pathname = $opt_dump_file_network . "." . $dump_ext;
			if ($opt_dump_use_driver_prefix) {
				$dump_pathname = $device_model . "_" . $dump_pathname;
			}
			$dump_pathname = $debug_path . "/$dump_pathname";
			writelog("Dumping Network Buffer to $dump_pathname",DEBUG);
			dumpToFile(\@device_network_buffer,$dump_pathname);
		}

		# Report Status
		$retcode = outputReportInfo(\@device_info_buffer);
		
	} else {
		writelog("Failed to get Device Data: $error_message",ERROR);
	}
} else {
	writelog($error_message,ERROR);
}


#	End


$finish_run_time = time;
$elapsed_run_time = $finish_run_time - $start_run_time;

writelog("Execution time was $elapsed_run_time second" . getPlural($elapsed_run_time),VERBOSE);
writelog("Program Completed",ALWAYS);

#-----------------------------------------------------------
# FUNCTIONS
#-----------------------------------------------------------
#-----------------------------------------------------------
# Load Driver
#-----------------------------------------------------------
sub loadDriver{
	my $device_model = shift;
	my $driver_pathname;
	my $retval = 0;
	my $model_uc;
	my $driver_name = NO_DATA;	
	my $error_message = ERROR_MISSING_MODEL;

	return ($retval,$error_message) unless defined $device_model;

	$model_uc = uc $device_model;

	switch ($model_uc) {
		case "SMCD3G-CCR" { $driver_name = "SMCD3G-CCR"; }
		case "CG3000DCR" {  $driver_name = "CG3000DCR"; }
	}

	if ($driver_name eq NO_DATA) {
		$error_message = ERROR_UNSUPPORTED;
	} else {
		$error_message = "";
		$driver_pathname = "$driver_path/$driver_prefix$driver_name.$driver_ext";

		if (-e $driver_pathname) {
			$retval = require($driver_pathname);
			$error_message = "";
		} else {	
			$error_message = ERROR_DRIVER_NOT_FOUND;
		}
	}

	return ($retval,$error_message);
	
}

#-----------------------------------------------------------
# Show Debug Level
#-----------------------------------------------------------
sub showDebugLevel{
	my $debug_text = "";

	if ($loglevel >= TRACE) {
		$debug_text = addString($debug_text,"TRACE");
	}

	if ($loglevel >= DEEP) {
		$debug_text = addString($debug_text,"DEEP");
	}

	writelog("Debug is ON",DEBUG);
	if ($debug_text) {
		writelog("EXTENDED OPTIONS: $debug_text",DEBUG);
	}

	return;
}

#-----------------------------------------------------------
# Write Log
#-----------------------------------------------------------
sub writelog{
	my $temp_string = shift;
	my $temp_level = shift;
	my $temp_filemode = "";
	my $temp_prefix = "";
	my $flag_show = 0;

	$temp_string = "" unless defined $temp_string;
	$temp_level = ALWAYS unless defined $temp_level;

	if ($loglevel == SILENT) {
		return;
	}

	if ($temp_level == ALWAYS) {
		$flag_show = 1;
	}

	if ($temp_level == ERROR) {
		$flag_show = 1;
	}

	if ($temp_level == DEBUG) {
		$temp_prefix = "DEBUG: ";
	}

	if ($temp_level == TRACE) {
		$temp_prefix = "TRACE: ";
	}

	if ($temp_level == ERROR) {
		$temp_prefix = "ERROR: ";
	}

	if ($temp_level == DEEP) {
		$temp_prefix = "DEEP: ";
	}

	if ($loglevel >= $temp_level) {
		$flag_show = 1;
	}

	$temp_string = $temp_prefix . $temp_string if defined $temp_prefix;

	if ($flag_show) {
		if ($opt_console_output) {
			print "$temp_string\n";
		}
		if ($flag_log_to_file) {
			if (length($temp_string) > 0) {
				if (open(FOUT,">>$logfile")) {
					print FOUT getTimestamp() . " $temp_string\n";
				} else {
					$flag_log_to_file = 0;
				}
				close(FOUT);
			}
		}
	}

	return;
}

#--------------------------------------------------
# Initialize Log
#--------------------------------------------------
sub initializeLog{
	return unless defined $logfile;
	if ($flag_log_to_file) {
		if ($flag_append_log) {
			if (open(FOUT,">>$logfile")) {
				print FOUT getTimestamp() . " " . LOG_SEPARATOR . "\n";
			} else {
				$flag_log_to_file = 0;
			}
			close(FOUT);
		} else {
			unlink $logfile;
		}
	}
	return;
}

#--------------------------------------------------
# Remove Substring
#--------------------------------------------------
sub removeSubstring {
	my $content = shift;
	my $match_string = shift;

	return $content unless defined $content;
	return $content unless defined $match_string;

	$match_string = quotemeta($match_string);

	$content =~ s/$match_string//g;

	return $content;
}

#--------------------------------------------------
# Trim String
#--------------------------------------------------
sub trimString {
	my $tempvar = shift;

	$tempvar = "" unless defined $tempvar;

    	$tempvar =~ s/^\s+//;
    	$tempvar =~ s/\s+$//;

	return $tempvar;
}

#--------------------------------------------------
# Parse Quotes
#--------------------------------------------------
sub parseQuotes{
	my $temp = shift;
	my $flag_trim = shift;
	my $ret_string = "";
	my $ret_value = "";

	$temp = "" unless defined $temp;
	$flag_trim = $global_trimwhitespace unless defined $flag_trim;
	$flag_trim = forceNumeric($flag_trim);

	{
		$temp =~  /(.*)\"(.+)\"(.*)/;

		$ret_string = $temp;
		$ret_value = "";

		if (($1) || ($2)) {
			if ($3) {
				if ($flag_trim) {
					$ret_string = trimWhiteSpace($1) . trimString($3);
					$ret_value = trimWhiteSpace($2);
				} else {
					$ret_string = $1 . $3;
					$ret_value = $2;
				}
			} else { 
				if ($flag_trim) {
					$ret_string = trimWhiteSpace($1);
					$ret_value = trimWhiteSpace($2);
				} else { 
					$ret_string = $1;
					$ret_value = $2;
				}
			}
		}
	}

	return ($ret_string,$ret_value);
}

#--------------------------------------------------
# Line Starts with a Comment Character
#--------------------------------------------------
sub isComment{
	my $line = shift;
	my $retval = 0;

	$line = "\#" unless defined $line;

	$line = trimString($line);
	if ($line =~ /^\#/) {
		$retval = 1;
	}
	if ($line =~ /^\/\//) {
		$retval = 1;
	}

	return $retval;
}

#-----------------------------------------------------------
# Is Section
#-----------------------------------------------------------
sub isSection{
	my $line = shift;
	my $retval = 0;
	my $newsection = "";
	my $tempsection = "";

	$line = "" unless defined $line;

	$tempsection = quotemeta "[" . CONFIG_SECTION_MAIN . "]";
	if ($line =~ /^$tempsection$/i) {
		$newsection = CONFIG_SECTION_MAIN;
		$retval = 1;
	}

	$tempsection = quotemeta "[" . CONFIG_SECTION_DATABASE . "]";
	if ($line =~ /^$tempsection$/i) {
		$newsection = CONFIG_SECTION_DATABASE;
		$retval = 1;
	}

	return ($retval,$newsection);

}

#-----------------------------------------------------------
# Read Config
#-----------------------------------------------------------
sub readConfig{
	my $configfile = shift;
	my $line = "";
	my $retval = 0;
	my $junk = "";
	my $option = "";
	my $value = "";
	my $comment = "";
	my $section = "";
	my $newsection = "";
	my $file_encoding = "";
	my $tempsection = "";
	my $flag_skip = 0;

	return $retval unless defined $configfile;

	$file_encoding = getFileEncoding($configfile);

	if (open(FILE,"<:$file_encoding","$configfile")) {
		while (<FILE>) {
			$flag_skip = 0;
			$line = trimString($_);
			if (isComment($line)) {
				# Comment
			} else {
				if (length($line) > 0) {
					($flag_skip,$newsection) = isSection($line);

					if ($flag_skip) {
						$section = $newsection;
					} else {
						if ($section eq "[" . CONFIG_SECTION_MAIN . "]" ) {
							if ($line =~ /\=/) {

								# Main Section						
	
								$option = "";
								$value = "";

								($option,$value) = split("=",$line,2);
		
								$retval++;
			
								$option = trimString($option);
								$value = trimString($value);
		
								# Strip Inline Comments
	
								if (length($value) > 0) {				
									if ($value =~ /\#/) {
										$value =~ s/\s+#\s.*//;
										$value = trimString($value);
									}

									if ($value =~ /\;/) {
										$value =~ s/\s+;\s.*//;
										$value = trimString($value);
									}

									if ($value =~ /\\/) {
										$value =~ s/\s+\/\/\s.*//;
										$value = trimString($value);
									}
	
									# Remove Quotes
			
									if ($value =~ /\"/) {
										($junk,$value) = parseQuotes($value);
									}
								}
	
								if ($option =~ /^logfile$/i) {
									$logfile = $value;
								}

								if ($option =~ /^loglevel$/i) {
									$loglevel = $value;
								}

								if ($option =~ /^logtofile$/i) {
									$flag_log_to_file = parseBoolean($value);
								}

								if ($option =~ /^logappend$/i) {
									$flag_append_log = parseBoolean($value);
								}

								if ($option =~ /^consoleoutput$/i) {
									$opt_console_output = parseBoolean($value);
								}

							}
						}

						# Section	DATABASE

						if ($section eq "[" . CONFIG_SECTION_DATABASE . "]" ) {
						
							if ($line =~ /\=/) {

								$option = "";
								$value = "";

								($option,$value) = split("=",$line,2);
		
								$retval++;
			
								$option = trimString($option);
								$value = trimString($value);
		
								# Strip Inline Comments
	
								if (length($value) > 0) {				
									if ($value =~ /\#/) {
										$value =~ s/\s+#\s.*//;
										$value = trimString($value);
									}

									if ($value =~ /\;/) {
										$value =~ s/\s+;\s.*//;
										$value = trimString($value);
									}

									if ($value =~ /\\/) {
										$value =~ s/\s+\/\/\s.*//;
										$value = trimString($value);
									}
	
									# Remove Quotes
			
									if ($value =~ /\"/) {
										($junk,$value) = parseQuotes($value);
									}
								}
	
#								if ($option =~ /^logfile$/i) {
#									$logfile = $value;
#								}
							}

						}

					}
				}	
			}
		}
	}
	close(FILE);
	return $retval;
}

#-----------------------------------------------------------
# Get Timestamp
#-----------------------------------------------------------
sub getTimestamp{
	my $retval = formatTime(time);
	return $retval;
}

#-----------------------------------------------------------
# Parse Boolean
#-----------------------------------------------------------
sub parseBoolean{
	my $value = shift;
	my $retval = -1;
	my $test_value;

	return -1 unless defined $value;

	$test_value = lc $value;

	# True

	if ($test_value eq 'true') {
		$retval = 1;
	}

	if ($test_value eq 'yes') {
		$retval = 1;
	}

	if ($test_value eq '1') {
		$retval = 1;
	}

	if ($test_value eq 'y') {
		$retval = 1;
	}

	if ($test_value eq 'on') {
		$retval = 1;
	}

	if ($test_value eq 'enabled') {
		$retval = 1;
	}

	if ($test_value eq 'enable') {
		$retval = 1;
	}

	# False

	if ($test_value eq 'false') {
		$retval = 0;
	}

	if ($test_value eq 'no') {
		$retval = 0;
	}

	if ($test_value eq '0') {
		$retval = 0;
	}

	if ($test_value eq 'n') {
		$retval = 0;
	}

	if ($test_value eq 'off') {
		$retval = 0;
	}

	if ($test_value eq 'disabled') {
		$retval = 0;
	}

	if ($test_value eq 'disable') {
		$retval = 0;
	}

	# Last Check

	if ($retval < 0) {
		$test_value = int $value;

		if ($test_value > 1) {
			$retval = 1;
		}

		if ($test_value < 1) {
			$retval = 0;
		}

		if ($test_value == 0) {
			$retval = 0;
		}
	}

	return $retval;
}

#-----------------------------------------------------------
# Format Time
#-----------------------------------------------------------
sub formatTime{
	my $timestamp = shift;
	my $retval;

	return unless defined $timestamp;

	$retval = strftime( $dateformat, localtime($timestamp) ) . " " . strftime( $timeformat, localtime($timestamp) );

	return $retval;
}

#-----------------------------------------------------------
# Normalize URL
#-----------------------------------------------------------
sub normalizeURL{
	my $url = shift;

	return unless defined $url;

	if ($url =~ /\.\.\// ) {		# remove ../
		$url =~ s/\.\.\///g;
	}

	if ($url =~ /\.\// ) {			# remove ./
		$url =~ s/\.\///g;
	}

	return $url;
}

#-----------------------------------------------------------
# Add String
#-----------------------------------------------------------
sub addString{
	my $string = shift;
	my $addcontent = shift;
	my $separator = shift;
	my $flag_new = 0;

	return $string unless defined $addcontent;
	$flag_new = 1 unless defined $string;
	$separator = DEFAULT_STRING_SEPARATOR unless defined $separator;
	$separator = $separator . " ";

	$string = "" unless defined $string;

	if (length($string) > 0) {
	} else {
		$flag_new = 1;
	}
	
	if ($addcontent =~ /$separator/) {
		$addcontent = quoteString($addcontent);
	}

	if ($flag_new) {
		$string = $addcontent;
	} else {
		$string = $string . $separator . $addcontent;
	}

	return $string;
}

#-----------------------------------------------------------
# Quote String
#-----------------------------------------------------------
sub quoteString{
	my $string = shift;
	my $quotesymbol = shift;

	return $string unless defined $string;
	$quotesymbol = DEFAULT_QUOTE_SYMBOL unless defined $quotesymbol;

	$string = $quotesymbol . $string . $quotesymbol;

	return $string;
}

#-----------------------------------------------------------
# Reformat Data
#-----------------------------------------------------------
sub reformatData{
	my $content = shift;
	my $original_separator = shift;
	my $array_separator = shift;
	my $buffer;
	my @original_array = ();
	my @temp_array = ();

	return NO_DATA unless defined $content;
	return $content unless defined $original_separator;

	if ($content eq NO_DATA) {
		return NO_DATA;
	}

	$array_separator = DEFAULT_ARRAY_SEPARATOR unless defined $array_separator;

	@original_array = split(quotemeta($original_separator),$content);
	
	foreach my $line (@original_array) {
		if ($global_trimwhitespace) { 
			$line = trimWhiteSpace($line); 
		}
		push(@temp_array,$line);	
	}

	$buffer = join("$array_separator",@temp_array) . $array_separator;
	return $buffer;
}

#-----------------------------------------------------------
# Get Values from HTML
#-----------------------------------------------------------
sub getValuesFromHTML{
	my $search_string = shift;
	my $content = shift;
	my $string_separator = shift;
	my $retval;
	my $value = NO_DATA;
	my $buffer;
	my $epos;
	
	$string_separator = DEFAULT_STRING_SEPARATOR unless defined $string_separator;

	if ($search_string eq NO_FIELD) { return NO_DATA; } 

	for (split /^/, $content) {
		$buffer = $_;
		if ($buffer =~ /$search_string/i ) {	
			$epos = index($buffer,"=");
			if ($epos) {
				$value = substr $buffer,$epos+1;
			} else {
				$value = $buffer;
			}
			$value = trimString($value);
		}
	}

	if ($value ne NO_DATA) {
		$retval = $value;
	}

	$retval = NO_DATA unless defined $retval;

	return $retval;

}

#-----------------------------------------------------------
# Get Quoted Values from HTML
#-----------------------------------------------------------
sub getQuotedValuesFromHTML{
	my $search_string = shift;
	my $content = shift;
	my $string_separator = shift;
	my $retval;
	my $buffer;
	my $line;

	if ($search_string eq NO_FIELD) { return NO_DATA; } 

	for (split /^/, $content) {
		$line = $_;
		if ($line =~ /$search_string/i ) {	
			($buffer,$retval) = parseQuotes($line);
			if ($global_trimwhitespace) { 
				$retval = trimWhiteSpace($retval); 
			}
		}
	}

	$retval = NO_DATA unless defined $retval;

	return $retval;

}

#-----------------------------------------------------------
# Get Values from HTML Table
#-----------------------------------------------------------
sub getValuesFromHTMLTable{
	my $search_string = shift;
	my $content = shift;
	my $string_separator = shift;
	my $retval;
	my $flag_active = 0;
	my $tr;
	my $ts;
	my $row;
	my $value;

	$string_separator = DEFAULT_STRING_SEPARATOR unless defined $string_separator;

	if ($search_string eq NO_FIELD) { return NO_DATA; } 

	# TO DO
	#	more error checking/handling

	my $root = HTML::TableExtract->new;
	$root->parse($content);

 	foreach $ts ($root->tables) {
		foreach $tr ($ts->rows) {
			$flag_active = 0;
			foreach $row (@$tr) {
				$row = NO_DATA unless defined $row;
				if ($row =~ /$search_string/i ) {	
					$flag_active = 1;
				} else {
					if ($flag_active) {
						$value = $row;
						$value = NO_DATA unless defined $value;
						if ($value ne NO_DATA) {
							if ($global_trimwhitespace) { 
								$value = trimWhiteSpace($value); 
							}
							$retval = addString($retval,$value,$string_separator);
						}
					}
				}	
			}
		}
	}

	$retval = NO_DATA unless defined $retval;

	return $retval;
}

#-----------------------------------------------------------
# Get Hash
#-----------------------------------------------------------
sub getHash{
	my $data = shift;
	my $hash = "";

	my $md5 = Digest::MD5->new;

	$md5->add(encode_utf8($data));
	$hash = $md5->hexdigest;

	return $hash;
}

#-----------------------------------------------------------
# Get Plural
#-----------------------------------------------------------
sub getPlural{
	my $number = shift;
	my $retval = "";

	$number = 0 unless defined $number;

	if ($number == 0) {
		$retval = "s";
	}

	if ($number > 1) {
		$retval = "s";
	}

	return $retval;
}

#-----------------------------------------------------------
# Raw to File
#-----------------------------------------------------------
sub rawToFile{
	my $content = shift;
	my $pathname = shift;
	my $retval = 0;

	return $retval unless defined $content;
	return $retval unless defined $pathname;

	if (open(FDUMP,">$pathname")) {
		binmode FDUMP;
		print FDUMP $content;
		$retval = 1;
	} else {
		# Failed to Open
	}
	close FDUMP;

	return $retval;
}

#-----------------------------------------------------------
# Remove WhiteSpace From String
#-----------------------------------------------------------
sub trimWhiteSpace{
	my $string = shift;
	return $string unless defined $string;

	$string =~ s/^\s*(.*?)\s*$/$1/;

	return $string;
}

#-----------------------------------------------------------
# Read From File (untested)
#-----------------------------------------------------------
sub readFromFile{
	my $reference = shift;
	my $pathname = shift;
	my $retval = 0;
	my $reftype;
	my $fh;

	return $retval unless defined $reference;
	return $retval unless defined $pathname;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";

	local $/;
	if (open($fh, '<', $pathname)) {
		local $/;
		(@{$reference}) = <$fh>;
		$retval = 1;
	} else {
		$retval = 0;
	}
	close($fh);

	return $retval;
}

#-----------------------------------------------------------
# Dump to File
#-----------------------------------------------------------
sub dumpToFile{
	my $reference = shift;
	my $pathname = shift;
	my $retval = 0;
	my $reftype;

	return $retval unless defined $reference;
	return $retval unless defined $pathname;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";

	if (open(FDUMP,">$pathname")) {
		foreach my $line (@{$reference}) {
			$retval++;
			print FDUMP "$line\n";
		}
	} else {
		# Failed to Open
	}
	close FDUMP;

	return $retval;
}

#--------------------------------------------------
# Check File Encoding
#--------------------------------------------------
sub getFileEncoding{
	my $path = shift;

	my $buffer = "";
	my $fileid = 0;
	my $bytes = 0;

	my $file_encoding = ENCODING_CRLF;

	$path = "" unless defined $path;

	if (open(FILE,"<",$path)) {
		binmode(FILE);
		$bytes = read FILE, $buffer, 2;

	} else {
		return $file_encoding;
	}
	close(FILE);

	if ($bytes == 2) {
		$fileid = unpack("S",$buffer);
	}

	if ($fileid == 0xFFFE ) {
		$file_encoding = ENCODING_UTF16;
	}

	if ($fileid == 0xFEFF ) {
		$file_encoding = ENCODING_UTF16;
	}

	return $file_encoding;
}

#-----------------------------------------------------------
# Is In List
#-----------------------------------------------------------
sub isInList{
	my $reference = shift;
	my $searchfor = shift;
	my $matchcase = shift;
	my $reftype;
	my $retval = 0;
	my $flag_matchcase = 0;
	my $searchitem = "";

	return $retval unless defined $reference;
	return $retval unless defined $searchfor;

	$matchcase = 0 unless defined $matchcase;

	$reftype = ref($reference);
	if (!$reftype) {
		$reftype = "DIRECT";
	}

	return $retval unless $reftype eq "ARRAY";

	if (parseBoolean($matchcase)) { 
		$flag_matchcase = 1;
	}

	if (!$flag_matchcase) {
		$searchfor = lc $searchfor;
	}

	foreach my $line (@{$reference}) {
		if (!$flag_matchcase) {
			$searchitem = lc $line;
		} else {
			$searchitem = $line;
		}

		if ($searchitem eq $searchfor) {
			$retval = 1;
			last;
		}
	}

	return $retval;

}

#-----------------------------------------------------------
# Force Numeric (basically to shut up warnings)
#-----------------------------------------------------------
sub forceNumeric{
	my $value = shift;
	return 0 unless defined $value;

	no warnings "numeric";
	$value = int $value;
	use warnings "all";

	return $value;
}

