-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 18, 2019 at 04:48 PM
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
 VALUES (customerId, MD5(pass), email, name, lastname, zipcode, sex, credit);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddDeliveryAgent` (IN `agentId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `deliveryStatus` ENUM('free','busy'), IN `credit` INT)  BEGIN
 INSERT INTO DELEVERY_AGENT VALUES (agentId, name, lastname, phonenumber, deliveryStatus, credit);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddItem` (IN `itemId` INT, IN `itemName` VARCHAR(255), IN `marketId` INT, IN `price` INT, IN `discount` INT, IN `amount` INT, IN `maxNumItem` INT)  BEGIN
 INSERT INTO ITEM VALUES (itemId, itemName, price);
 INSERT INTO MARKET_ITEM VALUES (marketId, itemId, amount, discount, maxNumItem);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddItemToShoppingCard` (IN `itemId` INT, IN `orderId` INT, IN `marketId` INT, IN `amount` INT, IN `customerId` INT)  BEGIN
    DECLARE itemPrice INT;
    DECLARE discount INT;
    DECLARE totallPrice INT;
    DECLARE customerCredit INT;
    DECLARE payment ENUM('credit', 'bank-card');
    SELECT CUSTOMER.credit INTO customerCredit FROM CUSTOMER WHERE CUSTOMER.id = customerId;
    SELECT ORDERT.paymentType INTO payment FROM ORDERT WHERE ORDERT.id = orderId;
    IF payment = 'credit' THEN
        SELECT MARKET_ITEM.discount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId AND MARKET_ITEM.itemId = itemId INTO discount;
        SELECT ITEM.price FROM ITEM WHERE ITEM.id = itemId INTO itemPrice;
        SET totallPrice = amount * (itemPrice * (1 - (discount / 100)));
        IF customerCredit > totallPrice THEN
        	UPDATE CUSTOMER SET CUSTOMER.credit = CUSTOMER.credit - totallPrice;
        	INSERT INTO ORDER_ITEM VALUES (orderId, itemId, amount, totallPrice);
        ELSE
        	CALL Log("Customer Hasn't got enough credit for this Item");
        END IF;
    ELSE
   		SELECT MARKET_ITEM.discount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId AND MARKET_ITEM.itemId = itemId INTO discount;
        SELECT ITEM.price FROM ITEM WHERE ITEM.id = itemId INTO itemPrice;
        SET totallPrice = amount * (itemPrice * (1 - (discount / 100)));
        INSERT INTO TRANSACTIONT VALUES (customerId, totallPrice, CURRENT_TIMESTAMP);
        INSERT INTO ORDER_ITEM VALUES (orderId, itemId, amount, totallPrice);
    END IF;
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddMarket` (IN `marketId` INT, IN `name` VARCHAR(255), IN `city` VARCHAR(255), IN `address` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `manager` VARCHAR(255), IN `supportId` INT, IN `deliveryId` INT, IN `operationsId` INT, IN `openTime` TIME, IN `closeTime` TIME)  BEGIN
 INSERT INTO MARKET VALUES (marketId, name, city, address, phonenumber, manager, supportId, deliveryId, operationsId, openTime, closeTime);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOptrationsOfficer` (IN `officerId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255))  BEGIN
 INSERT INTO OPERATIONS_OFFICER VALUES (officerId, name, lastname);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPhoneNumber` (IN `customerId` INT, IN `phone` VARCHAR(255))  BEGIN
 INSERT INTO PHONE_NUMBER
 VALUES (customerId, phone);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddSupportAgent` (IN `agentId` INT, IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `phonenumber` VARCHAR(255), IN `address` VARCHAR(255))  BEGIN
 INSERT INTO SUPPORT_AGENT VALUES (agentId, name, lastname, phonenumber, address);
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckOrderByOprator` (IN `orderId` INT, INOUT `valid` BOOLEAN)  BEGIN
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
FROM (SELECT ORDER_ITEM.itemId, ORDER_ITEM.amount FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId) AS userItems INNER JOIN (SELECT MARKET_ITEM.itemId, MARKET_ITEM.amount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId) AS marketItems
ON userItems.itemId = marketItems.itemId
WHERE userItems.amount <= marketItems.amount;

SELECT COUNT(*) INTO numOrderItem FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId;
# if not equal that mean market have not enough item
IF numExistItem != numOrderItem THEN
	SET valid = '0';
    CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} REJECTED because market has'nt got enough item!"));
