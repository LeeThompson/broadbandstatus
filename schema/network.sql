-- phpMyAdmin SQL Dump
-- version 4.6.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 30, 2017 at 11:35 AM
-- Server version: 5.5.50-MariaDB
-- PHP Version: 5.5.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `network`
--

-- --------------------------------------------------------

--
-- Table structure for table `carrier`
--

CREATE TABLE `carrier` (
  `carrier_id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `url` varchar(256) NOT NULL,
  `account_url` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `circuit`
--

CREATE TABLE `circuit` (
  `circuit_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modem_id` int(11) NOT NULL,
  `technology_id` int(11) NOT NULL,
  `circuit_name` varchar(256) NOT NULL,
  `carrier_id` int(11) NOT NULL,
  `lan_ipv4` varchar(64) NOT NULL,
  `lan_ipv6` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `modem`
--

CREATE TABLE `modem` (
  `modem_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `manufacturer` varchar(256) NOT NULL,
  `model` varchar(256) NOT NULL,
  `serial_number` varchar(256) NOT NULL,
  `hardware_version` varchar(64) NOT NULL,
  `firmware_version` varchar(64) NOT NULL,
  `is_oem` tinyint(4) NOT NULL DEFAULT '0',
  `operating_mode` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

CREATE TABLE `status` (
  `status_id` bigint(20) NOT NULL,
  `status_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `wan_id` int(11) NOT NULL,
  `circuit_id` int(11) NOT NULL,
  `modem_id` int(11) NOT NULL,
  `downstream_frequency` varchar(256) NOT NULL,
  `downstream_modulation` varchar(256) NOT NULL,
  `downstream_power` varchar(256) NOT NULL,
  `downstream_lock` varchar(256) NOT NULL,
  `downstream_rate` varchar(256) NOT NULL,
  `downstream_snr` varchar(256) NOT NULL,
  `downstream_channel` varchar(256) NOT NULL,
  `upstream_frequency` varchar(256) NOT NULL,
  `upstream_modulation` varchar(256) NOT NULL,
  `upstream_power` varchar(256) NOT NULL,
  `upstream_lock` varchar(256) NOT NULL,
  `upstream_rate` varchar(256) NOT NULL,
  `upstream_snr` varchar(256) NOT NULL,
  `upstream_channel` varchar(256) NOT NULL,
  `connection_status` int(11) NOT NULL,
  `tod_status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `technology`
--

CREATE TABLE `technology` (
  `technology_id` int(11) NOT NULL,
  `display_name` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `version` varchar(64) NOT NULL,
  `type` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `wan`
--

CREATE TABLE `wan` (
  `wan_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `circuit_id` int(11) NOT NULL,
  `external_ipv4` varchar(64) NOT NULL,
  `gateway_ipv4` varchar(64) NOT NULL,
  `dns1_ipv4` varchar(64) NOT NULL,
  `dns2_ipv4` varchar(64) NOT NULL,
  `using_dhcp` tinyint(1) NOT NULL DEFAULT '0',
  `domain_name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carrier`
--
ALTER TABLE `carrier`
  ADD UNIQUE KEY `carrier_id` (`carrier_id`);

--
-- Indexes for table `circuit`
--
ALTER TABLE `circuit`
  ADD UNIQUE KEY `circuit_id` (`circuit_id`);

--
-- Indexes for table `modem`
--
ALTER TABLE `modem`
  ADD UNIQUE KEY `modem_id` (`modem_id`);

--
-- Indexes for table `status`
--
ALTER TABLE `status`
  ADD UNIQUE KEY `status_id` (`status_id`);

--
-- Indexes for table `technology`
--
ALTER TABLE `technology`
  ADD UNIQUE KEY `technology_id` (`technology_id`);

--
-- Indexes for table `wan`
--
ALTER TABLE `wan`
  ADD UNIQUE KEY `wan_id` (`wan_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `carrier`
--
ALTER TABLE `carrier`
  MODIFY `carrier_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `circuit`
--
ALTER TABLE `circuit`
  MODIFY `circuit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `modem`
--
ALTER TABLE `modem`
  MODIFY `modem_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `status`
--
ALTER TABLE `status`
  MODIFY `status_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `technology`
--
ALTER TABLE `technology`
  MODIFY `technology_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `wan`
--
ALTER TABLE `wan`
  MODIFY `wan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
