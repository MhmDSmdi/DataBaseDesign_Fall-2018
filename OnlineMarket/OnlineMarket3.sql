-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 14, 2018 at 05:37 PM
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
-- Database: `OnlineMarket`
--

-- --------------------------------------------------------

--
-- Table structure for table `Customer`
--

CREATE TABLE `Customer` (
  `ID` int(11) NOT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `CustomerPassword` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `Sex` enum('male','female') DEFAULT NULL,
  `Credit` int(255) DEFAULT NULL,
  `Cellphone` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Customer`
--

INSERT INTO `Customer` (`ID`, `Email`, `CustomerPassword`, `FirstName`, `LastName`, `Sex`, `Credit`, `Cellphone`, `Address`) VALUES
(313, 'ali@gmail.com', '2342edq3e', 'Ali', 'Asghari', 'male', 2000, '09120152274', 'valiasr'),
(413, 'Mariobalotelli@yahoo.com', 'ff3fqwd', 'Mario', 'balotelli', 'male', 1200000, '09120967873', 'Pasdaran'),
(813, 'francescoTotti@yahoo.com', 'fw4fv121', 'francesco', 'totti', 'male', 1503000, '09220994373', 'Azadi'),
(4231, 'Mohammad@yahoo.com', 'e23r23r', 'Mohammad', 'Hoseini', 'male', 52000, '09120158473', 'ShahrakGharb');

-- --------------------------------------------------------

--
-- Table structure for table `Manager`
--

CREATE TABLE `Manager` (
  `ID` int(11) NOT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `CustomerPassword` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `Sex` enum('male','female') DEFAULT NULL,
  `Cellphone` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Manager`
--

INSERT INTO `Manager` (`ID`, `Email`, `CustomerPassword`, `FirstName`, `LastName`, `Sex`, `Cellphone`, `Address`) VALUES
(551, 'josep_guardiola76@gmail.com', 'wedq323', 'josep', 'guardiola', 'male', '+93124234', 'SaadatAbad'),
(4511, 'jose_mourinho@gmail.com', 'dd23ddddd3', 'jose', 'mourinho', 'male', '+9312383', 'Pasdaran'),
(5521, 'shefer64@gmail.com', 'wedq323', 'vinfer', 'shefer', 'male', '0912432573', 'Pasdaran');

-- --------------------------------------------------------

--
-- Table structure for table `OrderProduct`
--

CREATE TABLE `OrderProduct` (
  `OrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Amount` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `OrderProduct`
--

INSERT INTO `OrderProduct` (`OrderID`, `ProductID`, `Amount`) VALUES
(1511, 135, '1'),
(1512, 129, '2'),
(1513, 135, '1'),
(1514, 133, '2'),
(1515, 123, '4'),
(1516, 127, '3'),
(1517, 132, '1'),
(1518, 128, '3'),
(1519, 135, '1'),
(1520, 133, '3'),
(1521, 128, '2'),
(1522, 127, '2'),
(1523, 133, '2'),
(1524, 131, '1');

-- --------------------------------------------------------

--
-- Table structure for table `OrderT`
--

CREATE TABLE `OrderT` (
  `ID` int(11) NOT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `OrderStatus` enum('Registered','Sending','Delivery') DEFAULT NULL,
  `PaymentType` enum('BankCart','CreditAccount') DEFAULT NULL,
  `CreatedAt` date DEFAULT NULL,
  `DeliveryAddress` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `OrderT`
--

INSERT INTO `OrderT` (`ID`, `VendorID`, `CustomerID`, `OrderStatus`, `PaymentType`, `CreatedAt`, `DeliveryAddress`) VALUES
(1511, 4523, 313, 'Registered', 'CreditAccount', '2018-11-08', 'valiasr'),
(1512, 414, 813, 'Sending', 'BankCart', '2018-11-01', 'valiasr'),
(1513, 4523, 813, 'Delivery', 'CreditAccount', '2018-10-01', NULL),
(1514, 4523, 413, 'Registered', 'CreditAccount', '2018-11-12', 'ShahrakGharb'),
(1515, 319, 4231, 'Delivery', 'BankCart', '2018-11-13', 'valiasr'),
(1516, 319, 413, 'Registered', 'CreditAccount', '2018-11-10', 'valiasr'),
(1517, 467, 813, 'Delivery', 'BankCart', '2018-10-18', 'AbasAbad'),
(1518, 414, 313, 'Sending', 'CreditAccount', '2018-11-10', NULL),
(1519, 4523, 313, 'Delivery', 'BankCart', '2018-09-12', NULL),
(1520, 4523, 313, 'Delivery', 'BankCart', '2018-08-16', NULL),
(1521, 414, 413, 'Registered', 'CreditAccount', '2018-11-13', NULL),
(1522, 319, 413, 'Sending', 'CreditAccount', '2018-11-25', 'valiasr\r\n'),
(1523, 4523, 313, 'Delivery', 'CreditAccount', '2018-11-24', NULL),
(1524, 467, 4231, 'Sending', 'BankCart', '2018-11-02', 'Azadi');

-- --------------------------------------------------------

--
-- Table structure for table `Product`
--

CREATE TABLE `Product` (
  `ID` int(11) NOT NULL,
  `Title` varchar(255) DEFAULT NULL,
  `Price` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Product`
--

INSERT INTO `Product` (`ID`, `Title`, `Price`) VALUES
(123, 'CaramelCoffee', 9500),
(124, 'IceCoffee', 6500),
(125, 'esperso', 8500),
(126, 'HotChocolate', 5500),
(127, 'IceAmericano', 10000),
(128, 'Pasta', 30000),
(129, 'Stake', 38000),
(130, 'pizza', 42000),
(131, 'HarryPotter', 120000),
(132, 'Hafez_nafis', 230000),
(133, 'Nike_312', 840000),
(134, 'Nike_411', 520000),
(135, 'Skechers_133', 1200000);

-- --------------------------------------------------------

--
-- Table structure for table `Vendor`
--

CREATE TABLE `Vendor` (
  `ID` int(11) NOT NULL,
  `Title` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `ManagerID` int(11) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Phone` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Vendor`
--

INSERT INTO `Vendor` (`ID`, `Title`, `City`, `ManagerID`, `Address`, `Phone`) VALUES
(319, 'LamizCoffee', 'Tehran', 551, 'Valiasr', '6621333'),
(414, 'Pasdaran', 'Tehran', 4511, 'Valiasr', '4124244'),
(467, 'Book Store', 'Ahvaz', 5521, 'AbasAbad', '4315244'),
(4523, 'Saadatabad', 'Tehran', 5521, 'ads', '4412313');

-- --------------------------------------------------------

--
-- Table structure for table `VendorProduct`
--

CREATE TABLE `VendorProduct` (
  `VendorID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Amount` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `VendorProduct`
--

INSERT INTO `VendorProduct` (`VendorID`, `ProductID`, `Amount`) VALUES
(319, 123, '100'),
(319, 124, '14'),
(319, 125, '120'),
(319, 126, '20'),
(319, 127, '35'),
(414, 128, '20'),
(414, 129, '10'),
(414, 130, '12'),
(467, 131, '23'),
(467, 132, '5'),
(4523, 133, '14'),
(4523, 134, '18'),
(4523, 135, '3');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Customer`
--
ALTER TABLE `Customer`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `Manager`
--
ALTER TABLE `Manager`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `OrderProduct`
--
ALTER TABLE `OrderProduct`
  ADD PRIMARY KEY (`OrderID`,`ProductID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Indexes for table `OrderT`
--
ALTER TABLE `OrderT`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `VendorID` (`VendorID`),
  ADD KEY `CustomerID` (`CustomerID`);

--
-- Indexes for table `Product`
--
ALTER TABLE `Product`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `Vendor`
--
ALTER TABLE `Vendor`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ManagerID` (`ManagerID`);

--
-- Indexes for table `VendorProduct`
--
ALTER TABLE `VendorProduct`
  ADD PRIMARY KEY (`VendorID`,`ProductID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `OrderProduct`
--
ALTER TABLE `OrderProduct`
  ADD CONSTRAINT `OrderProduct_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `OrderT` (`ID`),
  ADD CONSTRAINT `OrderProduct_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`);

--
-- Constraints for table `OrderT`
--
ALTER TABLE `OrderT`
  ADD CONSTRAINT `OrderT_ibfk_1` FOREIGN KEY (`VendorID`) REFERENCES `Vendor` (`ID`),
  ADD CONSTRAINT `OrderT_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`ID`);

--
-- Constraints for table `Vendor`
--
ALTER TABLE `Vendor`
  ADD CONSTRAINT `Vendor_ibfk_1` FOREIGN KEY (`ManagerID`) REFERENCES `Manager` (`ID`);

--
-- Constraints for table `VendorProduct`
--
ALTER TABLE `VendorProduct`
  ADD CONSTRAINT `VendorProduct_ibfk_1` FOREIGN KEY (`VendorID`) REFERENCES `Vendor` (`ID`),
  ADD CONSTRAINT `VendorProduct_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