ELSE 
    SELECT COUNT(*) INTO freeDelevery FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free';
    #if equal 0 that mean Delivery agent is not free
    IF freeDelevery = 0 THEN
        SET valid = '0';
		CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} REJECTED because there aren't any free delivery agent!"));
   	ELSE 
    	SET valid = '1';
        CALL LOG(concat("I CHANGE VALID TO 1 SO VALID IS: ", valid));
		#Change Order Status to send
        SELECT id INTO deleveryId FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free' LIMIT 1;
        #Change Delivery Agent Status to busy
        UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.delevery_status = 'busy' WHERE DELEVERY_AGENT.id = deleveryId;
        #Bind Delivery Agen to Order
        INSERT DELEVERY_ORDER VALUES (deleveryId, orderId);
        #Update amount of item in Market
        UPDATE MARKET_ITEM AS marketItems
        INNER JOIN 
        (SELECT ORDER_ITEM.itemId, ORDER_ITEM.amount FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId) AS userItems 
        ON userItems.itemId = marketItems.itemId
        SET marketItems.amount = marketItems.amount - userItems.amount;
        #Add 5% of totallPrice to credit of Delivery Agent
        SELECT SUM(ORDER_ITEM.totallPrice) INTO totallPrice FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId GROUP BY ORDER_ITEM.orderId;
        CALL Log(totallPrice);
        UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.credit = DELEVERY_AGENT.credit + 0.5 * totallPrice WHERE DELEVERY_AGENT.id = deleveryId;
		CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} SENT, Delivery Agent{", deleveryId, "} accept that."));
       CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} bind to DeliveryAgent{", deleveryId, "}"));
    END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConfirmeOrder` (IN `orderId` INT)  BEGIN
UPDATE ORDERT SET ORDERT.confirmed = '1' WHERE ORDERT.id = orderId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DefineShoppingCard` (OUT `orderId` INT, INOUT `marketId` INT, IN `customerId` INT, IN `paymentType` ENUM('credit','bank-card'), IN `address` VARCHAR(255))  BEGIN
DECLARE opent TIME;
DECLARE closet TIME;    
SELECT MARKET.openTime, MARKET.closeTime INTO opent, closet FROM MARKET WHERE MARKET.id = marketId;
IF (opent < CURRENT_TIME AND closet > CURRENT_TIME) THEN
	IF customerId != '0' THEN
    	INSERT INTO ORDERT(ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address, ORDERT.orderDate, ORDERT.orderStatus)
		VALUES (marketId, customerId, paymentType, address, NOW(), 'submit');
    ELSE
    	INSERT INTO ORDERT(ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address, ORDERT.orderDate, ORDERT.orderStatus)
		VALUES (marketId, '0', 'bank-card', null, NOW(), 'submit');
    END IF;
	SELECT LAST_INSERT_ID() INTO orderId;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeliveryOrderToCustomer` (IN `orderId` INT, IN `deleveryAgentId` INT)  BEGIN
UPDATE ORDERT SET ORDERT.orderStatus = 'complete' WHERE ORDERT.id = orderId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DiffGuestCustomerAccount` ()  BEGIN
DECLARE avrCustomer INT;
DECLARE avrGeustCustomer INT;

SELECT AVG(ORDER_ITEM.totallPrice)
INTO avrCustomer
FROM ORDERT, ORDER_ITEM
WHERE ORDER_ITEM.orderId = ORDERT.id AND ORDERT.customerId != '0';

SELECT AVG(ORDER_ITEM.totallPrice)
INTO avrGeustCustomer
FROM ORDERT, ORDER_ITEM
WHERE ORDER_ITEM.orderId = ORDERT.id AND ORDERT.customerId = '0';

SELECT avrCustomer;
SELECT avrGeustCustomer;
SELECT avrCustomer - avrGeustCustomer AS DIFF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EdtitCustomerProfile` (IN `id` INT, IN `pass` VARCHAR(255), IN `email` VARCHAR(255), IN `name` VARCHAR(255), IN `lastname` VARCHAR(255), IN `zipcode` VARCHAR(255))  BEGIN
UPDATE CUSTOMER SET CUSTOMER.pass = pass AND CUSTOMER.email = email AND CUSTOMER.name = name AND CUSTOMER.lastname = lastname AND CUSTOMER.zipcode = zipcode WHERE CUSTOMER.id = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxCreditDeliveryAgent` ()  BEGIN

