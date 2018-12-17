-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 17, 2018 at 08:57 PM
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

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAddress` (IN `customerId` INT, IN `address` VARCHAR(255))  BEGIN
 INSERT INTO ADDRESSES
 VALUES (customerId, address);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddCustomer` (IN `customerId` INT, IN `pass` VARCHAR(255), IN `email` VARCHAR(255), IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `zipcode` VARCHAR(255), IN `sex` ENUM('male','female'), IN `credit` INT)  BEGIN
 INSERT INTO CUSTOMER
 VALUES (customerId, pass, email, name, lastname, zipcode, sex, credit);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddDeliveryAgent` (IN `agentId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `deliveryStatus` ENUM('free','busy'))  BEGIN
 INSERT INTO DELEVERY_AGENT VALUES (agentId, name, lastname, phonenumber, deliveryStatus);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddItem` (IN `itemId` INT, IN `itemName` VARCHAR(255), IN `marketId` INT, IN `price` INT, IN `discount` INT, IN `amount` INT)  BEGIN
 INSERT INTO ITEM VALUES (itemId, itemName, price);
 INSERT INTO MARKET_ITEM VALUES (marketId, itemId, amount, discount);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddItemToOrder` (IN `orderId` INT, IN `itemId` INT, IN `amount` INT)  BEGIN 
 DECLARE cost INT;
 (SELECT ITEM.price INTO cost
 		FROM ITEM
 		WHERE ITEM.id = itemId);
 SET cost = cost * amount;
 INSERT INTO Order_Item
 VALUES (orderId, itemId, amount, cost);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddMarket` (IN `marketId` INT, IN `name` VARCHAR(255), IN `city` VARCHAR(255), IN `address` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `manager` VARCHAR(255), IN `supportId` INT, IN `deliveryId` INT, IN `operationsId` INT)  BEGIN
 INSERT INTO MARKET VALUES (marketId, name, city, address, phonenumber, manager, supportId, deliveryId, operationsId);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOptrationsOfficer` (IN `officerId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255))  BEGIN
 INSERT INTO OPERATIONS_OFFICER VALUES (officerId, name, lastname);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOrder` (IN `marketId` INT, IN `customerId` INT, IN `paymentType` ENUM('credit','bank-card'), IN `address` VARCHAR(255))  BEGIN
 INSERT INTO ORDERT (ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address)
 VALUES(marketId, customerId, paymentType, address);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPhoneNumber` (IN `customerId` INT, IN `phone` VARCHAR(255))  BEGIN
 INSERT INTO PHONE_NUMBERS
 VALUES (customerId, phone);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddSupportAgent` (IN `agentId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `address` VARCHAR(255))  BEGIN
 INSERT INTO SUPPORT_AGENT VALUES (agentId, name, lastname, phonenumber, address);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DefineShoppingCard` (IN `orderId` INT, IN `marketId` INT, IN `customerId` INT, IN `paymentType` ENUM('credit','bank-card'), IN `address` VARCHAR(255))  BEGIN 
 INSERT INTO ORDERT(ORDERT.id, ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address, ORDERT.orderDate)
 VALUES (orderId, marketId, customerId, paymentType, address, NOW());
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `IncreaseCredit` (IN `customerId` INT, IN `amount` INT)  BEGIN
 UPDATE CUSTOMER 
	SET 
    CUSTOMER.credit = CUSTOMER.credit + amount
	WHERE
    CUSTOMER.id = customerId;
 select "Log\n" as log into outfile '/home/mhmd/MHMD_DRIVE/Term5/DB/Project/FinalProject/log.txt';
 END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ADDRESSES`
--

CREATE TABLE `ADDRESSES` (
  `id` int(11) NOT NULL,
  `address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ADDRESSES`
--

INSERT INTO `ADDRESSES` (`id`, `address`) VALUES
(123, 'asdasdasd');

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

--
-- Dumping data for table `CUSTOMER`
--

INSERT INTO `CUSTOMER` (`id`, `pass`, `email`, `name`, `lastname`, `zipcode`, `sex`, `credit`) VALUES
(123, '312', 'd223', 'sddsf', 'smdi', '12ed', 'male', 4599379);

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
  `price` int(11) DEFAULT NULL
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
-- Table structure for table `MARKET_ITEM`
--

CREATE TABLE `MARKET_ITEM` (
  `marketId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `discount` int(11) DEFAULT NULL
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
  `address` varchar(255) DEFAULT NULL,
  `orderDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Order_Item`
--

CREATE TABLE `Order_Item` (
  `orderId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `totallPrice` int(11) NOT NULL
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
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `MARKET`
--
ALTER TABLE `MARKET`
  ADD PRIMARY KEY (`id`),
  ADD KEY `supportId` (`supportId`),
  ADD KEY `deliveryId` (`deliveryId`),
  ADD KEY `operationsId` (`operationsId`);

--
-- Indexes for table `MARKET_ITEM`
--
ALTER TABLE `MARKET_ITEM`
  ADD PRIMARY KEY (`marketId`,`itemId`),
  ADD KEY `itemId` (`itemId`);

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
-- Indexes for table `Order_Item`
--
ALTER TABLE `Order_Item`
  ADD PRIMARY KEY (`orderId`,`itemId`),
  ADD KEY `itemId` (`itemId`);

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
-- Constraints for table `MARKET`
--
ALTER TABLE `MARKET`
  ADD CONSTRAINT `MARKET_ibfk_1` FOREIGN KEY (`supportId`) REFERENCES `SUPPORT_AGENT` (`id`),
  ADD CONSTRAINT `MARKET_ibfk_2` FOREIGN KEY (`deliveryId`) REFERENCES `DELEVERY_AGENT` (`id`),
  ADD CONSTRAINT `MARKET_ibfk_3` FOREIGN KEY (`operationsId`) REFERENCES `OPERATIONS_OFFICER` (`id`);

--
-- Constraints for table `MARKET_ITEM`
--
ALTER TABLE `MARKET_ITEM`
  ADD CONSTRAINT `MARKET_ITEM_ibfk_1` FOREIGN KEY (`itemId`) REFERENCES `ITEM` (`id`),
  ADD CONSTRAINT `MARKET_ITEM_ibfk_2` FOREIGN KEY (`marketId`) REFERENCES `MARKET` (`id`);

--
-- Constraints for table `ORDERT`
--
ALTER TABLE `ORDERT`
  ADD CONSTRAINT `ORDERT_ibfk_1` FOREIGN KEY (`marketId`) REFERENCES `MARKET` (`id`),
  ADD CONSTRAINT `ORDERT_ibfk_2` FOREIGN KEY (`customerId`) REFERENCES `CUSTOMER` (`id`);

--
-- Constraints for table `Order_Item`
--
ALTER TABLE `Order_Item`
  ADD CONSTRAINT `Order_Item_ibfk_1` FOREIGN KEY (`itemId`) REFERENCES `ITEM` (`id`),
  ADD CONSTRAINT `Order_Item_ibfk_2` FOREIGN KEY (`orderId`) REFERENCES `ORDERT` (`id`);

--
-- Constraints for table `PHONE_NUMBERS`
--
ALTER TABLE `PHONE_NUMBERS`
  ADD CONSTRAINT `PHONE_NUMBERS_ibfk_1` FOREIGN KEY (`id`) REFERENCES `CUSTOMER` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
