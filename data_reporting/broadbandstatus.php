<?php
#
#	Broadband Status
#	WEB INTERFACE
#
#	Lee Thompson <thompsonl@logh.net>
#
#=============================================================================
#
# 	This is a prototype/proof of concept.
#	Schema etc is not final.
#
#	TO DO
#		sql based config options
#		circuit/wan/modem/carrier information
#		other data?
#		other modem data?
#		average/trending information under controls?
#
# 	CHANGELOG
#		20170430
#			changes to HTML headers
#		20161130
#			if upstream power is below 1? it should probably be red
#
#=============================================================================

$script_name = "broadbandstatus";
$script_description = "This is very, very alpha.";
$version = "201704301126";

#------------------------------------
#	Config
#------------------------------------

$debug = 0;				# Debug Option

$allow_sql_config = 0;			# Allow SQL Config to be Used
$max_range = 4320;			# Max Range, 3 Days
$range = 60;				# Data Range (Minutes)

$time_format = "Y-m-d H:i:s";		# Time Format
$date_format = "l, F d, Y h:i A T (O)";	# Long Date

$css_file = "broadbandstatus.css";	# CSS URL or Filename
$info_icon = "/info32.png";		# Icon

$string_not_available = "N/A";		

$refresh_time = 60;			# Refresh Page every X Seconds (-1 disable)


#	Units of Measure

$measure_unit_frequency_hz = "Hz";
$measure_unit_frequency_mhz = "MHz";
$measure_unit_snr = "dB";
$measure_unit_modulation = "QAM";
$measure_unit_power = "dBmV";
$measure_unit_rate_m = "Msym/sec";
$measure_unit_rate_k = "Ksym/sec";

# CSS Classes

$css_class_outofspec = "outofspec";
$css_class_maximum = "marginal";
$css_class_acceptable = "acceptable";
$css_class_recommended = "recommended";
$css_class_connect_ok = "connectok";
$css_class_connect_progress = "connectprogress";
$css_class_connect_error = "connecterror";

# Options

$opt_show_controls = 1;			# Show Controls
$opt_show_footer = 1;			# Show Footer
$opt_show_summary = 1;			# Show Summary

#--------------------------------------------
#	CGI Selectors
#--------------------------------------------

$selector_range = "range";

#--------------------------------------------
#	Database Configuration
#--------------------------------------------

$db_host = "ultra.sgc.logh.net";
$db_user = "root";
$db_password = "hammond";
$db_database = "network";

$db_carrier_table = "carrier";
$db_status_table = "status";
$db_wan_table = "wan";
$db_technology_table = "technology";
$db_circuit_table = "circuit";
$db_modem_table = "modem";


#------------------------------------
#	Start
#------------------------------------

$debug_string = "DEBUG<p>\n";
$flag_db_error = 0;
$flag_no_data = 0;
$flag_wan_data_available = 0;
$flag_modem_data_available = 0;
$flag_carrier_data_available = 0;
$flag_circuit_data_available = 0;

$debug_status_query = "N/A";
$debug_modem_query = "N/A";
$debug_circuit_query = "N/A";
$debug_carrier_query = "N/A";
$debug_wan_query = "N/A";
$debug_technology_query = "N/A";

$now = time();
$current_time = date($date_format,$now);

$dbhandle = @new mysqli($db_host, $db_user, $db_password, $db_database);
if ($dbhandle->connect_error) {
	$flag_db_error = 1;
	$db_error = $dbhandle->connect_error;
}

if ((!$flag_db_error) && ($allow_sql_config))
{

	#	NOT YET IMPLEMENTED

	#
	#	Configuration Table
	#	These override defaults in this program
	#	CGI parameters will override these
}

#	Boolean Checks

#	Get CGI/FCGI Values

$script_url = $_SERVER['PHP_SELF'];
parse_str($_SERVER['QUERY_STRING'], $query_string);
$get_range = $_GET[$selector_range];

if (is_null($get_range))
{
} else {
	$range = (int)$get_range;
}

if ($range < 1)
{
	$range = 5;
}

if ($range > $max_range)
{	
	$range = $max_range;
}


#	Set Time Ranges

$starttime = date($time_format,$now - ($range * 60));
$endtime = date($time_format,$now);

#	Set Debug Strings

$debug_string = $debug_string . "<p>Options: <br />\n";
$debug_string = $debug_string . "range: $range ($max_range)<br />\n";
$debug_string = $debug_string . "allow_sql_config: $allow_sql_config<br />\n";