SELECT DELEVERY_AGENT.id, DELEVERY_AGENT.name, DELEVERY_AGENT.lastname, DELEVERY_AGENT.delevery_status, avr.avrCredit
FROM DELEVERY_AGENT
INNER JOIN (SELECT DELEVERY_AGENT.id, AVG(DELEVERY_AGENT.credit) AS avrCredit
	  		FROM DELEVERY_AGENT
	  		GROUP BY DELEVERY_AGENT.id) AS avr
ON avr.id = DELEVERY_AGENT.id
ORDER BY avr.avrCredit DESC
LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxHoursWork` ()  BEGIN
SELECT *
FROM MARKET
ORDER BY ((MARKET.closeTime - MARKET.openTime)) DESC
LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNMaxItem` (IN `marketId` INT, IN `num` INT)  BEGIN

SELECT * 
FROM ITEM AS items
INNER JOIN (SELECT MARKET_ITEM.itemId
                  FROM MARKET_ITEM
                  WHERE MARKET_ITEM.marketId = marketId
                  ORDER BY (MARKET_ITEM.max_num_item - MARKET_ITEM.amount) DESC
                  LIMIT num) as marketItems
ON items.id = marketItems.itemId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRejectedPhonenumber` ()  BEGIN
SELECT *
FROM PHONE_NUMBERS
WHERE PHONE_NUMBERS.id IN (SELECT ORDERT.customerId
                           FROM ORDERT
                           WHERE ORDERT.orderStatus = 'reject')
LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `IncreaseCredit` (IN `customerId` INT, IN `amount` INT)  BEGIN
 UPDATE CUSTOMER 
	SET 
    CUSTOMER.credit = CUSTOMER.credit + amount
	WHERE
    CUSTOMER.id = customerId;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Log` (IN `log` VARCHAR(255))  BEGIN
