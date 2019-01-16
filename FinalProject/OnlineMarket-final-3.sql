-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 16, 2019 at 10:21 PM
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
CREATE DATABASE IF NOT EXISTS `OnlineMarket-final` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `OnlineMarket-final`;

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
 VALUES (customerId, MD5(pass), email, name, lastname, zipcode, sex, credit);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddItemToShoppingCard` (IN `itemId` INT, IN `orderId` INT, IN `amount` INT, IN `marketId` INT)  BEGIN
    DECLARE itemPrice INT;
    DECLARE discount INT;
    DECLARE totallPrice INT;
    SELECT MARKET_ITEM.discount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId AND MARKET_ITEM.itemId = itemId INTO discount;
    SELECT ITEM.price FROM ITEM WHERE ITEM.id = itemId INTO itemPrice;
    SET totallPrice = amount * (itemPrice * (1 - discount));
    INSERT INTO Order_Item VALUES (orderId, itemId, amount, totallPrice);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckOrderByOprator` (IN `orderId` INT)  BEGIN
DECLARE numOrderItem INT;
DECLARE numExistItem INT;
DECLARE valid BOOLEAN DEFAULT TRUE;
DECLARE marketId INT;
DECLARE customerId INT;
DECLARE freeDelevery INT;
DECLARE deleveryId INT;
DECLARE totallPrice INT;
SELECT ORDERT.marketId, ORDERT.customerId INTO marketId, customerId FROM ORDERT WHERE ORDERT.id = orderId;

#Compute Number of Exist and Ordered
SELECT COUNT(*) INTO numExistItem
FROM (SELECT Order_Item.itemId, Order_Item.amount FROM Order_Item WHERE Order_Item.orderId = orderId) AS userItems NATURAL JOIN (SELECT MARKET_ITEM.itemId, MARKET_ITEM.amount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId) AS marketItems
WHERE userItems.amount < marketItems.amount;
SELECT COUNT(*) INTO numOrderItem FROM Order_Item WHERE Order_Item.orderId = orderId;
# if not equal that mean market have not enough item
IF numExistItem != numOrderItem THEN
	UPDATE ORDERT SET ORDERT.orderStatus = 'reject' WHERE ORDERT.id = orderId;
END IF;

SELECT COUNT(*) INTO freeDelevery FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free';
#if equal 0 that mean Delivery agent is not free
IF freeDelevery = 0 THEN
	UPDATE ORDERT SET ORDERT.orderStatus = 'reject' WHERE ORDERT.id = orderId;
END IF;
#Change Order Status to send
SELECT id INTO deleveryId FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free' LIMIT 1;
UPDATE ORDERT SET ORDERT.orderStatus = 'send' WHERE ORDERT.id = orderId;
#Change Delivery Agent Status to busy
UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.delevery_status = 'busy' WHERE DELEVERY_AGENT.id = deleveryId;
#Bind Delivery Agen to Order
INSERT DELEVERY_ORDER VALUES (deleveryId, orderId);
#Update amount of item in Market
UPDATE MARKET_ITEM AS marketItems
INNER JOIN 
(SELECT Order_Item.itemId, Order_Item.amount FROM Order_Item WHERE Order_Item.orderId = orderId) AS userItems 
ON userItems.itemId = marketItems.itemId
SET marketItems.amount = marketItems.amount - userItems.amount;
#Add 5% of totallPrice to credit of Delivery Agent
SELECT SUM(Order_Item.totallPrice) INTO totallPrice FROM Order_Item WHERE Order_Item.orderId = orderId GROUP BY Order_Item.orderId;
CALL Log(totallPrice);
UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.credit = DELEVERY_AGENT.credit + 0.5 * totallPrice WHERE DELEVERY_AGENT.id = deleveryId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DefineShoppingCard` (OUT `orderId` INT, INOUT `marketId` INT, IN `customerId` INT, IN `paymentType` ENUM('credit','bank-card'), IN `address` VARCHAR(255))  BEGIN
    DECLARE opent TIME;
    DECLARE closet TIME;
    SELECT MARKET.openTime, MARKET.closeTime INTO opent, closet FROM MARKET WHERE MARKET.id = marketId;
    CALL Log(opent);
    CALL Log(closet);
    CALL Log(CURRENT_TIME);
    IF (opent < CURRENT_TIME AND closet > CURRENT_TIME) THEN
       INSERT INTO ORDERT(ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address, ORDERT.orderDate, ORDERT.orderStatus)
       VALUES (marketId, customerId, paymentType, address, NOW(), 'submit');
       SELECT LAST_INSERT_ID() INTO orderId;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeliveryOrderToCustomer` (IN `orderId` INT, IN `deleveryAgentId` INT)  BEGIN
UPDATE ORDERT SET ORDERT.orderStatus = 'complete' WHERE ORDERT.id = orderId;
UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.delevery_status = 'free' WHERE DELEVERY_AGENT.id = deleveryAgentId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `IncreaseCredit` (IN `customerId` INT, IN `amount` INT)  BEGIN
 UPDATE CUSTOMER 
	SET 
    CUSTOMER.credit = CUSTOMER.credit + amount
	WHERE
    CUSTOMER.id = customerId;
 select "Log\n" as log into outfile '/home/mhmd/MHMD_DRIVE/Term5/DB/Project/FinalProject/log.txt';
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Log` (IN `log` VARCHAR(255))  BEGIN
INSERT INTO LOG(log) VALUES(log);
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
(12, '32131', 'asdad', 'Parsa', 'Kave', '4141', 'male', 10000),
(123, '312', 'd223', 'sddsf', 'smdi', '12ed', 'male', 4599379),
(3123, '4297f44b13955235245b2497399d7a93', '123dsf', 'f2e', 'f2ef', '23e', 'female', 123);

-- --------------------------------------------------------

--
-- Table structure for table `DELEVERY_AGENT`
--

CREATE TABLE `DELEVERY_AGENT` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `phonenumber` varchar(255) DEFAULT NULL,
  `delevery_status` enum('free','busy') DEFAULT NULL,
  `credit` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `DELEVERY_AGENT`
--

INSERT INTO `DELEVERY_AGENT` (`id`, `name`, `lastname`, `phonenumber`, `delevery_status`, `credit`) VALUES
(434, 'Mohammad', 'fsdfsdf', '343423434', 'free', 45000);

-- --------------------------------------------------------

--
-- Table structure for table `DELEVERY_ORDER`
--

CREATE TABLE `DELEVERY_ORDER` (
  `deleveryId` int(11) NOT NULL,
  `orderId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `DELEVERY_ORDER`