#	Temporary Hack
#	Ideally it would pull this, from each circuit

$circuit_modulation = "QAM";		

	#	Get WAN/Circuit/Modem Data

if (!$flag_db_error)
{
	# 	Data will go into an array 

	#	Important data for other operations
	#		upstream/downstream modulation per circuit
	#		technology type of each circuit's device
	#	
	#	I'm not sure how detailed a php struct can get
	#	but ideally it should be indexed by the circuit id
	#	for the purposes of the report.
	
}

if (!$flag_db_error)
{
	#	Get Data

	$numRows = 0;
	$query = "";
	$sql_select = "*";
	$sql_from = "$db_status_table";
	$sql_where = "status_time BETWEEN '$starttime' AND '$endtime'";
	$sql_group = "status_time DESC";

	$query = $query . "SELECT $sql_select";
	$query = $query . " FROM `$sql_from`";
	$query = $query . " WHERE $sql_where";
	$query = $query . " GROUP BY $sql_group";
	$query = "$query;";	
	$result = $dbhandle->query($query);
	$debug_status_query = $query;
	$numRows = $result->num_rows;
}

?>
<!DOCTYPE html>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml" manifest="/manifest.appcache">
<head>
	<title>Broadband Status</title>
	<link rel="shortcut icon" href="/broadbandstatus.ico" type="image/x-icon" />
	<link rel="stylesheet" type="text/css" href="<?php echo $css_file; ?>" /> 
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<?php
	if ($refresh_time != -1)
	{
		echo "	<meta http-equiv=\"refresh\" content=\"$refresh_time\" />\r\n";
	}
?>
</head>
<body>
<h1>Broadband Status</h1>
<h6><?php echo $current_time; ?></h6>
<p>
<?php

if ($debug)
{
	echo "<div class=debug>\n";
	echo $debug_string;
	echo "</div>\n";
}

if ($debug_comment_queries)
{
	echo "<!-- SQL Queries: -->\n";
#	echo "<!--       config: $debug_config_query -->\n";
	echo "<!--    condition: $debug_status_query -->\n";
}

#	Show WAN/CIRCUIT table here?

#	Show Table

if ($numRows) 
{
	echo "<table>\n";
	echo "<tr><td class=headings>Time";
#	echo "<td class=headings>Circuit";
#	echo "<td class=headings>Frequency";
#	echo "<td class=headings>Modulation";
#	echo "<td class=headings>Rate";
	echo "<td class=headings>Downstream Power";
	echo "<td class=headings>Upstream Power";
	echo "<td class=headings>SNR";
	echo "<td class=headings>Status";
	echo "</tr>\n";

	$result->data_seek(0);
	while($row = $result->fetch_assoc()) 
	{
		$misc_string = "";
		$eventtime = $row["status_time"];
		$wan_id = $row["wan_id"];
		$circuit_id = $row["circuit_id"];
		$modem_id = $row["modem_id"];
		$downstream_frequency = $row["downstream_frequency"];
		$downstream_modulation = $row["downstream_modulation"];
		$downstream_power = $row["downstream_power"];
		$downstream_lock = $row["downstream_lock"];
		$downstream_rate = $row["downstream_rate"];
		$downstream_snr = $row["downstream_snr"];
		$downstream_channel = $row["downstream_channel"];
		$upstream_frequency = $row["upstream_frequency"];
		$upstream_modulation = $row["upstream_modulation"];
		$upstream_power = $row["upstream_power"];
		$upstream_lock = $row["upstream_lock"];
		$upstream_rate = $row["upstream_rate"];
		$upstream_snr = $row["upstream_snr"];
		$upstream_channel = $row["upstream_channel"];
		$connection_status = $row["connection_status"];
		$tod_status = $row["tod_status"];

		$report_connection_status = reportComcastConnectionStatus($connection_status);
		$report_snr = reportComcastSNR($downstream_snr,$downstream_modulation,$circuit_modulation);
		$report_downstream_power = reportComcastRXPower($downstream_power,$downstream_channel);
		$report_upstream_power = reportComcastTXPower($upstream_power,$upstream_channel);


		# need to split up downstream and upstream data by channel

		echo "<tr>";
		echo "<td class=eventtime>";
			echo "$eventtime";
#		echo "<td class=circuit>";
#			echo "$circuit_id";
		echo "<td class=power>";
			echo "$report_downstream_power $measure_unit_power";
		echo "<td class=power>";
			echo "$report_upstream_power $measure_unit_power";
		echo "<td class=snr>";
			echo "$report_snr";
		echo "<td class=status>";
			echo "$report_connection_status";
		echo "</tr>\n";
	}
	echo "</table><br />\n";

} else {
	if ($flag_db_error)
	{
		echo "<B>Database Error:</B> $db_error<br />\n";
	} else {
		$flag_no_data = 1;
		echo "No Data.<br />\n";
		echo "There are no records for the range/circuits selected.<br />\n";
	}
}
		