INSERT INTO LOG(log) VALUES(log);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SignupAsGuest` ()  BEGIN
INSERT INTO CUSTOMER VALUES(0, null, null, 'GUEST', null, null, null, null);
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
(1, 'Tehran, Beheshti');

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
(0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1, '202cb962ac59075b964b07152d234b70', 'mhmd@gmail.com', 'MohammadReza', 'Samadi', '192192192', 'male', 9026632);

--
-- Triggers `CUSTOMER`
--
DELIMITER $$
CREATE TRIGGER `before_customer_update` BEFORE UPDATE ON `CUSTOMER` FOR EACH ROW BEGIN
    INSERT INTO CUSTOMER_LOG VALUES(concat(CURRENT_TIME, "  Customer ID : ", NEW.id, "  Name : ", NEW.name, "  Lastname : ", NEW.lastname, "  Password : ", NEW.pass, "  Credit : ", NEW.credit));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `CUSTOMER_LOG`
--

CREATE TABLE `CUSTOMER_LOG` (
  `log` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `CUSTOMER_LOG`
--

INSERT INTO `CUSTOMER_LOG` (`log`) VALUES
('10:32:02  Customer ID : 1  Name : MohammadReza  Lastname : Samadi  Password : 202cb962ac59075b964b07152d234b70  Credit : 53250'),
('10:32:25  Customer ID : 1  Name : MohammadReza  Lastname : Samadi  Password : 202cb962ac59075b964b07152d234b70  Credit : 56500'),
('10:34:47  Customer ID : 1  Name : MohammadReza  Lastname : Samadi  Password : 202cb962ac59075b964b07152d234b70  Credit : 56632'),
('11:19:11  Customer ID : 1  Name : MohammadReza  Lastname : Samadi  Password : 202cb962ac59075b964b07152d234b70  Credit : 2306632'),
('11:19:28  Customer ID : 1  Name : MohammadReza  Lastname : Samadi  Password : 202cb962ac59075b964b07152d234b70  Credit : 9026632');

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
(1, 'Saleh', 'Saberi', '0912435231', 'busy', 1227500);

--
-- Triggers `DELEVERY_AGENT`
--
DELIMITER $$
CREATE TRIGGER `before_deliveryagent_update` BEFORE UPDATE ON `DELEVERY_AGENT` FOR EACH ROW BEGIN
    INSERT INTO DELIVERY_LOG VALUES(concat(CURRENT_TIME, "  DelivaryAgent ID : ", NEW.id, "  Status : ", NEW.delevery_status, "  Credit : ", NEW.credit));
END
$$
DELIMITER ;

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
(1, 4),
(1, 5);

-- --------------------------------------------------------

--
-- Table structure for table `DELIVERY_LOG`
--

CREATE TABLE `DELIVERY_LOG` (
  `log` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `DELIVERY_LOG`
--

INSERT INTO `DELIVERY_LOG` (`log`) VALUES
('11:39:12  DelivaryAgent ID : 1  Status : busy  Credit : 0'),
('11:39:12  DelivaryAgent ID : 1  Status : busy  Credit : 173750'),
('11:56:02  DelivaryAgent ID : 1  Status : free  Credit : 173750'),
('11:56:11  DelivaryAgent ID : 1  Status : busy  Credit : 173750'),
('11:56:11  DelivaryAgent ID : 1  Status : busy  Credit : 347500'),
('11:58:43  DelivaryAgent ID : 1  Status : free  Credit : 347500'),
('11:59:46  DelivaryAgent ID : 1  Status : busy  Credit : 347500'),
('11:59:46  DelivaryAgent ID : 1  Status : busy  Credit : 521250'),
('12:26:16  DelivaryAgent ID : 1  Status : free  Credit : 521250'),
('12:48:42  DelivaryAgent ID : 1  Status : busy  Credit : 521250'),
('12:48:42  DelivaryAgent ID : 1  Status : busy  Credit : 695000'),
('12:51:00  DelivaryAgent ID : 1  Status : free  Credit : 695000'),
('12:52:01  DelivaryAgent ID : 1  Status : busy  Credit : 695000'),
('12:52:01  DelivaryAgent ID : 1  Status : busy  Credit : 868750'),
('12:52:58  DelivaryAgent ID : 1  Status : free  Credit : 868750'),
('12:53:23  DelivaryAgent ID : 1  Status : busy  Credit : 868750'),
('12:53:23  DelivaryAgent ID : 1  Status : busy  Credit : 1042500'),
('12:53:57  DelivaryAgent ID : 1  Status : free  Credit : 1042500'),
('12:54:17  DelivaryAgent ID : 1  Status : busy  Credit : 1042500'),
('12:54:17  DelivaryAgent ID : 1  Status : busy  Credit : 1216250'),
('12:54:47  DelivaryAgent ID : 1  Status : free  Credit : 1216250'),
('18:18:30  DelivaryAgent ID : 1  Status : busy  Credit : 1216250'),
('18:18:30  DelivaryAgent ID : 1  Status : busy  Credit : 1227500');

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
(1, 'Pashmak1', 25000),
(2, 'Pashmak2', 40000),
(3, 'Pashmak3', 45000);

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
('90:00:00'),
('23:00:00'),
('10:47:51'),
('09:00:00'),
('23:00:00'),
('10:52:10'),
('11:29:03 , order {3} REJECTED because market has\'nt got enough item!'),
('09:00:00'),
('23:00:00'),
('11:33:43'),
('347500'),
('11:39:12 , order {4} SENT, Delivery Agent{1} accept that.'),
('11:39:12 , order {4} bind to DeliveryAgent{1}'),
('11:55:26 , order {4} REJECTED because there aren\'t any free delivery agent!'),
('VALID: 0'),
('347500'),
('11:56:11 , order {4} SENT, Delivery Agent{1} accept that.'),
('11:56:11 , order {4} bind to DeliveryAgent{1}'),
('VALID: 0'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('347500'),
('11:59:46 , order {4} SENT, Delivery Agent{1} accept that.'),
('11:59:46 , order {4} bind to DeliveryAgent{1}'),
('First if VALID: 0'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('347500'),
('12:48:42 , order {4} SENT, Delivery Agent{1} accept that.'),
('12:48:42 , order {4} bind to DeliveryAgent{1}'),
('In Else VALID: 1'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('347500'),
('12:52:01 , order {4} SENT, Delivery Agent{1} accept that.'),
('12:52:01 , order {4} bind to DeliveryAgent{1}'),
('In Else VALID: 1'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('347500'),
('12:53:23 , order {4} SENT, Delivery Agent{1} accept that.'),
('12:53:23 , order {4} bind to DeliveryAgent{1}'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('347500'),
('12:54:17 , order {4} SENT, Delivery Agent{1} accept that.'),
('12:54:17 , order {4} bind to DeliveryAgent{1}'),
('In Else VALID: 1'),
('I CHANGE VALID TO 1 SO VALID IS: 1'),
('22500'),
('18:18:30 , order {5} SENT, Delivery Agent{1} accept that.'),
('18:18:30 , order {5} bind to DeliveryAgent{1}'),
('In Else VALID: 1');

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
(1, 'Pashmak_Haj_Abdollah', 'Tehran', 'Tehran, Azadi', '33242423', 'Haj Abdollah', 1, 1, 1, '09:00:00', '23:00:00'),
(2, 'DDDD', 'adsad', '24324qew', '12331', 'asdasd', 1, 1, 1, '07:00:00', '23:55:00');

-- --------------------------------------------------------

--
-- Table structure for table `MARKET_ITEM`
--

CREATE TABLE `MARKET_ITEM` (
  `marketId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `discount` int(11) DEFAULT NULL,
  `max_num_item` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `MARKET_ITEM`