--

INSERT INTO `DELEVERY_ORDER` (`deleveryId`, `orderId`) VALUES
(434, 1),
(434, 2);

-- --------------------------------------------------------

--
-- Table structure for table `ITEM`
--

CREATE TABLE `ITEM` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ITEM`
--

INSERT INTO `ITEM` (`id`, `name`, `price`) VALUES
(41, 'Shampo', 224),
(4123, 'Pofak', 4300);

-- --------------------------------------------------------

--
-- Table structure for table `LOG`
--

CREATE TABLE `LOG` (
  `log` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `LOG`
--

INSERT INTO `LOG` (`log`) VALUES
('That is test for log'),
('asdasdsad'),
('Item is Exist In Market'),
('Order 1 Status set to send'),
('Delivery Agent 434 Status set to busy'),
('Item is Exist In Market'),
('Order 1 Status set to send'),
('Delivery Agent 434 Status set to busy'),
('12:00:00'),
('23:00:00'),
('21:59:01'),
('22:30:00'),
('23:00:00'),
('22:00:09'),
('Order send, Delivery Agent is Busy'),
('30000'),
('Delivery agent credit updated!'),
('30000'),
('Delivery agent credit updated!'),
('30000'),
('Delivery agent credit updated!'),
('amount of market updated!'),
('30000'),
('Delivery agent credit updated!');

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
  `operationsId` int(11) DEFAULT NULL,
  `openTime` time DEFAULT NULL,
  `closeTime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `MARKET`
--

INSERT INTO `MARKET` (`id`, `name`, `city`, `address`, `phonenumber`, `manager`, `supportId`, `deliveryId`, `operationsId`, `openTime`, `closeTime`) VALUES
(42, 'asd', 'dqw', 'qerr', '123123', 'awda', 123, 434, 321, '22:30:00', '23:00:00');

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

--
-- Dumping data for table `MARKET_ITEM`
--

INSERT INTO `MARKET_ITEM` (`marketId`, `itemId`, `amount`, `discount`) VALUES
(42, 4123, 238, 24);

-- --------------------------------------------------------

--
-- Table structure for table `OPERATIONS_OFFICER`
--

CREATE TABLE `OPERATIONS_OFFICER` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `OPERATIONS_OFFICER`
--

INSERT INTO `OPERATIONS_OFFICER` (`id`, `name`, `lastname`) VALUES
(321, 'Hosain', 'asdasd');

-- --------------------------------------------------------

--
-- Table structure for table `ORDERT`
--

CREATE TABLE `ORDERT` (
  `id` int(11) NOT NULL,
  `marketId` int(11) DEFAULT NULL,
  `customerId` int(11) DEFAULT NULL,
  `orderStatus` enum('send','complete','reject','submit') DEFAULT NULL,
  `paymentType` enum('credit','bank-card') DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `orderDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ORDERT`
--

INSERT INTO `ORDERT` (`id`, `marketId`, `customerId`, `orderStatus`, `paymentType`, `address`, `orderDate`) VALUES
(1, 42, 12, 'complete', 'credit', 'sfsdfsdf', '2019-01-16 10:22:05'),
(2, 42, 12, 'reject', 'bank-card', 'esdff', '2019-01-16 21:59:01');

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

--
-- Dumping data for table `Order_Item`
--

INSERT INTO `Order_Item` (`orderId`, `itemId`, `amount`, `totallPrice`) VALUES
(1, 4123, 10, 10000),
(2, 4123, 12, 30000);

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
-- Dumping data for table `SUPPORT_AGENT`
--

INSERT INTO `SUPPORT_AGENT` (`id`, `name`, `lastname`, `phonenumber`, `address`) VALUES
(123, 'ali', 'sad', '13111313', 'disadhsd');

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
-- Indexes for table `DELEVERY_ORDER`
--
ALTER TABLE `DELEVERY_ORDER`
  ADD PRIMARY KEY (`deleveryId`,`orderId`),
  ADD KEY `orderId` (`orderId`);

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ORDERT`
--
ALTER TABLE `ORDERT`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ADDRESSES`
--
ALTER TABLE `ADDRESSES`
  ADD CONSTRAINT `ADDRESSES_ibfk_1` FOREIGN KEY (`id`) REFERENCES `CUSTOMER` (`id`);

--
-- Constraints for table `DELEVERY_ORDER`
--
ALTER TABLE `DELEVERY_ORDER`
  ADD CONSTRAINT `DELEVERY_ORDER_ibfk_1` FOREIGN KEY (`deleveryId`) REFERENCES `DELEVERY_AGENT` (`id`),
  ADD CONSTRAINT `DELEVERY_ORDER_ibfk_2` FOREIGN KEY (`orderId`) REFERENCES `ORDERT` (`id`);

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
