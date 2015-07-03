# broadbandstatus
Broadband Device Status and Reporting Tool

NOTE: This is in pre-alpha state at this time.    Very little is implemented at this time.   If you've found this and make it work for you, that's fantastic but also completely unexpected.


Features:
* Collect Data/Statstics from Various Broadband Devices
* Normalize/Format Device Data
* Test WAN Connections
* Log Data to CSV, Console and/or SQL
* Web Based Report Tool (SQL backend only)


Requirements:
* Data Gathering: Perl 5 (and appropriate modules) (optional: MariaDB/MySQL or compatible)
* Data Reporting: Web Server, PHP 5, MariaDB/MySQL or compatible database


Perl Modules:
* Digest:MD5
* Encode
* Getopt::Long
* HTML::TableExtract
* POSIX
* Switch
* Time::Local
* WWW::Mechanize

NOTE: Some of these Perl modules are included in some distributions of Perl.


NOTE: As this is in pre-alpha state, everything above is subject to change.