--

INSERT INTO `MARKET_ITEM` (`marketId`, `itemId`, `amount`, `discount`, `max_num_item`) VALUES
(1, 1, 51, 10, 100),
(1, 2, 10, 5, 45),
(1, 3, 99, 50, 100);

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
(1, 'Saman', 'Salehi'),
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
  `orderDate` datetime NOT NULL,
  `confirmed` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ORDERT`
--

INSERT INTO `ORDERT` (`id`, `marketId`, `customerId`, `orderStatus`, `paymentType`, `address`, `orderDate`, `confirmed`) VALUES
(3, 1, 1, 'reject', 'credit', 'Tehran, Atisaz', '2019-01-18 10:52:10', 1),
(4, 1, 1, 'complete', 'bank-card', 'Tehran, Azadi', '2019-01-18 11:33:43', 1),
(5, 1, 0, 'send', 'bank-card', NULL, '2019-01-18 18:17:03', 1);

--
-- Triggers `ORDERT`
--
DELIMITER $$
CREATE TRIGGER `before_order_update` BEFORE UPDATE ON `ORDERT` FOR EACH ROW BEGIN
	DECLARE valid BOOLEAN DEFAULT '0';
    DECLARE deleveryAgentId INT;
    #
    DECLARE numOrderItem INT;
    DECLARE numExistItem INT;
    DECLARE marketId INT;
    DECLARE customerId INT;
    DECLARE freeDelevery INT;
    DECLARE deleveryId INT;
    DECLARE totallPrice INT;
    DECLARE orderId INT;
    SET orderId = NEW.id;
    #
 	IF (NEW.confirmed = '1' AND NEW.orderStatus = 'submit') THEN
    	#CALL CheckOrderByOprator(NEW.id, valid);
        #
        SELECT ORDERT.marketId, ORDERT.customerId INTO marketId, customerId FROM ORDERT WHERE ORDERT.id = orderId;
        #Compute Number of Exist and Ordered
        SELECT COUNT(*) INTO numExistItem
        FROM (SELECT ORDER_ITEM.itemId, ORDER_ITEM.amount FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId) AS userItems INNER JOIN (SELECT MARKET_ITEM.itemId, MARKET_ITEM.amount FROM MARKET_ITEM WHERE MARKET_ITEM.marketId = marketId) AS marketItems
        ON userItems.itemId = marketItems.itemId
        WHERE userItems.amount <= marketItems.amount;

        SELECT COUNT(*) INTO numOrderItem FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId;
        # if not equal that mean market have not enough item
        IF numExistItem != numOrderItem THEN
            SET valid = '0';
            CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} REJECTED because market has'nt got enough item!"));
        ELSE 
            SELECT COUNT(*) INTO freeDelevery FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free';
            #if equal 0 that mean Delivery agent is not free
            IF freeDelevery = 0 THEN
                SET valid = '0';
                CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} REJECTED because there aren't any free delivery agent!"));
            ELSE 
                SET valid = '1';
                CALL LOG(concat("I CHANGE VALID TO 1 SO VALID IS: ", valid));
                #Change Order Status to send
                SELECT id INTO deleveryId FROM DELEVERY_AGENT WHERE DELEVERY_AGENT.delevery_status = 'free' LIMIT 1;
                #Change Delivery Agent Status to busy
                UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.delevery_status = 'busy' WHERE DELEVERY_AGENT.id = deleveryId;
                #Bind Delivery Agen to Order
                INSERT DELEVERY_ORDER VALUES (deleveryId, orderId);
                #Update amount of item in Market
                UPDATE MARKET_ITEM AS marketItems
                INNER JOIN 
                (SELECT ORDER_ITEM.itemId, ORDER_ITEM.amount FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId) AS userItems 
                ON userItems.itemId = marketItems.itemId
                SET marketItems.amount = marketItems.amount - userItems.amount;
                #Add 5% of totallPrice to credit of Delivery Agent
                SELECT SUM(ORDER_ITEM.totallPrice) INTO totallPrice FROM ORDER_ITEM WHERE ORDER_ITEM.orderId = orderId GROUP BY ORDER_ITEM.orderId;
                CALL Log(totallPrice);
                UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.credit = DELEVERY_AGENT.credit + 0.5 * totallPrice WHERE DELEVERY_AGENT.id = deleveryId;
                CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} SENT, Delivery Agent{", deleveryId, "} accept that."));
               CALL Log(concat(CURRENT_TIME, " , order {", orderId, "} bind to DeliveryAgent{", deleveryId, "}"));
            END IF;
             IF valid = '0' THEN
          	 CALL Log(concat("First if VALID: ", valid));
             SET NEW.orderStatus = 'reject';
             INSERT INTO ORDER_LOG VALUES(concat(CURRENT_TIME, " Order{", NEW.id, "} Reject!"));
          ELSE
          	CALL Log(concat("In Else VALID: ", valid));
            SET NEW.orderStatus = 'send';
            INSERT INTO ORDER_LOG VALUES(concat(CURRENT_TIME, " Order{", NEW.id, "} Sent."));
          END IF;
	END IF;
        #
         
    END IF;
   IF NEW.orderStatus = 'complete' AND OLD.orderStatus != 'complete' THEN
   		SELECT DELEVERY_ORDER.deleveryId INTO deleveryAgentId FROM DELEVERY_ORDER WHERE DELEVERY_ORDER.orderId = NEW.id;
   		UPDATE DELEVERY_AGENT SET DELEVERY_AGENT.delevery_status = 'free' WHERE DELEVERY_AGENT.id = deleveryAgentId;
   END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ORDER_ITEM`