?>

<?php

$dbhandle->close();

echo "<p>\n";

if ($opt_show_controls)
{
	#	Show Controls (if enabled)

	echo "<div class=controls>\n";

	echo "<div class=legend>controls</div>\n";

	#	Reset

	echo "<a href=\"";
	echo buildQSReference($script_url,"");
	echo "\">";
	echo "Set Defaults";
	echo "</a>\n";

	# 	Range

	if (!is_null($get_range))
	{
		echo "$item_separator";
		$opt_remove_range = "";
		$opt_remove_range = removeFromURL(removeFromQS($selector_range),$selector_range);

		echo "\n<a href=\"";
		echo buildQSReference($script_url,$opt_remove_range);
		echo "\">";
		echo "Remove Range Override";
		echo "</a>\n";
	}

	# 	Circuit
	#	NOT YET IMPLEMENTED

	echo "<br >\n";

	#	Ranges

	echo "<div class=legend>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;change data range</div>\n";

	$opt_add_range = "";

	if ($range != 15)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,15);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "15 Minutes";
		echo "</a>&nbsp;\n";
	}

	if ($range != 30)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,30);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "30 Minutes";
		echo "</a>&nbsp;\n";
	}


	if ($range != 45)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,45);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "45 Minutes";
		echo "</a>&nbsp;\n";
	}

	if ($range != 60)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,60);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "60 Minutes";
		echo "</a>&nbsp;";
	}

	if ($range != 90)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,90);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "90 Minutes";
		echo "</a>&nbsp;\n";
	}

	if ($range != 120)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,120);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "120 Minutes";
		echo "</a>&nbsp;\n";
	}

	if ($range != 180)
	{
		echo "&nbsp;<a href=\"";
		$opt_add_range = addToQS($selector_range,180);
		echo buildQSReference($script_url,$opt_add_range);
		echo "\">";
		echo "180 Minutes";
		echo "</a>&nbsp;\n";
	}


	echo "</div>\n";
}

if ($opt_show_summary)
{
	#	Show Summary

	echo "<p>\n";
	echo "<table class=general>";
	echo "<tr class=general>";
	echo "<td class=periodlabel>";
	echo "<B>Status Period:</B>";
	echo "<td class=periodtext>$starttime - $endtime<br /><small>$range minutes</small>";
	echo "</tr>\n";

	echo "</table>";

}

if ($opt_show_footer)
{
	echo "<p>\n";
	echo "<div class=footer>";
	echo "$script_name v$version";
	echo "<br /><strong>$script_description</strong>";
	echo "</div>\n";
}
?>
<br />
</body>
</html>
<?php

