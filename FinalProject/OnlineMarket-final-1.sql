-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 17, 2018 at 04:30 PM
-- Server version: 10.1.36-MariaDB
-- PHP Version: 5.6.38

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `OnlineMarket-final`
--

-- --------------------------------------------------------

--
-- Table structure for table `ADDRESSES`
--

CREATE TABLE `ADDRESSES` (
  `id` int(11) NOT NULL,
  `address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `CUSTOMER`
--

CREATE TABLE `CUSTOMER` (
  `id` int(11) NOT NULL,
  `pass` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `sex` enum('male','female') DEFAULT NULL,
  `credit` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `DELEVERY_AGENT`
--

CREATE TABLE `DELEVERY_AGENT` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `phonenumber` varchar(255) DEFAULT NULL,
  `delevery_status` enum('free','busy') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ITEM`
--

CREATE TABLE `ITEM` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `marketId` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `discount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `MARKET`
--

CREATE TABLE `MARKET` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phonenumber` varchar(255) DEFAULT NULL,
  `manager` varchar(255) DEFAULT NULL,
  `supportId` int(11) DEFAULT NULL,
  `deliveryId` int(11) DEFAULT NULL,
  `operationsId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `OPERATIONS_OFFICER`
--

CREATE TABLE `OPERATIONS_OFFICER` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ORDERT`
--

CREATE TABLE `ORDERT` (
  `id` int(11) NOT NULL,
  `marketId` int(11) DEFAULT NULL,
  `customerId` int(11) DEFAULT NULL,
  `orderStatus` enum('send','complete','reject') DEFAULT NULL,
  `paymentType` enum('credit','bank-card') DEFAULT NULL,
  `date` date DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `PHONE_NUMBERS`
--

CREATE TABLE `PHONE_NUMBERS` (
  `id` int(11) NOT NULL,
  `phonenumber` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `SUPPORT_AGENT`
--

CREATE TABLE `SUPPORT_AGENT` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `phonenumber` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ADDRESSES`
--
ALTER TABLE `ADDRESSES`
  ADD PRIMARY KEY (`id`,`address`);

--
-- Indexes for table `CUSTOMER`
--
ALTER TABLE `CUSTOMER`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `DELEVERY_AGENT`
--
ALTER TABLE `DELEVERY_AGENT`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ITEM`
--
ALTER TABLE `ITEM`
  ADD PRIMARY KEY (`id`),
  ADD KEY `marketId` (`marketId`);

--
-- Indexes for table `MARKET`
--
ALTER TABLE `MARKET`
  ADD PRIMARY KEY (`id`),
  ADD KEY `supportId` (`supportId`),
  ADD KEY `deliveryId` (`deliveryId`),
  ADD KEY `operationsId` (`operationsId`);

--
-- Indexes for table `OPERATIONS_OFFICER`
--
ALTER TABLE `OPERATIONS_OFFICER`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ORDERT`
--
ALTER TABLE `ORDERT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `marketId` (`marketId`),
  ADD KEY `customerId` (`customerId`);

--
-- Indexes for table `PHONE_NUMBERS`
--
ALTER TABLE `PHONE_NUMBERS`
  ADD PRIMARY KEY (`id`,`phonenumber`);

--
-- Indexes for table `SUPPORT_AGENT`
--
ALTER TABLE `SUPPORT_AGENT`
  ADD PRIMARY KEY (`id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ADDRESSES`
--
ALTER TABLE `ADDRESSES`
  ADD CONSTRAINT `ADDRESSES_ibfk_1` FOREIGN KEY (`id`) REFERENCES `CUSTOMER` (`id`);

--
-- Constraints for table `ITEM`
--
ALTER TABLE `ITEM`
  ADD CONSTRAINT `ITEM_ibfk_1` FOREIGN KEY (`marketId`) REFERENCES `MARKET` (`id`);

--
-- Constraints for table `MARKET`
--
ALTER TABLE `MARKET`
  ADD CONSTRAINT `MARKET_ibfk_1` FOREIGN KEY (`supportId`) REFERENCES `SUPPORT_AGENT` (`id`),
  ADD CONSTRAINT `MARKET_ibfk_2` FOREIGN KEY (`deliveryId`) REFERENCES `DELEVERY_AGENT` (`id`),
  ADD CONSTRAINT `MARKET_ibfk_3` FOREIGN KEY (`operationsId`) REFERENCES `OPERATIONS_OFFICER` (`id`);

--
-- Constraints for table `ORDERT`
--
ALTER TABLE `ORDERT`
  ADD CONSTRAINT `ORDERT_ibfk_1` FOREIGN KEY (`marketId`) REFERENCES `MARKET` (`id`),
  ADD CONSTRAINT `ORDERT_ibfk_2` FOREIGN KEY (`customerId`) REFERENCES `CUSTOMER` (`id`);

--
-- Constraints for table `PHONE_NUMBERS`
--
ALTER TABLE `PHONE_NUMBERS`
  ADD CONSTRAINT `PHONE_NUMBERS_ibfk_1` FOREIGN KEY (`id`) REFERENCES `CUSTOMER` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