--

CREATE TABLE `ORDER_ITEM` (
  `orderId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `totallPrice` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ORDER_ITEM`
--

INSERT INTO `ORDER_ITEM` (`orderId`, `itemId`, `amount`, `totallPrice`) VALUES
(3, 1, 10, 2250000),
(3, 2, 42, 6720000),
(4, 1, 7, 157500),
(4, 2, 5, 190000),
(5, 3, 1, 22500);

-- --------------------------------------------------------

--
-- Table structure for table `ORDER_LOG`
--

CREATE TABLE `ORDER_LOG` (
  `log` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ORDER_LOG`
--

INSERT INTO `ORDER_LOG` (`log`) VALUES
('11:39:12 Order{4} Reject!'),
('12:52:01 Order{4} Sent.'),
('12:54:17 Order{4} Sent.'),
('18:18:30 Order{5} Sent.');

-- --------------------------------------------------------

--
-- Table structure for table `PHONE_NUMBER`
--

CREATE TABLE `PHONE_NUMBER` (
  `id` int(11) NOT NULL,
  `phonenumber` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `PHONE_NUMBER`
--

INSERT INTO `PHONE_NUMBER` (`id`, `phonenumber`) VALUES
(1, '09120189176');

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
(1, 'Ali', 'Akbari', '9092301201', 'Tehran, Valiasr');

-- --------------------------------------------------------

--
-- Table structure for table `TRANSACTIONT`
--

CREATE TABLE `TRANSACTIONT` (
  `customerId` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `transactionDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `TRANSACTIONT`
--

INSERT INTO `TRANSACTIONT` (`customerId`, `amount`, `transactionDate`) VALUES
(1, NULL, '2019-01-18 08:06:34'),
(1, NULL, '2019-01-18 08:07:29'),
(1, 157500, '2019-01-18 08:08:33'),
(0, 22500, '2019-01-18 14:47:54');

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
-- Indexes for table `ORDER_ITEM`
--
ALTER TABLE `ORDER_ITEM`
  ADD PRIMARY KEY (`orderId`,`itemId`),
  ADD KEY `itemId` (`itemId`);

--
-- Indexes for table `PHONE_NUMBER`
--
ALTER TABLE `PHONE_NUMBER`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
-- Constraints for table `ORDER_ITEM`
--
ALTER TABLE `ORDER_ITEM`
  ADD CONSTRAINT `ORDER_ITEM_ibfk_1` FOREIGN KEY (`itemId`) REFERENCES `ITEM` (`id`),
  ADD CONSTRAINT `ORDER_ITEM_ibfk_2` FOREIGN KEY (`orderId`) REFERENCES `ORDERT` (`id`);

--
-- Constraints for table `PHONE_NUMBER`
--
ALTER TABLE `PHONE_NUMBER`
  ADD CONSTRAINT `PHONE_NUMBER_ibfk_1` FOREIGN KEY (`id`) REFERENCES `CUSTOMER` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
