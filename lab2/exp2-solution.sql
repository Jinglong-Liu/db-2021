-- 姓名：XXX
-- 学号：XXX
-- 提交前请确保本次实验独立完成，若有参考请注明并致谢。

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1.1
-- 输入的商品名称，返回该商品的客户编号、客户名称、订单编号、订货数量和订货金额，并按订货金额降序输出
drop procedure if exists productInfo;
delimiter $$
create procedure productInfo(IN pName varchar(40))
BEGIN
    select o.customerNo,c.customerName,o.orderNo,od.quantity * od.price orderMoney
    from OrderMaster o,Customer c,OrderDetail od,Product p
    where pName = p.productName and od.productNo = p.productNo 
        and od.orderNo = o.orderNo and o.customerNo = c.customerNo
    order by orderMoney desc;
END$$
delimiter ;

call productInfo('32M DRAM');
-- 32M DRAM

-- END Q1.1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1.2
-- END Q1.2
-- 根据输入的员工编号，查询比该员工雇佣日期早的同一部门的员工编号、姓名、性别、雇佣日期、所属部门；
drop procedure if exists employeeAtSameDepartmentHireEarlier;
delimiter $$
create procedure employeeAtSameDepartmentHireEarlier (IN eNo char(8))
BEGIN
    select e.employeeNo,e.employeeName,e.gender,e.hireDate,e.department
    from Employee e,Employee e2
    where e2.employeeNo = eNo and e.department = e2.department and e.hireDate < e2.hireDate;
END $$
delimiter ;

call employeeAtSameDepartmentHireEarlier('E2008005');
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2.1
-- 存储函数功能：根据输入的商品名称，返回该商品订购平均价；
-- 调用该存储函数查询商品基本信息表中所有商品名称及其订购平均价。

set global log_bin_trust_function_creators = 1;
drop function if exists averageOrderPrice;
delimiter $$
create function averageOrderPrice (pName varchar(40))
returns integer
BEGIN
    declare ave integer;  
        select sum(od.quantity * od.price)/sum(od.quantity) into ave
        from Product p,OrderDetail od
        where p.productName = pName and od.productNo = p.productNo;
    return ave;
END $$
delimiter ;

select productName,averageOrderPrice(productName) averagePrice from Product p;


-- END Q2.1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2.2

-- 根据输入的商品编号，统计该商品的销售总量；
-- 调用该存储函数查询销售总量大于4的商品编号、商品名称及销售数量。
drop function if exists totalQuantity;
delimiter $$
create function totalQuantity (pNo char(9))
returns integer
BEGIN
    declare total integer;
        select sum(quantity) into total 
        from OrderDetail od
        where pNo = productNo;
    return total; 
END $$
delimiter ;
--
select distinct p.productNo,p.productName,totalQuantity(p.productNo) totalQuantity 
from Product p,OrderDetail od
where p.productNo = od.productNo and totalQuantity(p.productNo) > 4; 

-- END Q2.2

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3.1
drop trigger if exists reviseProductPrice;
delimiter $$
create trigger reviseProductPrice 
BEFORE INSERT on Product 
    for each row
BEGIN
   if new.productPrice > 1000 then
   set new.productPrice = 1000;
   end if;
END $$
delimiter ;
-- testcase
insert Product values('P20090001','很好的显示器',  '显示器',1100.00);
insert Product values('P20090002','很高级的显示器',  '显示器',1900.00);
insert Product values('P20090003','贵重的显示器',  '显示器',2888.00);
select * from Product where productNo like 'P2009000%';
-- drop new rows
delete from Product WHERE productNo like 'P2009000%';
-- END Q3.1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3.2
-- 当员工完成一个新的订单时，薪水增加5%；如果该员工是1992年前入职的，则再增加3%。
drop trigger if exists addSalaryAfterFinishOrder;

delimiter $$
create trigger addSalaryAfterFinishOrder 
BEFORE INSERT on OrderMaster 
    for each row
BEGIN
   update Employee e
   set e.salary = e.salary * 1.05
   where new.employeeNo = e.employeeNo;

   update Employee e
   set e.salary = e.salary * 1.03
   where new.employeeNo = e.employeeNo and e.hireDate < "19920101";
END $$
delimiter ;
-- testcase
select * from Employee where employeeNo  = 'E2008004' or employeeNo = 'E2005003';
-- 2600 3400 
insert OrderMaster values('200807010001','C20050001','E2008004','20080701',0.00,'I000000011'); 
insert OrderMaster values('200807010002','C20050001','E2005003','20080701',0.00,'I000000012'); 
-- 2600 * 1.05 = 2730; 3400 * 1.05 * 1.03 = 3677
select * from Employee where employeeNo  = 'E2008004' or employeeNo = 'E2005003';
-- END Q3.2