#------------------------------------
#	Functions
#------------------------------------
#------------------------------------
#	Comcast Specific
#------------------------------------
function reportComcastConnectionStatus($cc_status)
{
	$css_class = $GLOBALS['css_class_connect_progress'];
	$retval = "UNKNOWN";

	if ($cc_status <= 2) {
		$retval = "Initializing Hardware";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 3) {
		$retval = "Acquiring Downstream Channel";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if (($cc_status == 4) || ($cc_status == 5))  {
		$retval = "Upstream Ranging";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 6) {
		$retval = "DHCP Binding";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 7) {
		$retval = "Setting Time Of Day";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 8) {
		$retval = "Downloading CM Configuration File";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 9) {
		$retval = "Downloading CM Configuration File";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 10) {
		$retval = "Registering Device";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 11) {
		$retval = "Registered Device";
		$css_class = $GLOBALS['css_class_connect_progress'];
	}

	if ($cc_status == 12) {
		$retval = "OK";
		$css_class = $GLOBALS['css_class_connect_ok'];
	}

	if ($cc_status == 13) {
		$retval = "REFUSED BY CMTS";
		$css_class = $GLOBALS['css_class_connect_error'];
		
	}

	if ($css_class != NULL) {
		$retval = "<div class=$css_class>$retval</div>";
	}

	return $retval;
}

#------------------------------------
function evaluateComcastRXPower($rx_power)
{
	$retval = $GLOBALS['css_class_outofspec'];
		
	if ((compareFloat($rx_power,-15.000000,">")) || (compareFloat($rx_power,15.000000,">"))) {
		$retval = $GLOBALS['css_class_outofspec'];
	}
	
	if ((compareFloat($rx_power,-10.000001,">=") && compareFloat($rx_power,-15.000000,"<")) || (compareFloat($rx_power,10.000001,">=") && compareFloat($rx_power,15.000000,"<"))) {
		$retval = $GLOBALS['css_class_maximum'];
	}

	if ((compareFloat($rx_power,-10.000000,">=") && compareFloat($rx_power,-7.000001,"<=")) || (compareFloat($rx_power,10.000000,"<=") && compareFloat($rx_power,7.000001,">="))) {
		$retval = $GLOBALS['css_class_acceptable'];
	}

	if ((compareFloat($rx_power,-7.000000,">=") && compareFloat($rx_power,7.000000,"<=")))  {
		$retval = $GLOBALS['css_class_recommended'];
	}

	return $retval;
}

#------------------------------------
function evaluateComcastTXPower($tx_power)
{
	$retval = $GLOBALS['css_class_recommended'];

	if (compareFloat($tx_power,35.0000,"<")) {
		$retval = $GLOBALS['css_class_recommended'];
	}

	if ((compareFloat($tx_power,35.0000,">=")) && (compareFloat($tx_power,49.0000,"<="))) {
		$retval = $GLOBALS['css_class_recommended'];
	}

	if (compareFloat($tx_power,49.0000,">")) {
		$retval = $GLOBALS['css_class_acceptable'];
	}

	if (compareFloat($tx_power,51.0000,">=")) {
		$retval = $GLOBALS['css_class_maximum'];
	}

	if (compareFloat($tx_power,52.0000,">")) {
		$retval = $GLOBALS['css_class_outofspec'];
	}

	if (compareFloat($tx_power,1.0000,"<")) {
		$retval = $GLOBALS['css_class_outofspec'];
	}

	return $retval;
}

#------------------------------------
function reportComcastSNR($downstream_snr,$downstream_modulation,$modulation)
{
	$retval = "N/A";

	$temp_snr = explode("|", $downstream_snr);
	if (count($temp_snr) > 1) {
		array_pop($temp_snr);
		$downstream_snr = array_sum($temp_snr) / count($temp_snr); 
	} else {
		$downstream_snr = array_sum($temp_snr);
	}

	if ($modulation == "QAM") {
		if ($downstream_modulation == 256) {
			if (compareFloat($downstream_snr,30.000000,"<")) {
				$retval = "BAD";
			} 

			if (compareFloat($downstream_snr,30.000000,">=")) {
				$retval = "OK";
			} 

			if (compareFloat($downstream_snr,33.000000,">=")) {
				$retval = "EXCELLENT";
			} 
		}

		if ($downstream_modulation == 64) {
			if (compareFloat($downstream_snr,24.000000,"<")) {
				$retval = "BAD";
			} 

			if (compareFloat($downstream_snr,24.000000,">=")) {
				$retval = "OK";
			} 

			if (compareFloat($downstream_snr,27.000000,">=")) {
				$retval = "EXCELLENT";
			} 

		}

		if ($downstream_modulation == 16.000000) {
			if (compareFloat($downstream_snr,18.000000,"<")) {
				$retval = "BAD";
			} 

			if (compareFloat($downstream_snr,18.000000,">=")) {
				$retval = "OK";
			} 

			if (compareFloat($downstream_snr,21.000000,">=")) {
				$retval = "EXCELLENT";
			} 
		}
	}

	if ($modulation == "QPSK") {
		if (compareFloat($downstream_snr,12.000000,"<")) {
			$retval = "BAD";
		} 

		if (compareFloat($downstream_snr,12.000000,">=")) {
			$retval = "OK";
		} 

		if (compareFloat($downstream_snr,15.000000,">=")) {
			$retval = "EXCELLENT";
		}
	}
		
	$css_class = "";

	if ($retval == "BAD") {
		$css_class = $GLOBALS['css_class_outofspec'];
	}

	if ($retval = "OK") {
		$css_class = $GLOBALS['css_class_maximum'];
	}

	if ($retval = "EXCELLENT") {
		$css_class = $GLOBALS['css_class_recommended'];
	}

	if ($css_class != NULL) {
		$retval = "<div class=$css_class>$retval</div>";
	}

	return $retval;

}

#------------------------------------
function reportComcastRXPower($downstream_power,$downstream_channel)
{
	$retval = "";

	$values_rx_power = explode("|", $downstream_power);
    	foreach($values_rx_power as $key => $val) {
	     if ($val != NULL ) {
		$css_class = evaluateComcastRXPower($val);
		if ($css_class != NULL) {
			$val = "<div class=$css_class>$val</div>";
		}

	     	if ($retval != NULL) {
			$retval = $retval . ", ";
	     	}
             	$retval = $retval . $val;
	     }
        }
	return $retval;
}

#------------------------------------
function reportComcastTXPower($upstream_power,$upstream_channel)
{
	$retval = "";

	$temp_tx_power = explode("|", $upstream_power);
	$tx_channels = explode("|", $upstream_channel);

	asort($tx_channels);
	foreach($tx_channels as $key => $val) {
		$values_tx_power[$key] = $temp_tx_power[$key];
	}

    	foreach($values_tx_power as $key => $val) {
	     if ($val != NULL ) {
		$css_class = evaluateComcastTXPower($val);
		if ($css_class != NULL) {
			$val = "<div class=$css_class>$val</div>";
		}

	     	if ($retval != NULL) {
			$retval = $retval . ", ";
	     	}
             	$retval = $retval . $val;
	     }
        }
	return $retval;
}

#------------------------------------
#	General Functions
#------------------------------------
function convertBooleanToNumeric($value,$default)
{
	$retval = $default;

	$temp_bool = parseBoolean($value);
	
	if ($temp_bool == 1)
	{
		$retval = 1;
	}

	if ($temp_bool == -1)
	{
		$retval = 0;
	}

	return $retval;
}

#------------------------------------
function parseBoolean($value)
{
	$retval = 0;

	if (!is_null($value))
	{
		$value = strtolower($value);
		
		switch ($value) {
			case "false":
				$retval = -1;
				break;
			case "off":
				$retval = -1;
				break;
			case "no":
				$retval = -1;
				break;
			case "n":
				$retval = -1;
				break;
			case "f":
				$retval = -1;
				break;
			case "-1":
				$retval = -1;
				break;
			case "disabled":
				$retval = -1;
				break;

			case "true":
				$retval = 1;
				break;
			case "on":
				$retval = 1;
				break;
			case "yes":
				$retval = 1;
				break;
			case "y":
				$retval = 1;
				break;
			case "t":
				$retval = 1;
				break;
			case "1":
				$retval = 1;
				break;
			case "enabled":
				$retval = 1;
				break;
		}
	}

	return $retval;
}

#------------------------------------
function isValid($value,$test = NULL)
{
	$retval = 0;
	if (is_null($test)) { $test = "notnull"; } else { $test = strtolower($test); }

	switch ($test) {
		case "notnull":
			if (!is_null($value)) { $retval = 1; } else { $retval = 0; }
			break;
		case "numeric":
			if (is_numeric($value)) { $retval = 1; } else { $retval = 0; }
			break;
		case "positive":
			$value = (int)$value;
			if ($value > 0) { $retval = 1; } else { $retval = 0; }
			break;
		case "nonzero":
			$value = (int)$value;
			if ($value != 0) { $retval = 1; } else { $retval = 0; }
			break;
		case "boolean":
			$temp = parseBoolean($value);
			if ($temp == 0)
			{
				$retval = 0;
			} else {
				$retval = 1;
			}
			break;
	}


	return $retval;
}

#------------------------------------
function buildQSReference($base,$qs)
{
	$url = "";
	if (strlen($qs) > 0)
	{
		if (substr($qs,0,1) == "?")
		{
			$url = $base . $qs;
		} else {
			$url = $base . "?" . $qs;
		}
	} else {
		$url = $base;
	}

	return $url;
}

#------------------------------------
function isInRange($range,$value)
{
	$retval = 0;
	$low = $range[0] . ".0";
	$high = $range[1] . ".9";
	if (($value >= $low) && ($value <= $high))
	{
		$retval = 1;
	}

	return $retval;
}

#------------------------------------
function removeFromURL($string,$remove)
{
	$temp_string = $string;
	$match = strstr($string,$remove);
	if ($match) 
	{
		$next_parameter = strpos($match,"&");
		if ($next_parameter === false) 
		{
		} else {
			$match = substr($match,0,$next_parameter);
		}
		$temp_string = removeFromString($string,$match);
	}

	$ts_len = strlen($temp_string);

	if ($ts_len > 1)
	{	
		if (substr($temp_string,0,2) == "?&")
		{
			$temp_string = "?" . substr($temp_string,2);
		}

		$ts_len = strlen($temp_string);

		if ($ts_len > 1)
		{
			if ((substr($temp_string,$ts_len-1,1) == "?") || (substr($temp_string,$ts_len-1,1) == "&"))
			{
				$temp_string = substr($temp_string,0,$ts_len-1);
			}
		}
	} else {
		if (($temp_string == "?") || ($temp_string == "&"))
		{
			$temp_string = "";
		}
	}

	return $temp_string;
}

#------------------------------------
function removeFromString($string,$remove)
{
	$retval = str_replace($remove, "", $string);
	return $retval;
}

#------------------------------------
function addToQS($element,$value)
{
	parse_str($_SERVER['QUERY_STRING'], $query_string);
	$add_to = array($element=>$value);
	$query_string = array_merge($query_string, $add_to);
	return http_build_query($query_string);
}


#------------------------------------
function removeFromQS($element)
{
	parse_str($_SERVER['QUERY_STRING'], $query_string);
	unset($query_string[$element]);
	return http_build_query($query_string);
}

#------------------------------------
function processQS($string)
{
	$retval = $string;
	$qs_len = strlen($string);

	if ($qs_len > 0)
	{
		if (substr($string,0,1) == "?")
		{
			$retval = $string;
		} else {
			$retval = "?$string";
		}

		if ($qs_len > 2)
		{
			if ((substr($string,0,2) == "??") || (substr($string,0,2) == "?&"))
			{
				$retval = "?" . substr($string,2);
			}
		}
	}

	return $retval;
}

#------------------------------------
function getMultiplier($val) 
{
	$retval = 1;

	$dec_pos = strpos($val,".");	

	if ($dec_pos > 0) 
	{
		$dec_len = strlen(substr($val,$dec_pos + 1));
		if ($dec_len > 0) 
		{
			$retval = 1 . str_repeat("0",$dec_len);
		}
	}

	return $retval;
	
}

#------------------------------------
function compareFloat($x,$y,$operation)
{
	$retval = -1;

	$t_x = $x * getMultiplier($x);
	$t_y = $y * getMultiplier($x);

 	$operation = strtoupper($operation);

	if ($operation == "=") {
		$op_flag = 0;
	}

	if ($operation == "E") {
		$op_flag = 0;
	}

	if ($operation == "EQ") {
		$op_flag = 0;
	}

	if ($operation == "EQU") {
		$op_flag = 0;
	}

	if ($operation == ">") {
		$op_flag = 1;
	}

	if ($operation == "G") {
		$op_flag = 1;
	}

	if ($operation == "GTR") {
		$op_flag = 1;
	}


	if ($operation == "<") {
		$op_flag = 2;
	}

	if ($operation == "L") {
		$op_flag = 2;
	}

	if ($operation == "LSS") {
		$op_flag = 2;
	}

	if ($operation == "=>") {
		$op_flag = 3;
	}

	if ($operation == ">=") {
		$op_flag = 3;
	}

	if ($operation == "GOE") {
		$op_flag = 3;
	}

	if ($operation == "GE") {
		$op_flag = 3;
	}

	if ($operation == "=<") {
		$op_flag = 4;
	}

	if ($operation == "<=") {
		$op_flag = 4;
	}

	if ($operation == "LOE") {
		$op_flag = 4;
	}

	if ($operation == "LE") {
		$op_flag = 4;
	}

	if ($op_flag == 0) {
		if ($t_x == $t_y) {
			$retval = 1;
		} else {
			$retval = 0;
		}
	}

	if ($op_flag == 1) {
		if ($t_x > $t_y) {
			$retval = 1;
		} else {
			$retval = 0;
		}
	}

	if ($op_flag == 2) {
		if ($t_x < $t_y) {
			$retval = 1;
		} else {
			$retval = 0;
		}
	}

	if ($op_flag == 3) {
		if ($t_x >= $t_y) {
			$retval = 1;
		} else {
			$retval = 0;
		}
	}

	if ($op_flag == 4) {
		if ($t_x <= $t_y) {
			$retval = 1;
		} else {
			$retval = 0;
		}
	}


	return $retval;
}

?>
