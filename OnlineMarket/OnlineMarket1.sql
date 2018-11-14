-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 13, 2018 at 06:19 PM
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
  `Sex` bit(1) DEFAULT NULL,
  `Credit` int(11) DEFAULT NULL,
  `Cellphone` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `Sex` bit(1) DEFAULT NULL,
  `Cellphone` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `OrderProduct`
--

CREATE TABLE `OrderProduct` (
  `OrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Amount` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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

-- --------------------------------------------------------

--
-- Table structure for table `Product`
--

CREATE TABLE `Product` (
  `ID` int(11) NOT NULL,
  `Title` varchar(255) DEFAULT NULL,
  `Price` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
