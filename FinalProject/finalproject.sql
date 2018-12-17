CREATE TABLE CUSTOMER (id INT, pass VARCHAR(255), email VARCHAR(255), name VARCHAR(255), lastname VARCHAR(255), zipcode VARCHAR(255), sex ENUM('male', 'female'), credit INT, PRIMARY KEY(id))

CREATE TABLE SUPPORT_AGENT(id INT, name VARCHAR(255), lastname VARCHAR(255), phonenumber VARCHAR(255), address VARCHAR(255), PRIMARY KEY(id));

CREATE TABLE OPERATIONS_OFFICER(id INT, name VARCHAR(255), lastname VARCHAR(255), PRIMARY KEY(id));

CREATE TABLE DELEVERY_AGENT(id INT, name VARCHAR(255), lastname VARCHAR(255), phonenumber VARCHAR(255), delevery_status ENUM('free', 'busy'), PRIMARY KEY(id));

CREATE TABLE MARKET(id INT, name VARCHAR(255), city VARCHAR(255), address VARCHAR(255), phonenumber VARCHAR(255), manager VARCHAR(255), supportId INT, deliveryId INT, operationsId INT, PRIMARY KEY(id), FOREIGN KEY(supportId) REFERENCES SUPPORT_AGENT(id), FOREIGN KEY(deliveryId) REFERENCES DELEVERY_AGENT(id), FOREIGN KEY(operationsId) REFERENCES OPERATIONS_OFFICER(id))

CREATE TABLE ORDERT(id INT, marketId INT, customerId INT, orderStatus ENUM('send', 'complete', 'reject'), paymentType ENUM('credit', 'bank-card'), date DATE, address VARCHAR(255), PRIMARY KEY(id), FOREIGN KEY(marketId) REFERENCES MARKET(id), FOREIGN KEY(customerId) REFERENCES CUSTOMER(id));

CREATE TABLE ITEM(id INT, name VARCHAR(255), marketId INT, price INT, discount INT, PRIMARY KEY (id), FOREIGN KEY(marketId) REFERENCES MARKET(id));

CREATE TABLE PHONE_NUMBERS(id INT, phonenumber VARCHAR(255), PRIMARY KEY(id, phonenumber), FOREIGN KEY(id) REFERENCES CUSTOMER(id));

CREATE TABLE ADDRESSES(id INT, address VARCHAR(255), PRIMARY KEY(id, address), FOREIGN KEY(id) REFERENCES CUSTOMER(id));

CREATE TABLE CUSTOMER_ORDER(customerId INT, orderId INT, orderDate DATE, PRIMARY KEY(customerId, orderId), FOREIGN KEY(customerId) REFERENCES CUSTOMER(id), FOREIGN KEY(orderId) REFERENCES ORDERT(id))

CREATE TABLE Order_Item(orderId INT, itemId INT, PRIMARY KEY(orderId, itemId), FOREIGN KEY(itemId) REFERENCES ITEM(id), FOREIGN KEY(orderId) REFERENCES ORDERT(id))

CREATE TABLE MARKET_ITEM(marketId INT, itemId INT, PRIMARY KEY(marketId, itemId), FOREIGN KEY(itemId) REFERENCES ITEM(id), FOREIGN KEY(marketId) REFERENCES MARKET(id))

////

DELIMITER $$
CREATE PROCEDURE AddOrder(IN marketId INT, IN customerId INT, IN paymentType ENUM('credit', 'bank-card'), IN address VARCHAR(255))
 BEGIN
 INSERT INTO ORDERT (ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address);
 VALUES (marketId, customerId, paymentType, address)
 END $$
DELIMITER ;	

DELIMITER $$
CREATE PROCEDURE AddCustomer(IN customerId INT, IN pass VARCHAR(255), IN email VARCHAR(255), IN name VARCHAR(255), IN lastname VARCHAR(255), IN zipcode VARCHAR(255), IN sex ENUM('male', 'female'), IN credit INT)
 BEGIN
 INSERT INTO CUSTOMER
 VALUES (customerId, pass, email, name, lastname, zipcode, sex, credit);
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE AddAddress(IN customerId INT, IN address VARCHAR(255))
 BEGIN
 INSERT INTO ADDRESSES
 VALUES (customerId, address);
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE AddPhoneNumber(IN customerId INT, IN phone VARCHAR(255))
 BEGIN
 INSERT INTO PHONE_NUMBERS
 VALUES (customerId, phone);
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IncreaseCredit(IN customerId INT, IN amount INT)
 BEGIN
 UPDATE CUSTOMER 
	SET 
    CUSTOMER.credit = CUSTOMER.credit + amount;
	WHERE
    CUSTOMER.id = customerId;
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE AddItem(IN itemId INT, IN itemName VARCHAR(255), IN marketId INT, IN price INT, IN discount INT, IN amount INT)
 BEGIN
 INSERT INTO ITEM VALUES (itemId, itemName, price);
 INSERT INTO MARKET_ITEM VALUES (marketId, itemId, amount, discount);
 END $$
DELIMITER ;	

DELIMITER $$
CREATE PROCEDURE AddSupportAgent(IN agentId INT, IN name VARCHAR(255),IN lastname VARCHAR(255), IN phonenumber VARCHAR(255),IN address VARCHAR(255))
 BEGIN
 INSERT INTO SUPPORT_AGENT VALUES (agentId, name, lastname, phonenumber, address);
 END $$
DELIMITER ;	

DELIMITER $$
CREATE PROCEDURE AddOptrationsOfficer(IN officerId INT, IN name VARCHAR(255),IN lastname VARCHAR(255))
 BEGIN
 INSERT INTO OPERATIONS_OFFICER VALUES (officerId, name, lastname);
 END $$
DELIMITER ;	

DELIMITER $$
CREATE PROCEDURE AddDeliveryAgent(IN agentId INT, IN name VARCHAR(255),IN lastname VARCHAR(255), IN phonenumber VARCHAR(255), IN deliveryStatus ENUM('free', 'busy'))
 BEGIN
 INSERT INTO DELEVERY_AGENT VALUES (agentId, name, lastname, phonenumber, deliveryStatus);
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE AddMarket(IN marketId INT, IN name VARCHAR(255),IN city VARCHAR(255), IN address VARCHAR(255), IN phonenumber VARCHAR(255), IN manager VARCHAR(255),IN supportId INT, IN deliveryId INT, IN operationsId INT)
 BEGIN
 INSERT INTO MARKET VALUES (marketId, name, city, address, phonenumber, manager, supportId, deliveryId, operationsId);
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE DefineShoppingCard(IN orderId INT, IN marketId INT, IN customerId INT, IN paymentType ENUM('credit', 'bank-card'), IN address VARCHAR(255))
 BEGIN 
 INSERT INTO ORDERT(ORDERT.id, ORDERT.marketId, ORDERT.customerId, ORDERT.paymentType, ORDERT.address, ORDERT.orderDate)
 VALUES (orderId, marketId, customerId, paymentType, address, NOW());
 END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE AddItemToOrder(IN orderId INT, IN itemId INT, IN amount INT)
 BEGIN 
 DECLARE cost INT;
 (SELECT ITEM.price INTO cost
 		FROM ITEM
 		WHERE ITEM.id = itemId);
 SET cost = cost * amount;
 INSERT INTO Order_Item
 VALUES (orderId, itemId, amount, cost);
 END $$
DELIMITER ;






